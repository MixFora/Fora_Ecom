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
      ,[MVZ], [type],[Ïîêàçíèê]
      ,sum([Ãðí_áåç_ïäâ]) [Ãðí_áåç_ïäâ]
	  into #to_ecom_t
  FROM [Business_Analytic].[ecom].[TO_ecom] t
  where month=@month and year=@year
  group by [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ], [type]
      ,[Ïîêàçíèê]


SELECT [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ]
      ,[Ïîêàçíèê],
	  	case when t.type='iPost' then t.Ãðí_áåç_ïäâ else 0 end as [iPost],
	case when t.type='Ðîé' then t.Ãðí_áåç_ïäâ else 0 end as [Ðîé],
	case when t.type='Íîâà ïîøòà' then t.Ãðí_áåç_ïäâ else 0 end as [Íîâà ïîøòà],
	case when t.type='Uklon' then t.Ãðí_áåç_ïäâ else 0 end as [Uklon],
	case when t.type='Äîñòàâêà shop.fora.ua' then t.Ãðí_áåç_ïäâ else 0 end as [Äîñòàâêà shop.fora.ua],
	case when t.type='Ñàìîâûâîç shop.fora.ua' then t.Ãðí_áåç_ïäâ else 0 end as [Ñàìîâûâîç shop.fora.ua],
	case when t.type='Glovo' then t.Ãðí_áåç_ïäâ else 0 end as [Glovo]
	  into #to_ecom
  FROM #to_ecom_t t
  where month=@month and year=@year


  select [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ]
      ,[Ïîêàçíèê], sum([Glovo]) [Glovo], sum([iPost]) [iPost], sum([Uklon]) [Uklon], sum([Äîñòàâêà shop.fora.ua]) [Äîñòàâêà shop.fora.ua], 
	  sum([Ñàìîâûâîç shop.fora.ua]) [Ñàìîâûâîç shop.fora.ua], sum([Ðîé]) [Ðîé], sum([Íîâà ïîøòà]) [Íîâà ïîøòà]
	  into #to_ecom_f
	  FROM #to_ecom
  group by [year]
      ,[month]
      ,[filid]
      ,[fil.Filials.filialNameUA]
      ,[MVZ]
      ,[Ïîêàçíèê]


select v.*, t.[Glovo],t.[iPost],t.[Uklon],t.[Äîñòàâêà shop.fora.ua], 
	  t.[Ñàìîâûâîç shop.fora.ua], t.[Ðîé],t.[Íîâà ïîøòà],

	  /*case when v.sum_vytraty=0 then 0 else t.[Glovo]/v.sum_vytraty end as [Glovo %% â On-line],
	  case when v.sum_vytraty=0 then 0 else t.[iPost]/v.sum_vytraty end as [iPost %% â On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Uklon]/v.sum_vytraty end as [Uklon %% â On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Äîñòàâêà shop.fora.ua]/v.sum_vytraty end as [Äîñòàâêà shop.fora.ua %% â On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Ñàìîâûâîç shop.fora.ua]/v.sum_vytraty end as [Ñàìîâûâîç shop.fora.ua %% â On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Ðîé]/v.sum_vytraty end as [Ðîé %% â On-line],
	  case when v.sum_vytraty=0 then 0 else t.[Íîâà ïîøòà]/v.sum_vytraty end as [Íîâà ïîøòà %% â On-line],*/
	  tt.[Glovo] [Glovo_ñîá],tt.[iPost] [iPost_ñîá],tt.[Uklon] [Uklon_ñîá],tt.[Äîñòàâêà shop.fora.ua] [Äîñòàâêà shop.fora.ua_ñîá], 
	  tt.[Ñàìîâûâîç shop.fora.ua] [Ñàìîâûâîç shop.fora.ua_ñîá], tt.[Ðîé] [Ðîé_ñîá],tt.[Íîâà ïîøòà] [Íîâà ïîøòà_ñîá],

	   t.[Glovo]+t.[iPost]+t.[Uklon]+t.[Äîñòàâêà shop.fora.ua]+ 
	  t.[Ñàìîâûâîç shop.fora.ua]+t.[Ðîé]+t.[Íîâà ïîøòà] [ÒÎ_âñüîãî],

	  tt.[Glovo]+tt.[iPost]+tt.[Uklon]+tt.[Äîñòàâêà shop.fora.ua]+ 
	  tt.[Ñàìîâûâîç shop.fora.ua]+tt.[Ðîé]+tt.[Íîâà ïîøòà] [Ñîá³âàðò³ñòü_âñüîãî],

	  t.[Glovo]+t.[iPost]+t.[Uklon]+t.[Äîñòàâêà shop.fora.ua]+ 
	  t.[Ñàìîâûâîç shop.fora.ua]+t.[Ðîé]+t.[Íîâà ïîøòà] + 
	  tt.[Glovo]+tt.[iPost]+tt.[Uklon]+tt.[Äîñòàâêà shop.fora.ua]+ 
	  tt.[Ñàìîâûâîç shop.fora.ua]+tt.[Ðîé]+tt.[Íîâà ïîøòà] [Ôðîíò_ìàðæà]
	  into #temp_vyr
	  from business_analytic.ecom.vyruchka v
left join #to_ecom_f t on t.mvz=v.mvz and t.year=v.year and t.month=v.month and [Ïîêàçíèê]='ÒÎ_áåç_ïäâ'
left join #to_ecom_f tt on tt.mvz=v.mvz and tt.year=v.year and tt.month=v.month and tt.[Ïîêàçíèê]='ñîá³âàðò³ñòü_áåç_ïäâ'
where v.month=@month and v.year=@year

	  select [Ì³ñ.âèí.ï.], 
case when [Ñòàò]='Glovo' then sum([Ñóìà ó âíóò.âàëþò³]) else 0 end as [Glovo],
case when [Ñòàò]='iPost' then sum([Ñóìà ó âíóò.âàëþò³]) else 0 end as [iPost],
case when [Ñòàò]='Uklon' then sum([Ñóìà ó âíóò.âàëþò³]) else 0 end as [Uklon],
case when [Ñòàò]='Äîñòàâêà shop.fora.ua' then sum([Ñóìà ó âíóò.âàëþò³]) else 0 end as [Äîñòàâêà shop.fora.ua],
case when [Ñòàò]='Ñàìîâûâîç shop.fora.ua' then sum([Ñóìà ó âíóò.âàëþò³]) else 0 end as [Ñàìîâûâîç shop.fora.ua],
case when [Ñòàò]='Ðîé' then sum([Ñóìà ó âíóò.âàëþò³]) else 0 end as [Ðîé],
case when [Ñòàò]='Íîâà ïîøòà' then sum([Ñóìà ó âíóò.âàëþò³]) else 0 end as [Íîâà ïîøòà]
into #tmp_f
from Business_Analytic.ecom.FAGLL03
where month([Äàòà äîê.])=@month and year([Äàòà äîê.])=@year
group by [Ì³ñ.âèí.ï.], [Ñòàò]



delete from business_analytic.ecom.vyruchka_final
where year=@year and month=@month


insert into business_analytic.ecom.vyruchka_final
select t.*, 
case when t.[ÒÎ_âñüîãî]=0 then 0 else t.[Glovo]/t.[ÒÎ_âñüîãî] end as [Glovo %% â On-line], 
case when t.[ÒÎ_âñüîãî]=0 then 0 else t.[iPost]/t.[ÒÎ_âñüîãî] end as [iPost %% â On-line],  
case when t.[ÒÎ_âñüîãî]=0 then 0 else t.[Uklon]/t.[ÒÎ_âñüîãî] end as [Uklon %% â On-line],  
case when t.[ÒÎ_âñüîãî]=0 then 0 else t.[Äîñòàâêà shop.fora.ua]/t.[ÒÎ_âñüîãî] end as [Äîñòàâêà shop.fora.ua %% â On-line],  
case when t.[ÒÎ_âñüîãî]=0 then 0 else t.[Ñàìîâûâîç shop.fora.ua]/t.[ÒÎ_âñüîãî] end as [Ñàìîâûâîç shop.fora.ua %% â On-line],  
case when t.[ÒÎ_âñüîãî]=0 then 0 else t.[Ðîé]/t.[ÒÎ_âñüîãî] end as [Ðîé %% â On-line],  
case when t.[ÒÎ_âñüîãî]=0 then 0 else t.[Íîâà ïîøòà]/t.[ÒÎ_âñüîãî] end as [Íîâà ïîøòà %% â On-line], 

case when t.[sum_vytraty]=0 then 0 else t.[ÒÎ_âñüîãî]/t.[sum_vytraty] end as [Äîëÿ On-line â ÒÎ Ìàãàçèíó],
case when t.[sum_vytraty]=0 then 0 else t.[ÒÎ_âñüîãî]/ss.[ÒÎ_âñüîãî] end as [Äîëÿ Ìàãàçèíó â ÒÎ On-Line],
[Ñóìà ó âíóò.âàëþò³] [Êóð'ºðÄîñòàâÏîñèëîê On-line ÂÑÜÎÃÎ],
 ff.[Glovo] [Glovo_êóð], ff.[iPost] [iPost_êóð], ff.[Uklon] [Uklon_êóð], ff.[Äîñòàâêà shop.fora.ua] [Äîñòàâêà shop.fora.ua_êóð], 
	  ff.[Ñàìîâûâîç shop.fora.ua] [Ñàìîâûâîç shop.fora.ua_êóð], ff.[Ðîé] [Ðîé_êóð], ff.[Íîâà ïîøòà] [Íîâà ïîøòà_êóð]
from #temp_vyr t
cross join (select sum(sum_vytraty) sum_vytraty from business_analytic.ecom.vyruchka where month=@month and year=@year) s
cross join (select sum([ÒÎ_âñüîãî]) [ÒÎ_âñüîãî] from #temp_vyr v) ss
left join (select [Ì³ñ.âèí.ï.], sum([Ñóìà ó âíóò.âàëþò³]) [Ñóìà ó âíóò.âàëþò³] from Business_Analytic.ecom.FAGLL03
group by [Ì³ñ.âèí.ï.]) f on f.[Ì³ñ.âèí.ï.]=t.mvz
left join (select [Ì³ñ.âèí.ï.], sum([Glovo]) [Glovo]
, sum([iPost]) [iPost], sum([Uklon]) [Uklon], sum([Äîñòàâêà shop.fora.ua]) [Äîñòàâêà shop.fora.ua], 
sum([Ñàìîâûâîç shop.fora.ua]) [Ñàìîâûâîç shop.fora.ua], sum([Ðîé]) [Ðîé], sum([Íîâà ïîøòà]) [Íîâà ïîøòà]
from #tmp_f
group by [Ì³ñ.âèí.ï.]) ff on ff.[Ì³ñ.âèí.ï.]=t.mvz

  delete from  business_analytic.ecom.vyruchka_final
  where mvz in ('20211A2527', '20211I0218', '20211RC014', '20211RC016', '20200A6000')

  select * from business_analytic.ecom.vyruchka_final
  where year=@year and month=@month

