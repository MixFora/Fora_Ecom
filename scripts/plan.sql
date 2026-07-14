select * from business_analytic.ecom.analyzer_mvz_final

create table business_analytic.ecom.Plan_ecom(
	year int,
	month int,
	type_vytraty int,
	name_vytraty nvarchar(100),
	[Меппінг] nvarchar(50),
	[Признак_EBITDA] nvarchar(50),
	[Розрахунок] nvarchar(50),
	Glovo decimal(12, 3),
	iPost decimal(12, 3),
	Uklon decimal(12, 3),
	[Доставка] decimal(12, 3),
	[Самовивіз] decimal(12, 3),
	[Рой] decimal(12, 3),
	[Нова пошта] decimal(12, 3),
);


select sum([Самовивіз]) from business_analytic.ecom.Plan_ecom
where [Признак_EBITDA]<>'Інші витрати'
group by month;

select year,month,type_vytraty,name_vytraty,[Меппінг],[Признак_EBITDA],[Розрахунок],
sum(Glovo) Glovo, sum(iPost) iPost, sum(Uklon) Uklon, sum([Доставка]) [Доставка], 
sum([Самовивіз]) [Самовивіз], sum([Рой]) [Рой], sum([Нова пошта]) [Нова пошта]
into business_analytic.ecom.Plan_ecom
from business_analytic.ecom.Plan_ecom1
group by year,month,type_vytraty,name_vytraty,[Меппінг],[Признак_EBITDA],[Розрахунок]


select distinct меппінг from business_analytic.ecom.Plan_ecom


DROP TABLE business_analytic.ecom.Plan_ecom;
delete from business_analytic.ecom.Plan_ecom
where [Признак_EBITDA] ='Інші витрати' 

update p
set p.меппінг='Ремонти' --'Компютерне обладнання'--'Транспорт'
from business_analytic.ecom.Plan_ecom p
where p.меппінг='Транспорт' --'. Компютерне обладнання'--'. Транспорт'

