declare @year int=2026
declare @month int=4

/*delete from business_analytic.ecom.TO_ecom
where year=@year and month=@month*/

delete from [Business_Analytic].[ecom].[analyzer_mvz_final]
where year=@year and month=@month

delete from business_analytic.ecom.vyruchka_final
where year=@year and month=@month

delete from business_analytic.ecom.vyruchka
where year=@year and month=@month


delete from Business_Analytic.ecom.FAGLL03
where month([Дата док.])=@month and year([Дата док.])=@year

delete from business_analytic.ecom.analyzer_mvz_bonuses_100
where year=@year and month=@month

delete from business_analytic.ecom.analyzer_mvz_fop_office
where year=@year and month=@month

delete from business_analytic.ecom.sap_info
where year=@year and month=@month

delete from [Business_Analytic].[ecom].[analyzer_mvz]
where year=@year and month=@month

delete from business_analytic.ecom.analyzer_mvz_fop
where year=@year and month=@month


