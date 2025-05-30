USE [MarketingReportDWH]
GO
/****** Object:  StoredProcedure [DynamicReportBuilder].[DinamikPlanSEOPP]    Script Date: 20.05.2025 15:00:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [DynamicReportBuilder].[DinamikPlanSEOPP]

AS
BEGIN


declare @td as date = (SELECT GETDATE()) --Дата "сегодня", нужна для расчта от текущей даты до конца месяца, использует формат "2022-01-01T00:00:00"
declare @pdm as date = EOMONTH(@td) -- дата-конец текущего месяца, нужна для расчта от текущей даты до конца месяца, использует формат "2022-01-01T00:00:00"
declare @pdy as date = DATEADD(yy, DATEDIFF(yy, 0, @td) + 1, -1)--последний день года, использует формат "2022-01-01T00:00:00". Бесполезен 
declare @firstmes Nvarchar(30) = MONTH(@td)+1 -- номер следующего месяца после текущего, нужна дря расчета от следующего месяца после ткущего до конца года "по месяцам", имеет формат "1", "2"..., "12"
declare @tekYear Nvarchar(30)  = year(@td) --год текущей даты, нужна дря расчета от следующего месяца после ткущего до конца года "по месяцам", имеет формат "2022"

Declare @tdp Nvarchar(10), @pdmp Nvarchar(30),  @pdyp Nvarchar(30), @firstmesp Nvarchar(30), @tekYearp Nvarchar(30)
set @tdp=FORMAT (@td, 'yyyy-MM-dd')
set @pdmp=FORMAT (@pdm, 'yyyy-MM-dd')
set @pdyp=FORMAT (@pdy, 'yyyy-MM-dd')
set @firstmesp= case when @firstmes=13 then   format (DATEADD(MONTH, +0, GETDATE()),'MM') else format (DATEADD(MONTH, +1, @td),'MM') end 
set @tekYearp= format (DATEADD(MONTH, 0, @td),'yyyy')


--declare @zp nvarchar(max) = 

declare @query as nvarchar (max) =
'SELECT *
                                               FROM OPENQUERY ([WHSASP01_SALESMANAGER],''
with
set VerPlan as ({[SAPPlans].[SAP Plan ID].&[9]
})
select {[Measures].[SAPPlanWeightSalesPlan-Calc]} on 0
,nonempty((
[Calendar].[Date].&['+@tdp+'T00:00:00] : [Calendar].[Date].&['+@pdmp+'T00:00:00],
[Products].[Marking].children,
[ResponsibilityAreas].[R Name2].[R Name2],
[ResponsibilityAreas].[RObl2].[RObl2],
[DistrChannel].[Distr Channel Name].[Distr Channel Name],
[Chain].[Retail Chain Name].[Retail Chain Name],
VerPlan),
[Measures].[SAPPlanWeightSalesPlan-Calc]) on 1
from [Управление продажами]
where (
[Firms].[Head Firm].children-[Firms].[Head Firm].&[ЗАО "РЛЦ"],
[Products].[Is Spoilage].&[Нет],
{[SalesOrderStatuses].[SalesOrderStatus].&[12],
[SalesOrderStatuses].[SalesOrderStatus].&[11],
[SalesOrderStatuses].[SalesOrderStatus].&[15],
[SalesOrderStatuses].[SalesOrderStatus].&[9]},
{[ResponsibilityAreas].[RA Name4].&[],
[ResponsibilityAreas].[RA Name4].&[Дивизион _архив],
[ResponsibilityAreas].[RA Name4].&[Национальная дирекция 6_архив],
[ResponsibilityAreas].[RA Name4].&[Национальная дирекция 7_архив],
[ResponsibilityAreas].[RA Name4].&[ОП РЛЦ Краснодар, Ставрополь_архив],
[ResponsibilityAreas].[RA Name4].&[ОП РЛЦ Москва_архив],
[ResponsibilityAreas].[RA Name4].&[Проектная группа 10 Саратов_архив],
[ResponsibilityAreas].[RA Name4].&[Проектная группа 2 Казань_архив],
[ResponsibilityAreas].[RA Name4].&[Сети архив],
[ResponsibilityAreas].[RA Name4].&[Склады Трейд-Сервиса],
[ResponsibilityAreas].[RA Name4].&[Служба мерчендайзинга],
[ResponsibilityAreas].[RA Name4].&[Служба национальных продаж НКК],
[ResponsibilityAreas].[RA Name4].&[Служба национальных продаж Топ ЛКК],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 1],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 2],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 3],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 4],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 5],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 6],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 7],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 8],
[ResponsibilityAreas].[RA Name4].&[Служба продаж Опт и Хорека],
[ResponsibilityAreas].[RA Name4].&[Служба продаж ТМ Славница],
[ResponsibilityAreas].[RA Name4].&[Служба региональных менеджеров по работе с НКК]}
) 
                      '')'

                      
declare @queryM as nvarchar (max) =
'SELECT *
                                               FROM OPENQUERY ([WHSASP01_SALESMANAGER],''
with
set VerPlan as ({[SAPPlans].[SAP Plan ID].&[9]
})
select {[Measures].[SAPPlanWeightSalesPlan-Calc]} on 0
,nonempty((
[Calendar].[Calendar Year].[Calendar Year],
[Calendar].[MonthNumberOfYear].[MonthNumberOfYear],
[Products].[Marking].children,
[ResponsibilityAreas].[R Name2].[R Name2],
[ResponsibilityAreas].[RObl2].[RObl2],
[DistrChannel].[Distr Channel Name].[Distr Channel Name],
[Chain].[Retail Chain Name].[Retail Chain Name],
VerPlan),
[Measures].[SAPPlanWeightSalesPlan-Calc]) on 1
from [Управление продажами]
where (
[Firms].[Head Firm].children-[Firms].[Head Firm].&[ЗАО "РЛЦ"],
[Products].[Is Spoilage].&[Нет],
{[SalesOrderStatuses].[SalesOrderStatus].&[12],
[SalesOrderStatuses].[SalesOrderStatus].&[11],
[SalesOrderStatuses].[SalesOrderStatus].&[15],
[SalesOrderStatuses].[SalesOrderStatus].&[9]},
{[ResponsibilityAreas].[RA Name4].&[],
[ResponsibilityAreas].[RA Name4].&[Дивизион _архив],
[ResponsibilityAreas].[RA Name4].&[Национальная дирекция 6_архив],
[ResponsibilityAreas].[RA Name4].&[Национальная дирекция 7_архив],
[ResponsibilityAreas].[RA Name4].&[ОП РЛЦ Краснодар, Ставрополь_архив],
[ResponsibilityAreas].[RA Name4].&[ОП РЛЦ Москва_архив],
[ResponsibilityAreas].[RA Name4].&[Проектная группа 10 Саратов_архив],
[ResponsibilityAreas].[RA Name4].&[Проектная группа 2 Казань_архив],
[ResponsibilityAreas].[RA Name4].&[Сети архив],
[ResponsibilityAreas].[RA Name4].&[Склады Трейд-Сервиса],
[ResponsibilityAreas].[RA Name4].&[Служба мерчендайзинга],
[ResponsibilityAreas].[RA Name4].&[Служба национальных продаж НКК],
[ResponsibilityAreas].[RA Name4].&[Служба национальных продаж Топ ЛКК],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 1],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 2],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 3],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 4],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 5],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 6],
[ResponsibilityAreas].[RA Name4].&[Служба продаж 7],[ResponsibilityAreas].[RA Name4].&[Служба продаж 8],
[ResponsibilityAreas].[RA Name4].&[Служба продаж Опт и Хорека],
[ResponsibilityAreas].[RA Name4].&[Служба продаж ТМ Славница],
[ResponsibilityAreas].[RA Name4].&[Служба региональных менеджеров по работе с НКК]},
[Calendar].[Y-M-D].[Month Number Of Year].&['+@tekYearp+']&['+@firstmesp+'] : [Calendar].[Y-M-D].[Month Number Of Year].&['+@tekYearp+']&[12]
) 
                      '')'
declare @tabletmp as table ( [Год] nvarchar (10),
                                          [Номер месяца] nvarchar (10),
                                          [Код Аксапты_tmp] nvarchar (150),
                                          [Region] nvarchar (20),
                                          [Область ТМ] nvarchar (150),
                                          [Distr Channel Name] nvarchar (150),
                                          [Retail Chain Name] nvarchar (150),
                                          [Ver Plan] nvarchar (20),
                                          [План продаж, кг] float)--созадли tabltemp
    insert into @tabletmp ( [Год],
                                          [Номер месяца],
                                          [Код Аксапты_tmp],
                                          [Region],
                                          [Область ТМ],
                                          [Distr Channel Name],
                                          [Retail Chain Name],
                                          [Ver Plan],
                                          [План продаж, кг])   --вставили значения в таблицу tabltemp


exec sp_executeSQL @queryM ---процедура выше как select , откуда


declare @table as table ( [Date] date,
                                          [Код Аксапты_tmp] nvarchar (150),
                                          [Region] nvarchar (20),
                                          [Область ТМ] nvarchar (150),
                                          [Distr Channel Name] nvarchar (150),
                                          [Retail Chain Name] nvarchar (150),
                                          [Ver Plan] nvarchar (20),
                                          [План продаж, кг] float)   --созадли table

insert into @table ([Date],
                                  [Код Аксапты_tmp],
                                  [Region],
                                  [Область ТМ],
                                  [Distr Channel Name],
                                  [Retail Chain Name],
                                  [Ver Plan],
                                  [План продаж, кг] )--вставили значения в таблицу table и хотим запихать то что внизу

exec sp_executeSQL @query ---процедура выше как select , откуда

insert into @table ([Date],
                                  [Код Аксапты_tmp],
                                  [Region],
                                  [Область ТМ],
                                  [Distr Channel Name],
                                  [Retail Chain Name],
                                  [Ver Plan],
                                  [План продаж, кг] )  --вставили ещё значения в таблицу table

select cast([Год]+'.'+[Номер месяца]+'.'+'01' as date) as [date], 
       [Код Аксапты_tmp],
          [Region],
          [Область ТМ],
          [Distr Channel Name],
          [Retail Chain Name],
          [Ver Plan],
          [План продаж, кг]  --, откуда
		  
from @tabletmp

end

