/****** Script for SelectTopNRows command from SSMS  ******/
drop table if exists #to_ecom
drop table if exists #to_ecom_t
drop table if exists #to_ecom_f
drop table if exists #xd
drop table if exists #xd_1
drop table if exists #tmp_f
drop table if exists #bonuses
drop table if exists #bonuses_chan
drop table if exists #bonus_mvz


declare @year int = 2025
declare @month int = 2


SELECT [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ], [type]
      ,sum([Грн_без_пдв]) [Грн_без_пдв]
      ,[Показник]
	  into #to_ecom_t
  FROM [Business_Analytic].[ecom].[TO_ecom] t
  where month=@month and year=@year
  group by [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ], [type]
      ,[Показник]

SELECT [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ]
      ,[Показник],
	  	case when t.type='iPost' then t.Грн_без_пдв else 0 end as [iPost],
	case when t.type='Рой' then t.Грн_без_пдв else 0 end as [Рой],
	case when t.type='Нова пошта' then t.Грн_без_пдв else 0 end as [Нова пошта],
	case when t.type='Uklon' then t.Грн_без_пдв else 0 end as [Uklon],
	case when t.type='Доставка shop.fora.ua' then t.Грн_без_пдв else 0 end as [Доставка shop.fora.ua],
	case when t.type='Самовывоз shop.fora.ua' then t.Грн_без_пдв else 0 end as [Самовывоз shop.fora.ua],
	case when t.type='Glovo' then t.Грн_без_пдв else 0 end as [Glovo]
	  into #to_ecom
  FROM #to_ecom_t t
  where month=@month and year=@year


  select [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ]
      ,[Показник], sum([Glovo]) [Glovo], sum([iPost]) [iPost], sum([Uklon]) [Uklon], sum([Доставка shop.fora.ua]) [Доставка shop.fora.ua], 
	  sum([Самовывоз shop.fora.ua]) [Самовывоз shop.fora.ua], sum([Рой]) [Рой], sum([Нова пошта]) [Нова пошта]
	  into #to_ecom_f
	  FROM #to_ecom
  group by [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ]
      ,[Показник]


	  select year, month, mvz, type, показник, sum(t.[Грн_без_пдв]) [Грн_без_пдв]
	  into #xd
  FROM [Business_Analytic].[ecom].[TO_ecom] t
  left join [Business_Analytic].[ecom].[dovidnyk_statti] s on t.Показник=s.[name_statti]
    left join [Business_Analytic].[ecom].[dovidnyk] d on d.[Код_статті]=s.type_statti
  where  month=@month and year=@year and type_statti=70200000 and [Тип оплати]='Безнал'
  group by year, month, mvz, type, показник

  SELECT [year]
      ,[month]
      ,[MVZ], 
      [Показник],
	  	case when t.type='iPost' then t.Грн_без_пдв else 0 end as [iPost],
	case when t.type='Рой' then t.Грн_без_пдв else 0 end as [Рой],
	case when t.type='Нова пошта' then t.Грн_без_пдв else 0 end as [Нова пошта],
	case when t.type='Uklon' then t.Грн_без_пдв else 0 end as [Uklon],
	case when t.type='Доставка shop.fora.ua' then t.Грн_без_пдв else 0 end as [Доставка shop.fora.ua],
	case when t.type='Самовывоз shop.fora.ua' then t.Грн_без_пдв else 0 end as [Самовывоз shop.fora.ua],
	case when t.type='Glovo' then t.Грн_без_пдв else 0 end as [Glovo]
	into #xd_1
  FROM #xd t


    /*SELECT [year]
      ,[month]
      ,[MVZ], 
      [Показник], sum([Glovo]) [Glovo], sum([iPost]) [iPost], sum([Uklon]) [Uklon], sum([Доставка shop.fora.ua]) [Доставка shop.fora.ua], 
	  sum([Самовывоз shop.fora.ua]) [Самовывоз shop.fora.ua], sum([Рой]) [Рой], sum([Нова пошта]) [Нова пошта]
  FROM #xd_1 t
  group by [year]
      ,[month]
      ,[MVZ], 
      [Показник]*/

select [Міс.вин.п.], 
case when [Стат]='Glovo' then sum([Сума у внут.валюті]) else 0 end as [Glovo],
case when [Стат]='iPost' then sum([Сума у внут.валюті]) else 0 end as [iPost],
case when [Стат]='Uklon' then sum([Сума у внут.валюті]) else 0 end as [Uklon],
case when [Стат]='Доставка shop.fora.ua' then sum([Сума у внут.валюті]) else 0 end as [Доставка shop.fora.ua],
case when [Стат]='Самовывоз shop.fora.ua' then sum([Сума у внут.валюті]) else 0 end as [Самовывоз shop.fora.ua],
case when [Стат]='Рой' then sum([Сума у внут.валюті]) else 0 end as [Рой],
case when [Стат]='Нова пошта' then sum([Сума у внут.валюті]) else 0 end as [Нова пошта]
into #tmp_f
from Business_Analytic.ecom.FAGLL03
where month([Дата док.])=@month and year([Дата док.])=@year
group by [Міс.вин.п.], [Стат]

delete from #tmp_f
where [Міс.вин.п.] in ('20211A2527', '20211I0218', '20211RC014', '20211RC016', '20200A6000', '20210A2529')
/*select a.year, a.month, a.mvz, a.filialname, a.type_vytraty, a.name_vytraty, 
case when v.[Glovo %% в On-line]!=1 then v.[Доля Магазину в ТО On-Line]*b_100.sum_vytraty else 0 end sum_vytraty
into #bonuses
from [Business_Analytic].[ecom].[analyzer_mvz_bonuses] a
left join [Business_Analytic].[ecom].[dovidnyk] d on d.[Код_статті]=a.[type_vytraty] 
left join business_analytic.ecom.vyruchka_final v on a.mvz=v.mvz and a.year=v.year and a.month=v.month
cross join (select sum(sum_vytraty) sum_vytraty from [Business_Analytic].[ecom].[analyzer_mvz_bonuses_100]) b_100
--order by abs(round(a.sum_vytraty - (case when v.[Glovo %% в On-line]!=1 then v.[Доля Магазину в ТО On-Line]*b_100.sum_vytraty else 0 end), 4)) */


select a.year, a.month, a.mvz, a.filialname, a.type_vytraty, a.name_vytraty,
case when iPost+Uklon+[Доставка shop.fora.ua]+[Самовывоз shop.fora.ua]+[Рой]+[Нова пошта]=0 then 0 
else (iPost+Uklon+[Доставка shop.fora.ua]+[Самовывоз shop.fora.ua]+[Рой]+[Нова пошта])/(select sum(iPost)+sum(Uklon)+sum([Доставка shop.fora.ua])+sum([Самовывоз shop.fora.ua])+sum([Рой])+sum([Нова пошта])
from business_analytic.ecom.vyruchka_final where month=@month and year=@year) end [Доля кожного Магазину БЕЗ Glovo],
case when iPost+Uklon+[Доставка shop.fora.ua]+[Самовывоз shop.fora.ua]+[Рой]+[Нова пошта]=0 then 0 
else (iPost+Uklon+[Доставка shop.fora.ua]+[Самовывоз shop.fora.ua]+[Рой]+[Нова пошта])/(select sum(iPost)+sum(Uklon)+sum([Доставка shop.fora.ua])+sum([Самовывоз shop.fora.ua])+sum([Рой])+sum([Нова пошта])
from business_analytic.ecom.vyruchka_final where month=@month and year=@year)*s.sum_vytraty end as sum_vytraty_auto
into #bonus_mvz
from business_analytic.ecom.analyzer_mvz_bonuses_100 a
left join business_analytic.ecom.vyruchka_final v on a.mvz=v.mvz and a.year=v.year and a.month=v.month
left join business_analytic.ecom.sap_info s on a.year=s.year and a.month=s.month
where s.type_vytraty=719007 and a.month=@month and a.year=@year



/*update b
set sum_vytraty=0
from business_analytic.ecom.analyzer_mvz_fop b
where month=@month

update b
set sum_vytraty=0
from business_analytic.ecom.analyzer_mvz_fop_office b
where month=@month*/

	UPDATE a
	SET a.sum_vytraty = isnull(b.[Доля Магазину в ТО On-Line], 0)*s.sum_vytraty
	FROM business_analytic.ecom.analyzer_mvz_fop_office a
	LEFT JOIN business_analytic.ecom.vyruchka_final b 
		ON b.mvz = a.mvz 
	   AND b.year = a.year 
	   AND b.month = a.month
	left join business_analytic.ecom.sap_info s on a.year=s.year and a.month=s.month and  s.month=@month and s.year=@year;
	

	UPDATE a
	SET a.sum_vytraty = b.sum_vytraty_auto
	FROM business_analytic.ecom.analyzer_mvz_bonuses_100 a
	LEFT JOIN #bonus_mvz b 
		ON b.mvz = a.mvz 
	   AND b.year = a.year 
	   AND b.month = a.month  and b.month=@month and b.year=@year;

	   /*select month, name_vytraty, count(*) from  [Business_Analytic].[ecom].[analyzer_mvz]
	   where name_vytraty in ('Бонус Е-СОМ', 'ФОП ОФІСУ', 'ФОП збірників')
	   group by month, name_vytraty
	   order by  month*/

delete from [Business_Analytic].[ecom].[analyzer_mvz]
where name_vytraty='Бонус Е-СОМ' and year=@year and month=@month

insert into [Business_Analytic].[ecom].[analyzer_mvz]
select * from [Business_Analytic].[ecom].[analyzer_mvz_bonuses_100]
where year=@year and month=@month

delete from [Business_Analytic].[ecom].[analyzer_mvz]
where name_vytraty='ФОП ОФІСУ' and year=@year and month=@month

insert into [Business_Analytic].[ecom].[analyzer_mvz]
select * from  business_analytic.ecom.analyzer_mvz_fop_office
where year=@year and month=@month

delete from [Business_Analytic].[ecom].[analyzer_mvz]
where name_vytraty='ФОП збірників' and year=@year and month=@month

insert into [Business_Analytic].[ecom].[analyzer_mvz]
select * from  business_analytic.ecom.analyzer_mvz_fop
where year=@year and month=@month

select a.*,
0 [Glovo],
case when name_vytraty='Бонус Е-СОМ' then 
	(case when isnull(v.[Glovo], 0)=isnull(v.[iPost] , 0) then 0 
	else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 
		else  isnull(v.[iPost], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end) end [iPost],
case when name_vytraty='Бонус Е-СОМ' then 
	(case when isnull(v.[Glovo], 0)=isnull(v.[Uklon] , 0) then 0 
	else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 
		else  isnull(v.[Uklon], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end) end [Uklon],
case when name_vytraty='Бонус Е-СОМ' then 
	(case when isnull(v.[Glovo], 0)=isnull(v.[Доставка shop.fora.ua] , 0) then 0 
	else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 
		else  isnull(v.[Доставка shop.fora.ua], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end) end [Доставка shop.fora.ua],
case when name_vytraty='Бонус Е-СОМ' then 
	(case when isnull(v.[Glovo], 0)=isnull(v.[Самовывоз shop.fora.ua] , 0) then 0 
	else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 
		else  isnull(v.[Самовывоз shop.fora.ua], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end) end [Самовывоз shop.fora.ua],
case when name_vytraty='Бонус Е-СОМ' then 
	(case when isnull(v.[Glovo], 0)=isnull(v.[Рой] , 0) then 0 
	else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 
		else  isnull(v.[Рой], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end) end [Рой],
case when name_vytraty='Бонус Е-СОМ' then 
	(case when isnull(v.[Glovo], 0)=isnull(v.[Нова пошта] , 0) then 0 
	else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 
		else  isnull(v.[Нова пошта], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end) end [Нова пошта]
		into #bonuses_chan
from [Business_Analytic].[ecom].[analyzer_mvz_bonuses_100] a
left join business_analytic.ecom.vyruchka_final v on a.mvz=v.mvz and a.year=v.year and a.month=v.month




delete from [Business_Analytic].[ecom].[analyzer_mvz_final]
where year=@year and month=@month

insert into [Business_Analytic].[ecom].[analyzer_mvz_final]
SELECT a.*,d.*,t.Показник, 
case when d.Розрахунок='Міша' then t.[Glovo]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Glovo %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' then 0
when d.Розрахунок='FAGLL03' then -ff.[Glovo] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Glovo %% в On-line]
	--then (a.sum_vytraty-isnull(fop.sum_vytraty, 0))*[Доля On-line в ТО Магазину]*[Glovo %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Glovo %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Glovo %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[Glovo], 0)*1.185*0.01 else 0 end as [Glovo_final],

case when d.Розрахунок='Міша' then t.[iPost]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[iPost %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[iPost], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[iPost], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.iPost 
when d.Розрахунок='FAGLL03' then -ff.[iPost] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[iPost %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[iPost %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[iPost %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[iPost], 0)*1.185*0.01 else 0 end as [iPost_final],

case when d.Розрахунок='Міша' then t.[Uklon]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Uklon %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Uklon], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Uklon], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end)end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.Uklon 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Uklon %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Uklon %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Uklon %% в On-line]
when d.Розрахунок='FAGLL03' then -ff.[Uklon] 
when d.Розрахунок='ФОТ'then (a.sum_vytraty-isnull(fop.sum_vytraty, 0))*[Доля On-line в ТО Магазину]*[Uklon %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[Uklon], 0)*1.185*0.01 else 0 end as [Uklon_final],

case when d.Розрахунок='Міша' then t.[Доставка shop.fora.ua]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Доставка shop.fora.ua %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Доставка shop.fora.ua], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Доставка shop.fora.ua], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.[Доставка shop.fora.ua] 
when d.Розрахунок='Доставка' then isnull(a.sum_vytraty, 0)-isnull(t.[Нова пошта], 0) 
when d.Розрахунок='FAGLL03' then -ff.[Доставка shop.fora.ua] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Доставка shop.fora.ua %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Доставка shop.fora.ua %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Доставка shop.fora.ua %% в On-line]when d.Розрахунок='РКО' then isnull(rko.[Доставка shop.fora.ua], 0)*1.185*0.01 else 0 end as [Доставка shop.fora.ua_final],

case when d.Розрахунок='Міша' then t.[Самовывоз shop.fora.ua]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Самовывоз shop.fora.ua %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Самовывоз shop.fora.ua], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Самовывоз shop.fora.ua], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.[Самовывоз shop.fora.ua]
when d.Розрахунок='FAGLL03' then -ff.[Самовывоз shop.fora.ua] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Самовывоз shop.fora.ua %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Самовывоз shop.fora.ua %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Самовывоз shop.fora.ua %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[Самовывоз shop.fora.ua], 0)*1.185*0.01 else 0 end as [Самовывоз shop.fora.ua_final],

case when d.Розрахунок='Міша' then t.[Рой]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Рой %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта]
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Рой], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Рой], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.[Рой] 
when d.Розрахунок='FAGLL03' then -ff.[Рой] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Рой %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Рой %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Рой %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[Рой], 0)*1.185*0.01 else 0 end as [Рой_final],

case when d.Розрахунок='Міша' then t.[Нова пошта]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Нова пошта %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Нова пошта], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Нова пошта], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.[Нова пошта] 
when d.Розрахунок='FAGLL03' then -ff.[Нова пошта] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Нова пошта %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Нова пошта %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Нова пошта %% в On-line]when d.Розрахунок='РКО' then isnull(rko.[Нова пошта], 0)*1.185*0.01 else 0 end as [Нова пошта_final],

(case when d.Розрахунок='Міша' then t.[Glovo]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Glovo %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' then 0
when d.Розрахунок='FAGLL03' then -ff.[Glovo] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Glovo %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Glovo %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Glovo %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[Glovo], 0)*1.185*0.01 else 0 end +

case when d.Розрахунок='Міша' then t.[iPost]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[iPost %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[iPost], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[iPost], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.iPost 
when d.Розрахунок='FAGLL03' then -ff.[iPost] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[iPost %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[iPost %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[iPost %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[iPost], 0)*1.185*0.01 else 0 end +

case when d.Розрахунок='Міша' then t.[Uklon]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Uklon %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Uklon], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Uklon], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end)end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.Uklon 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Uklon %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Uklon %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Uklon %% в On-line]
when d.Розрахунок='FAGLL03' then -ff.[Uklon] 
when d.Розрахунок='ФОТ'then (a.sum_vytraty-isnull(fop.sum_vytraty, 0))*[Доля On-line в ТО Магазину]*[Uklon %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[Uklon], 0)*1.185*0.01 else 0 end +

case when d.Розрахунок='Міша' then t.[Доставка shop.fora.ua]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Доставка shop.fora.ua %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Доставка shop.fora.ua], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Доставка shop.fora.ua], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.[Доставка shop.fora.ua] 
when d.Розрахунок='Доставка' then isnull(a.sum_vytraty, 0)-isnull(t.[Нова пошта], 0) 
when d.Розрахунок='FAGLL03' then -ff.[Доставка shop.fora.ua] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Доставка shop.fora.ua %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Доставка shop.fora.ua %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Доставка shop.fora.ua %% в On-line]when d.Розрахунок='РКО' then isnull(rko.[Доставка shop.fora.ua], 0)*1.185*0.01 else 0 end +

case when d.Розрахунок='Міша' then t.[Самовывоз shop.fora.ua]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Самовывоз shop.fora.ua %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Самовывоз shop.fora.ua], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Самовывоз shop.fora.ua], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.[Самовывоз shop.fora.ua]
when d.Розрахунок='FAGLL03' then -ff.[Самовывоз shop.fora.ua] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Самовывоз shop.fora.ua %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Самовывоз shop.fora.ua %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Самовывоз shop.fora.ua %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[Самовывоз shop.fora.ua], 0)*1.185*0.01 else 0 end +

case when d.Розрахунок='Міша' then t.[Рой]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Рой %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта]
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Рой], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Рой], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.[Рой] 
when d.Розрахунок='FAGLL03' then -ff.[Рой] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Рой %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Рой %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Рой %% в On-line]
when d.Розрахунок='РКО' then isnull(rko.[Рой], 0)*1.185*0.01 else 0 end +

case when d.Розрахунок='Міша' then t.[Нова пошта]
when d.Розрахунок='%% від ТО' then a.sum_vytraty*[Нова пошта %% в On-line]*[Доля On-line в ТО Магазину]
when d.Розрахунок='НІ' then 0 
--when d.Розрахунок='Доставка' then a.sum_vytraty-t.[Нова пошта] 
when d.Розрахунок='100%' and a.name_vytraty ='МаркетКурєрсДостав'
	then (case when isnull(v.[Glovo], 0)=isnull(v.[Нова пошта], 0) then 0 
			else (case when isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0)=0 then 0 else  isnull(v.[Нова пошта], 0)/(isnull(v.[ТО_всього], 0)-isnull(v.Glovo, 0))*a.sum_vytraty end) end)
when d.Розрахунок='100%' and a.name_vytraty='Бонус Е-СОМ' then bc.[Нова пошта] 
when d.Розрахунок='FAGLL03' then -ff.[Нова пошта] 
when d.Розрахунок='ФОТ' and a.type_vytraty not in (811000, 811001) 
	then (a.sum_vytraty-0)*[Доля On-line в ТО Магазину]*[Нова пошта %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811000 then isnull(fop.sum_vytraty, 0)*[Нова пошта %% в On-line]
when d.Розрахунок='ФОТ' and a.type_vytraty=811001 then isnull(fop_of.sum_vytraty, 0)*[Нова пошта %% в On-line]when d.Розрахунок='РКО' then isnull(rko.[Нова пошта], 0)*1.185*0.01 else 0 end
) as [Всього] ,
	  [Glovo %% в On-line], [iPost %% в On-line],  [Uklon %% в On-line],   [Доставка shop.fora.ua %% в On-line],  
[Самовывоз shop.fora.ua %% в On-line],  [Рой %% в On-line],  [Нова пошта %% в On-line], [Доля On-line в ТО Магазину],[Доля Магазину в ТО On-Line]
	--into [Business_Analytic].[ecom].[analyzer_mvz_final]
  FROM [Business_Analytic].[ecom].[analyzer_mvz] a
  left join [Business_Analytic].[ecom].[dovidnyk] d on d.[Код_статті]=a.[type_vytraty] 
  left join [Business_Analytic].[ecom].[dovidnyk_statti] s on s.type_statti=a.[type_vytraty] 
  left join #to_ecom_f t on a.mvz=t.mvz and a.year=t.year and a.month=t.month and t.Показник=s.[name_statti]
  left join business_analytic.ecom.vyruchka_final v on a.mvz=v.mvz and a.year=v.year and a.month=v.month
  left join (    SELECT [year]
      ,[month]
      ,[MVZ], 
      [Показник], -sum([Glovo]) [Glovo], -sum([iPost]) [iPost], -sum([Uklon]) [Uklon], -sum([Доставка shop.fora.ua]) [Доставка shop.fora.ua], 
	  -sum([Самовывоз shop.fora.ua]) [Самовывоз shop.fora.ua], -sum([Рой]) [Рой], -sum([Нова пошта]) [Нова пошта]
  FROM #xd_1 t
  group by [year]
      ,[month]
      ,[MVZ], 
      [Показник]) rko on a.mvz=rko.mvz and a.year=rko.year and a.month=rko.month
  left join (
	  select year, month, mvz, type_vytraty, d.Розрахунок, [Меппінг], name_vytraty, sum(sum_vytraty) sum_vytraty FROM [Business_Analytic].[ecom].[analyzer_mvz_fop] a
		left join [Business_Analytic].[ecom].[dovidnyk] d on d.[Код_статті]=a.[type_vytraty] 
	  where d.Розрахунок='ФОТ' 
	  group by year, month, mvz, type_vytraty, d.Розрахунок, [Меппінг], name_vytraty) fop on a.mvz=fop.mvz and a.year=fop.year and a.month=fop.month

	  left join (
	  select year, month, mvz, type_vytraty, d.Розрахунок, [Меппінг], name_vytraty, sum(sum_vytraty) sum_vytraty FROM [Business_Analytic].[ecom].[analyzer_mvz_fop_office] a
		left join [Business_Analytic].[ecom].[dovidnyk] d on d.[Код_статті]=a.[type_vytraty] 
	  where d.Розрахунок='ФОТ'
	  group by year, month, mvz, type_vytraty, d.Розрахунок, [Меппінг], name_vytraty) fop_of on a.mvz=fop_of.mvz and a.year=fop_of.year and a.month=fop_of.month

  left join (select [Міс.вин.п.], sum([Glovo]) [Glovo]
, sum([iPost]) [iPost], sum([Uklon]) [Uklon], sum([Доставка shop.fora.ua]) [Доставка shop.fora.ua], 
sum([Самовывоз shop.fora.ua]) [Самовывоз shop.fora.ua], sum([Рой]) [Рой], sum([Нова пошта]) [Нова пошта]
from #tmp_f
group by [Міс.вин.п.]) ff on ff.[Міс.вин.п.]=a.mvz
	left join #bonuses_chan bc on a.mvz=bc.mvz and a.year=bc.year and a.month=bc.month
  where a.month=@month and a.year=@year --and a.mvz='2021108200' --and [name_vytraty] in ('СобівРеалТоварВироб', 'СобівартРеалізТовар')


/*
  SELECT [year]
      ,[month]
      ,[MVZ], 
      [Показник], -sum([Glovo])*1.185*0.01 [Glovo], sum([iPost]) [iPost], sum([Uklon]) [Uklon], sum([Доставка shop.fora.ua]) [Доставка shop.fora.ua], 
	  sum([Самовывоз shop.fora.ua]) [Самовывоз shop.fora.ua], sum([Рой]) [Рой], sum([Нова пошта]) [Нова пошта]
  FROM #xd_1 t
  where mvz='2021100100' and month=5
  group by [year]
      ,[month]
      ,[MVZ], 
      [Показник]

	  select * from [Business_Analytic].[ecom].[analyzer_mvz_final]

  select year, month, mvz, type, показник, sum(t.[Грн_без_пдв])
  FROM [Business_Analytic].[ecom].[TO_ecom] t
  left join [Business_Analytic].[ecom].[dovidnyk_statti] s on t.Показник=s.[name_statti]
    left join [Business_Analytic].[ecom].[dovidnyk] d on d.[Код_статті]=s.type_statti
  where month=5 and type_statti=70200000 and [Тип оплати]='Безнал'
  group by year, month, mvz, type, показник

  	  update [Business_Analytic].[ecom].[analyzer_mvz_final]
	  set [Glovo_final]=0
	  where [Glovo_final] is null

	  update [Business_Analytic].[ecom].[analyzer_mvz_final]
	  set [iPost_final]=0
	  where [iPost_final] is null

	  update [Business_Analytic].[ecom].[analyzer_mvz_final]
	  set [Uklon_final]=0
	  where [Uklon_final] is null

	  update [Business_Analytic].[ecom].[analyzer_mvz_final]
	  set [Доставка shop.fora.ua_final]=0
	  where [Доставка shop.fora.ua_final] is null

	  update [Business_Analytic].[ecom].[analyzer_mvz_final]
	  set [Самовывоз shop.fora.ua_final]=0
	  where [Самовывоз shop.fora.ua_final] is null

	  update [Business_Analytic].[ecom].[analyzer_mvz_final]
	  set [Рой_final]=0
	  where [Рой_final] is null

	  update [Business_Analytic].[ecom].[analyzer_mvz_final]
	  set [Нова пошта_final]=0
	  where [Нова пошта_final] is null


	  select cv.*, a.year, a.month, a.[Признак_EBITDA], a.[Меппінг], a.Glovo+a.[iPost]+a.[Uklon]+a.[Доставка shop.fora.ua]+
	  a.[Самовывоз shop.fora.ua]+a.[Рой]+a.[Нова пошта] [ON-LINE],
	  a.Glovo Glovo, a.[iPost] [iPost], a.[Uklon] [Uklon], a.[Доставка shop.fora.ua] [Доставка shop.fora.ua],
	  a.[Самовывоз shop.fora.ua] [Самовывоз shop.fora.ua], a.[Рой] [Рой], a.[Нова пошта] [Нова пошта]
	  from (select year, month, [Признак_EBITDA], Розрахунок, type_vytraty, [Меппінг],sum(Glovo_final) Glovo,
	  sum([iPost_final]) [iPost], sum([Uklon_final]) [Uklon], sum([Доставка shop.fora.ua_final]) [Доставка shop.fora.ua], 
	  sum([Самовывоз shop.fora.ua_final]) [Самовывоз shop.fora.ua], sum([Рой_final]) [Рой], sum([Нова пошта_final]) [Нова пошта]
	  from [Business_Analytic].[ecom].[analyzer_mvz_final]
	  where month=7
	  group by year, month, [Признак_EBITDA], Розрахунок, type_vytraty, [Меппінг]) a
	  right join business_analytic.ecom.channel_vytraty cv on cv.[Розрахунок]=a.[Розрахунок] and cv.type_statti=a.type_vytraty
	  --where [Меппінг] in ('Матеріали', 'Маркетинг', 'РКО', 'Інші - Доходи')
	  order by type_statti


	  select a.[Признак_EBITDA], a.[Меппінг], sum(a.Glovo)+sum(a.[iPost])+sum(a.[Uklon])+sum(a.[Доставка shop.fora.ua])+
	  sum(a.[Самовывоз shop.fora.ua])+sum(a.[Рой])+sum(a.[Нова пошта]) [ON-LINE],
	  
	  sum(a.Glovo) Glovo, sum(a.[iPost]) iPost, sum(a.[Uklon]) [Uklon], sum(a.[Доставка shop.fora.ua]) [Доставка shop.fora.ua],
	  sum(a.[Самовывоз shop.fora.ua]) [Самовывоз shop.fora.ua], sum(a.[Рой]) [Рой], sum(a.[Нова пошта]) [Нова пошта]
	  from (select Розрахунок, [Признак_EBITDA], type_vytraty, [Меппінг],sum(Glovo_final) Glovo,
	  sum([iPost_final]) [iPost], sum([Uklon_final]) [Uklon], sum([Доставка shop.fora.ua_final]) [Доставка shop.fora.ua], 
	  sum([Самовывоз shop.fora.ua_final]) [Самовывоз shop.fora.ua], sum([Рой_final]) [Рой], sum([Нова пошта_final]) [Нова пошта]
	  from [Business_Analytic].[ecom].[analyzer_mvz_final]
	  where month=1
	  group by Розрахунок, [Признак_EBITDA], type_vytraty, [Меппінг]) a
	  right join business_analytic.ecom.channel_vytraty cv on cv.[Розрахунок]=a.[Розрахунок] and cv.type_statti=a.type_vytraty
	  group by a.[Признак_EBITDA], [Меппінг]
	  order by [Меппінг]


	  select a.*, a.sum_vytraty*[Glovo %% в On-line] Glovo, a.sum_vytraty*[iPost %% в On-line] iPost,  
	  a.sum_vytraty*[Uklon %% в On-line] [Uklon],   a.sum_vytraty*[Доставка shop.fora.ua %% в On-line] [Доставка shop.fora.ua],  
a.sum_vytraty*[Самовывоз shop.fora.ua %% в On-line] [Самовывоз shop.fora.ua],  a.sum_vytraty*[Рой %% в On-line] [Рой],  
a.sum_vytraty*[Нова пошта %% в On-line] [Нова пошта],

a.sum_vytraty*[Glovo %% в On-line] + a.sum_vytraty*[iPost %% в On-line] +  
	  a.sum_vytraty*[Uklon %% в On-line] +   a.sum_vytraty*[Доставка shop.fora.ua %% в On-line] +  
a.sum_vytraty*[Самовывоз shop.fora.ua %% в On-line] + a.sum_vytraty*[Рой %% в On-line] +  
a.sum_vytraty*[Нова пошта %% в On-line] [Всього]

from business_analytic.ecom.analyzer_mvz_fop_office a
	  left join business_analytic.ecom.vyruchka_final v on a.mvz=v.mvz and a.year=v.year and a.month=v.month


select a.*, a.sum_vytraty*[Glovo %% в On-line] Glovo, a.sum_vytraty*[iPost %% в On-line] iPost,  
a.sum_vytraty*[Uklon %% в On-line] [Uklon],   a.sum_vytraty*[Доставка shop.fora.ua %% в On-line] [Доставка shop.fora.ua],  
a.sum_vytraty*[Самовывоз shop.fora.ua %% в On-line] [Самовывоз shop.fora.ua],  a.sum_vytraty*[Рой %% в On-line] [Рой],  
a.sum_vytraty*[Нова пошта %% в On-line] [Нова пошта],

a.sum_vytraty*[Glovo %% в On-line] + a.sum_vytraty*[iPost %% в On-line] +  
	  a.sum_vytraty*[Uklon %% в On-line] +   a.sum_vytraty*[Доставка shop.fora.ua %% в On-line] +  
a.sum_vytraty*[Самовывоз shop.fora.ua %% в On-line] + a.sum_vytraty*[Рой %% в On-line] +  
a.sum_vytraty*[Нова пошта %% в On-line] [Всього]

from business_analytic.ecom.analyzer_mvz_fop a
	  left join business_analytic.ecom.vyruchka_final v on a.mvz=v.mvz and a.year=v.year and a.month=v.month

	 select * from [Business_Analytic].[ecom].[analyzer_mvz_final]
	 where [Меппінг]=null

	 select * from  business_analytic.ecom.analyzer_mvz_fop_office
	 
	 select a.year, a.month, a.mvz, a.filialname, a.type_vytraty, a.name_vytraty,
	 case when iPost+Uklon+[Доставка shop.fora.ua]+[Самовывоз shop.fora.ua]+[Рой]+[Нова пошта]=0 then 0 
		else (iPost+Uklon+[Доставка shop.fora.ua]+[Самовывоз shop.fora.ua]+[Рой]+[Нова пошта])/(select sum(iPost)+sum(Uklon)+sum([Доставка shop.fora.ua])+sum([Самовывоз shop.fora.ua])+sum([Рой])+sum([Нова пошта])
		from business_analytic.ecom.vyruchka_final) end [Доля кожного Магазину БЕЗ Glovo],
		case when iPost+Uklon+[Доставка shop.fora.ua]+[Самовывоз shop.fora.ua]+[Рой]+[Нова пошта]=0 then 0 
		else (iPost+Uklon+[Доставка shop.fora.ua]+[Самовывоз shop.fora.ua]+[Рой]+[Нова пошта])/(select sum(iPost)+sum(Uklon)+sum([Доставка shop.fora.ua])+sum([Самовывоз shop.fora.ua])+sum([Рой])+sum([Нова пошта])
		from business_analytic.ecom.vyruchka_final)*s.sum_vytraty end as sum_vytraty_auto
		into #bouns_mvz
		from business_analytic.ecom.analyzer_mvz_bonuses_100 a
	 left join business_analytic.ecom.vyruchka_final v on a.mvz=v.mvz and a.year=v.year and a.month=v.month
	 left join business_analytic.ecom.sap_info s on a.year=s.year and a.month=s.month
	 where s.type_vytraty=719007


	UPDATE a
	SET a.sum_vytraty = isnull(b.[Доля Магазину в ТО On-Line], 0)*s.sum_vytraty
	FROM business_analytic.ecom.analyzer_mvz_fop_office a
	LEFT JOIN business_analytic.ecom.vyruchka_final b 
		ON b.mvz = a.mvz 
	   AND b.year = a.year 
	   AND b.month = a.month
	left join business_analytic.ecom.sap_info s on a.year=s.year and a.month=s.month;
	

	UPDATE a
	SET a.sum_vytraty = b.sum_vytraty_auto
	FROM business_analytic.ecom.analyzer_mvz_bonuses_100 a
	LEFT JOIN #bouns_mvz b 
		ON b.mvz = a.mvz 
	   AND b.year = a.year 
	   AND b.month = a.month;

	   select  sum([Всього]) [Всього], 
	   sum(Glovo_final)+sum([iPost_final])+sum([Uklon_final])+sum([Доставка shop.fora.ua_final])+
	  sum([Самовывоз shop.fora.ua_final])+sum([Рой_final])+sum([Нова пошта_final]) [ON-LINE],
	   sum([Glovo_final]) [Glovo], sum([iPost_final]) [iPost], sum([Uklon_final]) [Uklon], 
	   sum([Доставка shop.fora.ua_final]) [Доставка shop.fora.ua], sum([Самовывоз shop.fora.ua_final]) [Самовывоз shop.fora.ua], 
	   sum([Рой_final]) [Рой], sum([Нова пошта_final]) [Нова пошта] 
	   from [Business_Analytic].[ecom].[analyzer_mvz_final]
	   order by mvz, filialname
	
	select distinct [меппінг], [Признак_Ebitda], [Розрахунок], [Код_статті], [type_vytraty], [name_vytraty] from [Business_Analytic].[ecom].[analyzer_mvz_final]
	order by [Меппінг]

		select a.year, a.month, a.[Признак_EBITDA], a.[Меппінг], sum(a.Glovo)+sum(a.[iPost])+sum(a.[Uklon])+sum(a.[Доставка shop.fora.ua])+
	  sum(a.[Самовывоз shop.fora.ua])+sum(a.[Рой])+sum(a.[Нова пошта]) [ON-LINE], sum([Всього]) [Всього], 
	  
	  sum(a.Glovo) Glovo, sum(a.[iPost]) iPost, sum(a.[Uklon]) [Uklon], sum(a.[Доставка shop.fora.ua]) [Доставка shop.fora.ua],
	  sum(a.[Самовывоз shop.fora.ua]) [Самовывоз shop.fora.ua], sum(a.[Рой]) [Рой], sum(a.[Нова пошта]) [Нова пошта]
	  from (select year, month, Розрахунок, [Признак_EBITDA], type_vytraty, [Меппінг],sum(Glovo_final) Glovo,
	  sum([iPost_final]) [iPost], sum([Uklon_final]) [Uklon], sum([Доставка shop.fora.ua_final]) [Доставка shop.fora.ua], 
	  sum([Самовывоз shop.fora.ua_final]) [Самовывоз shop.fora.ua], sum([Рой_final]) [Рой], sum([Нова пошта_final]) [Нова пошта]
	  from [Business_Analytic].[ecom].[analyzer_mvz_final]
	  where month=4
	  group by year, month, Розрахунок, [Признак_EBITDA], type_vytraty, [Меппінг]) a
	  right join business_analytic.ecom.channel_vytraty cv on cv.[Розрахунок]=a.[Розрахунок] and cv.type_statti=a.type_vytraty
	  group by a.year, a.month, a.[Признак_EBITDA], [Меппінг]
	  order by [Меппінг]

	  	select a.year, a.month, a.[Признак_EBITDA], a.[Меппінг], sum(a.Glovo)+sum(a.[iPost])+sum(a.[Uklon])+sum(a.[Доставка shop.fora.ua])+
	  sum(a.[Самовывоз shop.fora.ua])+sum(a.[Рой])+sum(a.[Нова пошта]) [ON-LINE],
	  
	  sum(a.Glovo) Glovo, sum(a.[iPost]) iPost, sum(a.[Uklon]) [Uklon], sum(a.[Доставка shop.fora.ua]) [Доставка shop.fora.ua],
	  sum(a.[Самовывоз shop.fora.ua]) [Самовывоз shop.fora.ua], sum(a.[Рой]) [Рой], sum(a.[Нова пошта]) [Нова пошта]
	  from (select year, month, Розрахунок, [Признак_EBITDA], type_vytraty, [Меппінг],sum(Glovo_final) Glovo,
	  sum([iPost_final]) [iPost], sum([Uklon_final]) [Uklon], sum([Доставка shop.fora.ua_final]) [Доставка shop.fora.ua], 
	  sum([Самовывоз shop.fora.ua_final]) [Самовывоз shop.fora.ua], sum([Рой_final]) [Рой], sum([Нова пошта_final]) [Нова пошта]
	  from [Business_Analytic].[ecom].[analyzer_mvz_final]
	  group by year, month, Розрахунок, [Признак_EBITDA], type_vytraty, [Меппінг]) a
	  right join business_analytic.ecom.channel_vytraty cv on cv.[Розрахунок]=a.[Розрахунок] and cv.type_statti=a.type_vytraty
	  group by a.year, a.month, a.[Признак_EBITDA], [Меппінг]


	  select * from business_analytic.ecom.vyruchka_final*/

