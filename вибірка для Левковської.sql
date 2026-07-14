/****** Script for SelectTopNRows command from SSMS  ******/			
drop table if exists #one			
drop table if exists #two

declare @year int = 2026
declare @month int = 4
declare @firstday date = datefromparts(@year, @month, '01')
declare @lastday date = eomonth(@firstday)

select @year, @month, @firstday, @lastday

delete from business_analytic.ecom.TO_ecom	
where year=@year and month=@month

delete from Business_analytic.ecom.cheques_info	
where year=@year and month=@month

--треба групувати щоб прибрати відміни позицій в чеках	
SELECT  [filid],[CREATED],[CHEQUEID],[lagerid],[Type], [Тип оплати]      			
	  ,sum([sumout_no_nds]) [sumout_no_nds]		
      ,sum([percent_pereuchot_sumssc_nonds]) [percent_pereuchot_sumssc_nonds]			
      ,sum([percent_spisaniya_sumssc_nonds]) [percent_spisaniya_sumssc_nonds]			
      ,sum([sales_ssc_nonds]) [sales_ssc_nonds]			
	  ,sum([bonus_margin_no_nds]) [bonus_margin_no_nds]		
	  into #one		
  FROM [Business_Analytic].[ecom].[ecom_data]			
  where [CREATED] between @firstday and @lastday			
  group by [filid],[CREATED],[CHEQUEID],[lagerid],[Type],[Тип оплати]			
			

  --по кістках ставимо ручне ссц			
  SELECT [filid],[CREATED],[CHEQUEID],[lagerid],[Type],[Тип оплати]			
		,[sumout_no_nds],[percent_pereuchot_sumssc_nonds],[percent_spisaniya_sumssc_nonds]	
      ,case when (lagerid in (445253,32686,32681,556762,794592,32684) and [sales_ssc_nonds]>[sumout_no_nds]) 			
			then[sumout_no_nds]*0.8 
			else [sales_ssc_nonds] end [sales_ssc_nonds]
		,[bonus_margin_no_nds]	
	--	,[sum_bonus_margin_no_nds]	
  into #two			
  FROM #one			
			
	
INSERT INTO business_analytic.ecom.TO_ecom		
SELECT year(created) [year], month(created) [month], filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter] [MVZ], [Type]			
		,sum([sumout_no_nds]) [Грн_без_пдв]	
		,'ТО_без_пдв' [Показник], [Тип оплати]	
  --INTO business_analytic.ecom.TO_ecom
  FROM #two c			
  left join MasterData.dbo.dim_Filials f on f.[fil.Filials.filialId]=c.filid			
  group by	year(created), month(created), filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter], [Type], [Тип оплати]		
			
      union all			
  SELECT year(created) [year], month(created) [month],filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter] [MVZ], [Type]			
		,sum([sales_ssc_nonds]),	
		'собівартість_без_пдв', [Тип оплати] 	
  FROM #two c			
  left join MasterData.dbo.dim_Filials f on f.[fil.Filials.filialId]=c.filid			
  group by	year(created), month(created),filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter], [Type], [Тип оплати]		
			
  union all			
  SELECT year(created) [year], month(created) [month],filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter] [MVZ], [Type]			
		,sum([percent_pereuchot_sumssc_nonds]),
		'переоблік_без_пдв', [Тип оплати]    	
  FROM #two c			
  left join MasterData.dbo.dim_Filials f on f.[fil.Filials.filialId]=c.filid			
  group by	year(created), month(created),  filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter], [Type], [Тип оплати]		
			
    union all			
  SELECT year(created) [year], month(created) [month], filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter] [MVZ], [Type]			
		,sum([percent_spisaniya_sumssc_nonds]) 	
		,'списання_без_пдв' 	, [Тип оплати]
  FROM #two c			
  left join MasterData.dbo.dim_Filials f on f.[fil.Filials.filialId]=c.filid			
  group by	year(created), month(created), filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter], [Type]	, [Тип оплати]	
  			
    union all			
  SELECT year(created) [year], month(created) [month], filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter] [MVZ], [Type]			
		,sum([bonus_margin_no_nds]) 	
		,'бонуси_договірні_без_пдв' , [Тип оплати]	
  FROM #two c			
  left join MasterData.dbo.dim_Filials f on f.[fil.Filials.filialId]=c.filid			
  group by	year(created), month(created),  filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter], [Type]	, [Тип оплати]
    			

update [Business_Analytic].[ecom].[TO_ecom]
set [Грн_без_пдв]=-[Грн_без_пдв]
where [Показник]='собівартість_без_пдв' and year=@year and month=@month


----- ecom cheques
DROP TABLE IF EXISTS #cheq_stat
;with dat as (
select
        [filid],[CREATED],[CHEQUEID],[lagerid],[Type], [Тип оплати],
        sum(sumout_no_nds) as cheque_sum
    from Business_Analytic.ecom.ecom_data
    where created between @firstday and @lastday
    group by [filid],[CREATED],[CHEQUEID],[lagerid],[Type], [Тип оплати]
),

cheques as (
    select
        chequeid,
        filid,
        type,
        created,
        sum(cheque_sum) as cheque_sum
    from dat
    group by chequeid, filid, type, created
)

select 
    datefromparts(year(created), month(created), 1) as date,
    year(created) year,
    month(created) month,
    filid,
    type,
    count(*) as [Кількість чеків, од.],
    avg(cheque_sum) as [Середній чек, грн]
	into #cheq_stat
from cheques
group by 
    year(created),
    month(created),
    filid,
    type



update c
set c.type='Доставка'
from #cheq_stat c
where c.type='Доставка shop.fora.ua'

update c
set c.type='Самовивіз'
from #cheq_stat c
where c.type='Самовывоз shop.fora.ua'

insert into Business_analytic.ecom.cheques_info
select * from #cheq_stat


drop table if exists #delivery
--треба групувати щоб прибрати відміни позицій в чеках	
SELECT  [filid],[CREATED],[CHEQUEID],[lagerid],
	case when lagerid=933107 then 'Нова пошта' else [Type] end as [type], 
	[Тип оплати]      			
	  ,sum([sumout_no_nds]) [sumout_no_nds]			
	  into #delivery	
  FROM business_analytic.ecom.delivery_data			
  where [CREATED] between @firstday and @lastday			
  group by [filid],[CREATED],[CHEQUEID],[lagerid],case when lagerid=933107 then 'Нова пошта' else [Type] end,[Тип оплати]	
  
  INSERT INTO business_analytic.ecom.TO_ecom		
SELECT year(created) [year], month(created) [month], filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter] [MVZ], [Type]			
		,sum([sumout_no_nds]) [Грн_без_пдв]	
		,'ДохідПослКінцевСпож_без_пдв' [Показник], [Тип оплати]	
  --INTO business_analytic.ecom.TO_ecom
  FROM #delivery c			
  left join MasterData.dbo.dim_Filials f on f.[fil.Filials.filialId]=c.filid			
  group by	year(created), month(created), filid, f.[fil.Filials.filialNameUA],f.[fil.Filials.filialExpenseCenter], [Type], [Тип оплати]		
				

select filid, [fil.Filials.filialNameUA], mvz, type, Грн_без_пдв, Показник, [Тип оплати] from business_analytic.ecom.TO_ecom	
where year=@year and month=@month

