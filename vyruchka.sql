drop table if exists #to_ecom
drop table if exists #to_ecom_t
drop table if exists #to_ecom_f
drop table if exists #temp_vyr
drop table if exists #tmp_f

declare @year int = 2026
declare @month int = 4

SELECT [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ], [type],[Показник]
      ,sum([Грн_без_пдв]) [Грн_без_пдв]
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


select v.*, t.[Glovo],t.[iPost],t.[Uklon],t.[Доставка shop.fora.ua], 
	  t.[Самовывоз shop.fora.ua], t.[Рой],t.[Нова пошта],

	  /*case when v.sum_vytraty=0 then 0 else t.[Glovo]/v.sum_vytraty end as [Glovo %% в On-line],
	  case when v.sum_vytraty=0 then 0 else t.[iPost]/v.sum_vytraty end as [iPost %% в On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Uklon]/v.sum_vytraty end as [Uklon %% в On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Доставка shop.fora.ua]/v.sum_vytraty end as [Доставка shop.fora.ua %% в On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Самовывоз shop.fora.ua]/v.sum_vytraty end as [Самовывоз shop.fora.ua %% в On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Рой]/v.sum_vytraty end as [Рой %% в On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Нова пошта]/v.sum_vytraty end as [Нова пошта %% в On-line],*/
	  tt.[Glovo] [Glovo_соб],tt.[iPost] [iPost_соб],tt.[Uklon] [Uklon_соб],tt.[Доставка shop.fora.ua] [Доставка shop.fora.ua_соб], 
	  tt.[Самовывоз shop.fora.ua] [Самовывоз shop.fora.ua_соб], tt.[Рой] [Рой_соб],tt.[Нова пошта] [Нова пошта_соб],

	   t.[Glovo]+t.[iPost]+t.[Uklon]+t.[Доставка shop.fora.ua]+ 
	  t.[Самовывоз shop.fora.ua]+t.[Рой]+t.[Нова пошта] [ТО_всього],

	  tt.[Glovo]+tt.[iPost]+tt.[Uklon]+tt.[Доставка shop.fora.ua]+ 
	  tt.[Самовывоз shop.fora.ua]+tt.[Рой]+tt.[Нова пошта] [Собівартість_всього],

	  t.[Glovo]+t.[iPost]+t.[Uklon]+t.[Доставка shop.fora.ua]+ 
	  t.[Самовывоз shop.fora.ua]+t.[Рой]+t.[Нова пошта] + 
	  tt.[Glovo]+tt.[iPost]+tt.[Uklon]+tt.[Доставка shop.fora.ua]+ 
	  tt.[Самовывоз shop.fora.ua]+tt.[Рой]+tt.[Нова пошта] [Фронт_маржа]
	  into #temp_vyr
	  from business_analytic.ecom.vyruchka v
left join #to_ecom_f t on t.mvz=v.mvz and t.year=v.year and t.month=v.month and [Показник]='ТО_без_пдв'
left join #to_ecom_f tt on tt.mvz=v.mvz and tt.year=v.year and tt.month=v.month and tt.[Показник]='собівартість_без_пдв'
where v.month=@month and v.year=@year

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



delete from business_analytic.ecom.vyruchka_final
where year=@year and month=@month


insert into business_analytic.ecom.vyruchka_final
select t.*, 
case when t.[ТО_всього]=0 then 0 else t.[Glovo]/t.[ТО_всього] end as [Glovo %% в On-line], 
case when t.[ТО_всього]=0 then 0 else t.[iPost]/t.[ТО_всього] end as [iPost %% в On-line],  
case when t.[ТО_всього]=0 then 0 else t.[Uklon]/t.[ТО_всього] end as [Uklon %% в On-line],  
case when t.[ТО_всього]=0 then 0 else t.[Доставка shop.fora.ua]/t.[ТО_всього] end as [Доставка shop.fora.ua %% в On-line],  
case when t.[ТО_всього]=0 then 0 else t.[Самовывоз shop.fora.ua]/t.[ТО_всього] end as [Самовывоз shop.fora.ua %% в On-line],  
case when t.[ТО_всього]=0 then 0 else t.[Рой]/t.[ТО_всього] end as [Рой %% в On-line],  
case when t.[ТО_всього]=0 then 0 else t.[Нова пошта]/t.[ТО_всього] end as [Нова пошта %% в On-line], 

case when t.[sum_vytraty]=0 then 0 else t.[ТО_всього]/t.[sum_vytraty] end as [Доля On-line в ТО Магазину],
case when t.[sum_vytraty]=0 then 0 else t.[ТО_всього]/ss.[ТО_всього] end as [Доля Магазину в ТО On-Line],
[Сума у внут.валюті] [Кур'єрДоставПосилок On-line ВСЬОГО],
 ff.[Glovo] [Glovo_кур], ff.[iPost] [iPost_кур], ff.[Uklon] [Uklon_кур], ff.[Доставка shop.fora.ua] [Доставка shop.fora.ua_кур], 
	  ff.[Самовывоз shop.fora.ua] [Самовывоз shop.fora.ua_кур], ff.[Рой] [Рой_кур], ff.[Нова пошта] [Нова пошта_кур]
from #temp_vyr t
cross join (select sum(sum_vytraty) sum_vytraty from business_analytic.ecom.vyruchka where month=@month and year=@year) s
cross join (select sum([ТО_всього]) [ТО_всього] from #temp_vyr v) ss
left join (select [Міс.вин.п.], sum([Сума у внут.валюті]) [Сума у внут.валюті] from Business_Analytic.ecom.FAGLL03
group by [Міс.вин.п.]) f on f.[Міс.вин.п.]=t.mvz
left join (select [Міс.вин.п.], sum([Glovo]) [Glovo]
, sum([iPost]) [iPost], sum([Uklon]) [Uklon], sum([Доставка shop.fora.ua]) [Доставка shop.fora.ua], 
sum([Самовывоз shop.fora.ua]) [Самовывоз shop.fora.ua], sum([Рой]) [Рой], sum([Нова пошта]) [Нова пошта]
from #tmp_f
group by [Міс.вин.п.]) ff on ff.[Міс.вин.п.]=t.mvz

  delete from  business_analytic.ecom.vyruchka_final
  where mvz in ('20211A2527', '20211I0218', '20211RC014', '20211RC016', '20200A6000')

  select * from business_analytic.ecom.vyruchka_final
  where year=2026 and month=4

