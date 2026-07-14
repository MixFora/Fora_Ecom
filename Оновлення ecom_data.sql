-- Подивитись чи немає одного ж замовлення у різних місяцях
 WITH Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ordernum ORDER BY type) AS rn
    FROM Business_Analytic.ecom.ecom_orders
	where year=2026 and month=5
)
select * FROM Duplicates WHERE rn > 1;
--select * into #dubs FROM Duplicates WHERE rn > 1;

select eo.* into #delete from Business_Analytic.ecom.ecom_orders eo
join #dubs d on d.ordernum=eo.ordernum and d.year=eo.year and d.month=eo.month and d.type<>eo.type


delete eo from Business_Analytic.ecom.ecom_orders eo
join #delete d on d.ordernum=eo.ordernum and d.year=eo.year and d.month=eo.month and d.type=eo.type

-------------------------- Привязка чеків до номерів замовлень

/*SELECT ordernumber, ordersum, createdate, chequeid, filialid, city, street
  FROM [DBMS_CulinaryOrder].[CulinaryOrder].[Export].[view_Orders]
  where ordernumber in (24663440, 24663491, 24664596)*/


drop table if exists #final
SELECT e.ordernum, v.createdate, v.chequeid, e.type, e.year, e.month, v.filialid filid, ordersum
into #final
FROM Business_Analytic.ecom.ecom_orders e
join [DBMS_CulinaryOrder].[CulinaryOrder].[Export].[view_Orders] v on e.ordernum=v.ordernumber
and e.year=2026 and e.month=5 and (e.chequeid=0 or e.filid=0 or e.chequeid is NULL) 
and v.createdate BETWEEN '2026-04-25' AND '2026-06-05' --and e.type='Glovo'

select * from #final
order by chequeid

select * from #final f
join Business_Analytic.ecom.ecom_orders e on e.ordernum=f.ordernum
where  e.year=2026 and e.month=5 and (e.chequeid=0 or e.chequeid is null)
order by f.chequeid 
	

select cast(createdate as date), type, count(*) from #final f
group by cast(createdate as date), type
order by cast(createdate as date)

/*select * from #final
where cast(createdate as date) between '2026-02-26' and '2026-02-28'*/


update eo
set eo.chequeid=f.chequeid, eo.filid=f.filid
from Business_Analytic.ecom.ecom_orders eo
join #final f on eo.ordernum=f.ordernum
where eo.year=2026 and eo.month=5 and f.chequeid is not null and f.chequeid <>0

drop table if exists #misses
select eo.*, f.createdate, e.CHEQUEID cheq, e.filid fil, e.type typee into #misses from Business_Analytic.ecom.ecom_orders eo 
join #final f on eo.ordernum=f.ordernum
left join (select distinct chequeid, filid, type from Business_Analytic.ecom.ecom_data
where  created BETWEEN '2026-03-01' and '2026-04-05') e on eo.chequeid=e.chequeid and eo.filid=e.filid
where eo.year=2026 and eo.month=3 and e.chequeid is null

--select * from #misses

------------------ Оновлення ecom_data і перевірка к-сті чеків

UPDATE ed
SET ed.[type] = e.[type]
FROM Business_Analytic.ecom.ecom_data ed
INNER JOIN Business_Analytic.ecom.ecom_orders e
    ON ed.chequeid = e.chequeid and ed.filid = e.filid
WHERE ed.created BETWEEN '2026-04-25' and '2026-06-05'
    AND e.month = 5 AND e.year=2026
    AND ed.[type] = 'Доставка shop.fora.ua'
	--and e.type='Рой'
    AND e.[type] IS NOT NULL
	and e.ChequeID is not null

/*
select type, count(distinct chequeid) [к-сть чеків, вересень] from Business_Analytic.ecom.ecom_data
where created BETWEEN '2026-05-01' and '2026-05-31' --and type in ('ipost', 'uklon')
group by type

select type, count(distinct chequeid) [к-сть чеків, серпень] from Business_Analytic.ecom.ecom_data
where created BETWEEN '2025-12-01' and '2025-12-31' --and type in ('ipost', 'uklon')
group by type
*/

select distinct chequeid, filid [к-сть чеків, вересень] from Business_Analytic.ecom.ecom_data
where created BETWEEN '2026-05-01' and '2026-05-31' and type not in ('Самовывоз shop.fora.ua', 'Glovo')
group by chequeid, filid

select distinct chequeid [к-сть чеків, вересень] from Business_Analytic.ecom.ecom_data
where created BETWEEN '2026-05-01' and '2026-05-31' and type not in ('Самовывоз shop.fora.ua', 'Glovo')
group by chequeid