USE [TertiarySales]
GO
/****** Object:  StoredProcedure [Ship].[Simile_MTS-Ship_вс-ост]    Script Date: 20.05.2025 14:41:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER   PROCEDURE  [Ship].[Simile_MTS-Ship_]

AS
BEGIN

SET NOCOUNT ON;

declare @NoFound as int=0 --ПОИСК БЕЗ ИСКЛЮЧЕНИЙ если 0, то исключаем из поиска продукты из таблицы исключений(списания или розница) и исключаем "Прочие" группы мясо, охлажденка, рыба? и смотрим продажи за период.

declare @NoFoundName table (NameConstructorWeightNoFound nvarchar(max))
insert into @NoFoundName select [NameConstructor] from [TertiarySales].[dbo].[SHIP_NoFoundID] 


declare @NoFoundGroup table (NameConstructorWeightGroup nvarchar(max))  -- исключения для выборки
insert into @NoFoundGroup
SELECT [Наименование конструктора с весом]
  FROM [CompetitorSupplies].[to_model].[viewProducts]
    where [ПродуктоваяГруппаТП] in ('Мясные изделия',
'Прочие изделия',
'Котлеты рыбные',
'Рыбные пельмени',
'Рыбные изделия',
'Не определено')





declare @MTS table (ManufacturerMTS nvarchar(max),NameConstructorWeightMTS nvarchar(max), CalendarsMTS date, ProductMTSIDMTS nvarchar(max), SalesKGMTS float, ProductSourceMTS nvarchar(max))
insert into @MTS
SELECT *,[Производитель]='MTS'
	FROM OPENQUERY ([RUVLD1SQLM09_MTS], 
		'DEFINE
  VAR __DS0FilterTable = 
    TREATAS({"N","M"}, ''Продукты''[Производитель])

  VAR __DS0FilterYear = 
    TREATAS({"2024","2025"}, ''Календарь''[Год] )   

  VAR __chaines = 
    TREATAS({"X5","Ашан","Верный","ВкусВилл","Глобус","Дикси","Доброцен","Лента","Маяк","Метро","Окей","Самокат","Светофор","Смарт","СПАР Миддл Волга","Тандер","Фрешмаркет"}, ''Места продаж''[Родительская сеть])    

  VAR __DS0Core = 
    SUMMARIZECOLUMNS(
      ''Продукты''[Производитель],
      ''Продукты''[Конструктор Наименование с весом],
      ''Календарь''[Первый день месяца],
      ''Продукты''[ProductID],
      __DS0FilterTable, 	  __DS0FilterYear,	  __chaines,
      "Продажи__кг", ''Меры''[Продажи, кг])

EVALUATE  __DS0Core
	order by ''Продукты''[Конструктор Наименование с весом],''Календарь''[Первый день месяца]') 


/*продукты из базы Меркурия*/
declare @SHIP table (ManufacturerSH nvarchar(max),NameConstructorWeightSH nvarchar(max), CalendarsSH date, ProductShipIDSH nvarchar(max), SalesKGSH float, ProductSourceSH nvarchar(max))
insert into @SHIP 
SELECT *, [Производитель]='SHIP'
	FROM OPENQUERY ([RUVLD1SQLM44_CompetitorSupplies],
'DEFINE
  VAR __DS0FilterTable = 
    TREATAS({"N","M"}, ''Ship Products''[Производитель])

 VAR __DS0FilterYear = 
    TREATAS({"2024","2025"}, ''Calendars''[Год])    

  VAR __DS0Core = 
    SUMMARIZECOLUMNS(
      ''Ship Products''[Производитель],
      ''Ship Products''[Наименование конструктора с весом],
      ''Calendars''[Первый день месяца],
      ''Ship Products''[ProductID],
      __DS0FilterTable, 
	  __DS0FilterYear,
      "Продажи__кг", ''Ship Facts''[Продажи, кг])
EVALUATE  __DS0Core order by ''Ship Products''[Наименование конструктора с весом],''Calendars''[Первый день месяца]')

--/*
declare @MTS_2 table (ManufacturerMTS nvarchar(max),NameConstructorWeightMTS nvarchar(max), ProductSourceMTS nvarchar(max), SUMSalesKGMTS float, AmountMountMTS int,CalendarsMTSmin date,CalendarsMTSmax date) 
insert into @MTS_2  
  Select Tabsumm.ManufacturerMTS,Tabsumm.NameConstructorWeightMTS,ProductSourceMTS,SUM(SalesKGMTS)/cn as SummSalesTSO,cn, min(TabTsOMPK.CalendarsMTS), max(TabTsOMPK.CalendarsMTS)
 from @MTS Tabsumm join 
(select *, COUNT (CalendarsMTS) over (partition by NameConstructorWeightMTS) cn from 
(select distinct ManufacturerMTS,NameConstructorWeightMTS,CalendarsMTS from @MTS where  CalendarsMTS BETWEEN '2024-01-01' and  GETDATE()) TabDIST  ) TabTsOMPK on Tabsumm.NameConstructorWeightMTS=TabTsOMPK.NameConstructorWeightMTS --текущий месяц минус 2 из третички
 where TabTsOMPK.CalendarsMTS BETWEEN '2024-01-01' and  GETDATE() group by   Tabsumm.ManufacturerMTS, Tabsumm.NameConstructorWeightMTS, ProductSourceMTS,cn


declare @SHIP_2 table (ManufacturerSH nvarchar(max),NameConstructorWeightSH nvarchar(max), ProductSourceSH nvarchar(max), SUMSalesKGSH float, AmountMountSH int,CalendarsSHmin date,CalendarsSHmax date)
insert into @SHIP_2  
  Select Tabsumm.ManufacturerSH,Tabsumm.NameConstructorWeightSH,ProductSourceSH,SUM(SalesKGSH)/cn as SummSalesSH,cn ,min(TabTsOMPK.CalendarsSH),max(TabTsOMPK.CalendarsSH)
 from @SHIP Tabsumm join 
(select *, COUNT (CalendarsSH) over (partition by NameConstructorWeightSH) cn from 
(select distinct ManufacturerSH,NameConstructorWeightSH,CalendarsSH from @SHIP where CalendarsSH BETWEEN '2024-01-01' and  GETDATE()) TabDIST  ) TabTsOMPK on Tabsumm.NameConstructorWeightSH=TabTsOMPK.NameConstructorWeightSH --текущий месяц минус 3 из третички
 where TabTsOMPK.CalendarsSH BETWEEN '2024-01-01' and GETDATE()  group by   Tabsumm.ManufacturerSH, Tabsumm.NameConstructorWeightSH, ProductSourceSH,cn

select 
  MTS_2.*, 
  SHIP_2.* 
from 
  @SHIP_2 as SHIP_2 FULL 
  JOIN @MTS_2 as MTS_2 ON SHIP_2.NameConstructorWeightSH = MTS_2.NameConstructorWeightMTS 
  left join @NoFoundName as NoFoundName on NameConstructorWeightNoFound = SHIP_2.NameConstructorWeightSH 
  or NameConstructorWeightNoFound = MTS_2.NameConstructorWeightMTS 
  left join @NoFoundGroup as NoFoundGroup on NameConstructorWeightGroup = SHIP_2.NameConstructorWeightSH 
where 
NameConstructorWeightSH is null 
  or NameConstructorWeightMTS is null and ( NameConstructorWeightNoFound is null 
    and NameConstructorWeightGroup is null) END 

--select 



	
