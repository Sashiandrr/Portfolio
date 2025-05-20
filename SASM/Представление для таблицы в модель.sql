USE [TertiarySales]
GO

/****** Object:  View [model].[Products]    Script Date: 20.05.2025 15:03:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













ALTER VIEW [model].[Products]
AS
SELECT      
isnull(isnull(p.[ProductCategoriesName], nsicat.nsiname), 'Не определено') [Категория НСИ], 
tp.ProductID, 
tp.ProductVariantsID, 
tp.SplitDate[Дата окончания], 
tp.AddDate[Дата начала], 
CAST(pn.[ProductNameSrc] AS NVARCHAR(1024)) AS ProductName,
CAST(tp.ProductCode AS NVARCHAR(1024)) AS ProductCode,
CAST(cp.[ProductCode] AS NVARCHAR(1024)) AS [Код продукта AX],
--pn.[ProductNameSrc] ProductName,
--tp.ProductCode ProductCode,
--cp.[ProductCode] AS [Код продукта AX],

CASE WHEN tp.AxaptaCode IS NULL THEN 'Не определено' ELSE tp.AxaptaCode END AS AxaptaCode, 
m.Manufacturer, 
m.ManufacturerID,
--coalesce (GK.[Группа Компаний], m.Manufacturer) as [Группа Компаний], --12.03.2024 GK Илья дегтярь в ковычка поменять что выводится без ГК, неопределено или производитель
tm.TradeMark, 
ISNULL(p.[SAPSKUTrademarkName], tm.TradeMark) AS SAPSKUTrademarkName, 
pc.ProductTypeName Category, 
pc.ProductTypeID, 
pg.ProductGroup, 
pg.[NameGroupForReport], 
isnull(rdn.[ReportName], pg.[NameGroupForReport]) [Детальная группа], /*основана на справочнике подгрупп и групп*/ 
f.[Name] [Форма продукта], /*pt.PackingTypeName, --заменить на форму*/ 
isnull(p.[ProductFormatName], pf.nsiname) [Формат продукта НСИ], 
ts.TradeSeria, 
ISNULL(p.[SAPSKUTradeSeriaName], ts.TradeSeria) AS SAPSKUTradeSeriaName, 
sh.ShellName,
tp.ProductWeight as ProductWeightSrc,
REPLACE(CAST(CAST(tp.ProductWeight AS float) AS nvarchar), '.', ',') AS ProductWeight, 
ISNULL(p.SAPSKUCSKUName, N'Не определено') AS SAPSKUCSKUName, 
ISNULL(isnull(cp.[ProductName], p.SAPSKUName), N'Не определено') AS SAPSKUName, 
ISNULL(isnull(cp.[ProductShortName], p.SAPSKUShortName), N'Не определено') AS SAPSKUShortName, 
mn.[ManufacturerSrc] AS ManufacturerSource, 
ISNULL(p.SAPSKUCode , 0) AS SAPSKUCode, 
ISNULL(p.SAPSKUCSKUID ,0) AS SAPSKUCSKUID, 
ISNULL(p.SAPSKUProductionSKUID ,0) AS SAPSKUProductionSKUID, 
ISNULL(p.[SAPSKUAlternativeSKUID],0) AS [SAPSKUAlternativeSKUID], 
ISNULL(p.[SAPSKUAlternativeSKUName], N'Не определено') [Альтернативное],
ISNULL(p.SAPSKUCSKUNameShort, N'Не определено') AS SAPSKUCSKUNameShort, 
ISNULL(p.[SAPRecipeSKUID] , 0) AS [SAPRecipeSKUID], 
ISNULL(p.RecipeSKUsName, N'Не определено') AS RecipeSKUsName, ISNULL(p.RecipeSKUsNameShort, N'Не определено') AS [RecipeSKUsNameShort], /*	, try_parse(substring(tp.ProductName,CHARINDEX(':',tp.ProductName)+1,100) as decimal)  as kvantIsh*/ ISNULL(mt.ManufacturerType, 'Остальные конкуренты') AS [Тип производителя], 
h.name AS [Халяль], 
tp.ProductGroupID, 
CASE WHEN tp.[ManufacturerID] = 1357 THEN N'СТМ' ELSE N'Остальное' END [Характер производства]

/*Собираем наименование товара с весом*/ , 
	isnull(rdn.[ReportNameForConstructor] + ' ', 
	/*Короткое название группы*/ 
	CASE WHEN pg.AddNameGroup = 1 THEN isnull(pg.ProductGroupShort + ' ', pg.ProductGroup + ' ') ELSE '' END) + 
	/*Подгруппа*/ 
	CASE WHEN pg.AddNameSubGroup = 1 AND rdn.[ReportNameForConstructor] IS NULL AND spg.SubProductGroupID <> 10 THEN isnull(spg.SubProductGroup + ' ', '') ELSE '' END + 
	/*Наименование*/ 
	CASE WHEN pg.AddNameConstructor = 1 THEN isnull(tp.[ShortNameForConstructor] + ' ', '') ELSE '' END +  
	/*Халяль*/ 
	isnull(h.[halalForConstructor]+' ','') +

	/*Тип по весу и серия*/ 
	/*Убран из конструкторов АБИ 29.08.2024*/
	CASE WHEN m.ManufacturerID NOT IN (7) THEN
		CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria<> tm.TradeMark THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
		ELSE '' END + 

	/*Тип упаковки*/ 
	CASE WHEN pg.AddNameShell = 1 THEN isnull(sh.ShellNameShort + ' ', '') 
							 ELSE '' END + 
	/*Вес упаковки'*/ 
	CASE WHEN pg.AddNameWeight = 1 THEN CASE WHEN tp.PackingTypeID = 4 THEN 'вес ' ELSE REPLACE(CAST(CAST(tp.ProductWeight AS float) AS nvarchar), '.', ',') + 'кг ' END ELSE '' END + 
	/*нарезка\кусок\срез*/ 					 
	CASE WHEN pg.AddNameform = 1 AND f.FormID not IN (19,24,25,26) /*не определено*/ THEN isnull(f.Name + ' ', '') ELSE '' END + 
	/*Производитель*/ 					 
	CASE WHEN pg.AddNameManufactur = 1 AND tp.[ManufacturerID] NOT IN (1672, 1674, 1357) THEN m.Manufacturer + ' ' ELSE '' END + 
	/*Торговая марка*/	 
	CASE WHEN pg.AddNameTradeMark = 1 AND tm.TradeMark <> m.Manufacturer AND tp.[TradeMarkID] NOT IN (1313, 1009) THEN tm.TradeMark + ' ' ELSE '' END +
	/*Вид КИ*/
	isnull(vki.Viewforconstructor, '') 
AS NameConstructorWeight, 

/*Собираем наименование товара без веса*/ 
isnull(rdn.[ReportNameForConstructor] + ' ', 
	/*Короткое название группы*/
    CASE WHEN pg.AddNameGroup = 1 THEN isnull(pg.ProductGroupShort + ' ', pg.ProductGroup + ' ') ELSE '' END) +  
	/*Подгруппа*/ 
	CASE WHEN pg.AddNameSubGroup = 1 AND rdn.[ReportNameForConstructor] IS NULL AND spg.SubProductGroupID <> 10 THEN isnull(spg.SubProductGroup + ' ', '') ELSE '' END + 
	/*Наименование*/ 
	CASE WHEN pg.AddNameConstructor = 1 THEN isnull(tp.[ShortNameForConstructor] + ' ', '') ELSE '' END + 
	/*Халяль*/ 
	isnull(h.[halalForConstructor]+' ','')+
	/*Тип по весу и серия*/ 
	/*Убран из конструкторов АБИ 29.08.2024*/
	CASE WHEN m.ManufacturerID NOT IN (7) THEN
		CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria<> tm.TradeMark THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
		ELSE '' END + 
	/*Тип упаковки*/ 
	CASE WHEN pg.AddNameShell = 1 THEN isnull(sh.ShellNameShort + ' ', '')  ELSE '' END + 
	/*CASE WHEN pg.AddNameform = 1 AND f.FormID <> 19 /*не определено*/ THEN isnull(f.Name + ' ', '') ELSE '' END + /*нарезка\кусок\срез удалено 15/06/2022*/*/ 
	/*Производитель*/ 
	CASE WHEN pg.AddNameManufactur = 1 AND tp.[ManufacturerID] NOT IN (1672, 1674, 1357) THEN isnull(m.Manufacturer + ' ', '') ELSE '' END + 
	/*Торговая марка*/
	CASE WHEN pg.AddNameTradeMark = 1 AND tm.TradeMark <> m.Manufacturer AND tp.[TradeMarkID] NOT IN (1313, 1009) THEN isnull(tm.TradeMark + ' ', '') ELSE '' END + 
	/*Вид КИ*/
	isnull(vki.Viewforconstructor, '') 
AS NameConstructorNoWeight, 

tp.[ShortNameForConstructor] [NameConstructor]
,vki.ViewKI
,spg.SubProductGroup AS [Подгруппа]
,spg.SubProductGroupID
,ct.CookingType TypeCooking
,pt.PackingType
,isnull([ProductGroupsName]
,pg.GroupsNSI) GroupsNSI
,p.MARKERSKU
,ISNULL(p.[SalesUnitCode], N'Не определено') AS [Код единицы продаж]
,ISNULL(p.[SalesUnitName], N'Не определено') AS [Единица продаж]
, 

/*
/*Краткое наименование товара с весом*/ 
	CASE WHEN pg.AddNameConstructor = 1 THEN isnull(tp.[ShortNameForConstructor] + ' ', CASE WHEN spg.[SubProductGroupID]<>10 then spg.[SubProductGroup]+' ' ELSE pg.[ProductGroup]+' ' END) ELSE '' END
	+ /*Наименование*/isnull(h.[halalForConstructor]+' ','')+ CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria <> tm.TradeMark  THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
	+ /*Наименование уточнение*/ CASE WHEN pg.AddNameShell = 1 THEN isnull(sh.ShellNameShort + ' ', '') ELSE '' END 
	+ /*Тип упаковки*/ CASE WHEN pg.AddNameWeight = 1 THEN CASE WHEN tp.PackingTypeID = 4 THEN 'вес ' ELSE REPLACE(CAST(CAST(tp.ProductWeight AS float) AS nvarchar), '.', ',') END ELSE '' END
	+ CASE WHEN pg.AddNameform = 1 AND f.FormID <> 19 /*не определено*/ THEN isnull(f.Name + ' ', '') ELSE '' END +isnull(vki.Viewforconstructor, '')
	AS ShortNameConstructorWeight
,
*/ 

/*Собираем короткое наименование для Ильи Дектяря*/  
ShortNameConstructorWeight = TertiarySales.prd.CAPITALIZE(
	/*Чебупели Стрипсы Бельмеши для ильи+*/
	CASE WHEN spg.SubProductGroupID in (41,40,38) THEN ISNULL(spg.SubProductGroup + ' ', '') ELSE '' END + 
	/*Наименование*/
	CASE WHEN pg.AddNameConstructor = 1 THEN ISNULL(tp.[ShortNameForConstructor] + ' ', '') ELSE '' END + 
	/*Халяль*/
	ISNULL(h.[halalForConstructor]+' ','') + 
	/*Тип по весу и серия*/ 
	/*Убран из конструкторов АБИ 29.08.2024*/
	CASE WHEN m.ManufacturerID NOT IN (7) THEN
		CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria<> tm.TradeMark THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
		ELSE '' END + 
	/*Упаковка*/
	CASE WHEN pg.AddNameShell = 1 THEN ISNULL(sh.ShellNameShort + ' ', '') ELSE '' END + 
	/*Вес*/
	CASE WHEN pg.AddNameWeight = 1 THEN 
		CASE WHEN tp.PackingTypeID = 4 THEN 'вес ' ELSE REPLACE(CAST(CAST(tp.ProductWeight AS float) AS NVARCHAR), '.', ',')  + 'кг ' END 
		ELSE '' END + 
	/*Форма (нарезка\кусок\срез)*/
	CASE WHEN pg.AddNameform = 1 AND f.FormID not IN (19,24,25,26) /*не определено*/ THEN ISNULL(f.Name + ' ', '') ELSE '' END + 
	/*Производитель*/
	--CASE WHEN pg.AddNameManufactur = 1 AND tp.[ManufacturerID] NOT IN (1672, 1674, 1357) THEN isnull(m.Manufacturer + ' ', '') ELSE '' END + 
	/*Торговая марка*/
	CASE WHEN pg.AddNameTradeMark = 1 /*AND tm.TradeMark <> m.Manufacturer*/ AND tp.[TradeMarkID] NOT IN (1313, 1009) THEN tm.TradeMark + ' ' ELSE '' END + 
	ISNULL(vki.Viewforconstructor, '') 
),
/*заканчиваем короткое наименование для Ильи Дектяря*/  

	ch.ChainName, wr.Name[Весовой сегмент], 
     wr2.Name[Весовой сегмент (диаграмма)]
	, tp.[DuplicatedProductID] doubleid, isnull(sg.segmentGroup, N'Не определено') [Группа сегмента], sg.SegmentGroupID, isnull(BrandMgt, N'Не определено') [Бренд дирекция], 
     CASE WHEN fullname.productid IS NULL THEN N'Нет' ELSE N'Да' END [Флаг Полный конструктор],
	 keyc.KeyComponent [Ключевой компонент]
	 ,isnull(p.Brand, N'Не определено') [Бренд]
	 , cn.Country [Страна производителя]
	 ,sch.ChainName [Сеть покупки]
	 ,fmt.FacetValue as [Фасет тип мяса]
	 ,fis.FacetValue as [Фасет копчение]
	 ,fсs.FacetValue as [Фасет ситуация потребления]
	 ,fti.FacetValue as [Фасет вкусовые включения]
	 ,fmi.FacetValue as [Фасет мясные включения]
	 ,fch.FacetValue as [Фасет рубленость] 
	 ,fbab.FacetValue as [Фасет детский]
	 ,fn1.FacetValue as [Фасет нейм уровень1]
	 ,fn2.FacetValue as [Фасет нейм уровень2]
	 ,fn3.FacetValue as [Фасет нейм уровень3]
	 ,fps.FacetValue as [Фасет размер фасовки]
	-- ,fth.FacetValue as [Фасет толщина]
	 ,fhal.FacetValue as [Фасет халяль]
	 ,fgost.FacetValue as [Фасет ГОСТ]
	 ,fprs.FacetValue as [Фасет размер продукта]
	 ,case when fn1.FacetValue is null or fn2.FacetValue  is null or fn3.FacetValue is null then Null else fn1.FacetValue +case when fn1.FacetValue <> fn2.FacetValue then '|'+fn2.FacetValue  ELSE '' END + case when fn2.FacetValue <> fn3.FacetValue then '|'+fn3.FacetValue else '' end end as [Фасет нейм сводный]
	 ,CASE WHEN tp.PackingTypeID = 4 AND tp.ProductGroupID = 13 THEN 'Весовые' ELSE fwseg.FacetValue END AS [Фасет весовой диапазон]
	 ,ffat.FacetValue AS [Фасет шпик]
	 ,fform.FacetValue AS [Фасет форма]
	 ,fstpd.FacetValue AS [Фасет обвязка]
	 ,fsh.FacetValue AS [Фасет оболочка]
	 ,st.[FacetValue] as [Фасет тип среза]
	 ,fnfor.[FacetValue] as [Фасет  написание нейма]
	 ,fnun.[FacetValue] as [Фасет уникальность нейма]
	 ,fntast.[FacetValue] as [Фасет вкусовой нейм]
	 ,fp.[FacetValue] as [Фасет тип упаковки]
	 ,coalesce (pricS.[PriceStartegyNameShort],pricSs.[PriceStartegyNameShort], 'High-Low') as PriceStartegyName
	 ,PriceStrategiesInterval
	 ,case when pricS.PriceStartegyName is not null then 'Федеральное' 
	 when pricSs.PriceStartegyName is not null then 'Региональное' 
	 else null end as StrategyGeo
	 ,case when pricS.PriceStartegyName is not null then null 
	 when pricSs.PriceStartegyName is not null then PriceStrategiesRegions
	 else null end as PriceStrategiesRegions,

--собираем конструктор сводный для даунсайза или смены нейма
NameConstructorWeightClps = isnull(rdn.[ReportNameForConstructor] + ' ', 
	/*Короткое название группы*/
	CASE WHEN pg.AddNameGroup = 1 THEN isnull(pg.ProductGroupShort + ' ', pg.ProductGroup + ' ') ELSE '' END) +  
	/*Подгруппа*/ 
	CASE WHEN pg.AddNameSubGroup = 1 AND rdn.[ReportNameForConstructor] IS NULL AND spg.SubProductGroupID <> 10 THEN isnull(spg.SubProductGroup + ' ', '') ELSE '' END + 
	/*Наименование*/
	CASE WHEN pg.AddNameConstructor = 1 and ncc.[ShortNameForConstructor] is not null THEN ncc.[ShortNameForConstructor] + ' ' 
		 WHEN pg.AddNameConstructor = 1 then isnull(tp.[ShortNameForConstructor] + ' ', '') ELSE '' END + 
	isnull(h.[halalForConstructor]+' ','')+
	/*Тип по весу и серия*/ 
	/*Убран из конструкторов АБИ 29.08.2024*/
	CASE WHEN m.ManufacturerID NOT IN (7) THEN
		CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria<> tm.TradeMark THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
		ELSE '' END + 
	/*Тип упаковки*/ 
	CASE WHEN pg.AddNameShell = 1 THEN isnull(sh.ShellNameShort + ' ', '') ELSE '' END + 
	/*Вес упаковки'*/ 
	CASE WHEN pg.AddNameWeight = 1 THEN CASE WHEN tp.PackingTypeID = 4  THEN 'вес ' 
		 WHEN ncc.[ProductWeight] is not null 
			  THEN ncc.[ProductWeight] + ' '  ELSE REPLACE(CAST(CAST(tp.ProductWeight AS float) AS nvarchar), '.', ',') + 'кг ' END ELSE '' END +
	/*нарезка\кусок\срез*/
	CASE WHEN pg.AddNameform = 1 AND f.FormID not IN (19,24,25,26) /*не определено*/ THEN isnull(f.Name + ' ', '') ELSE '' END +  
	/*Производитель*/
	CASE WHEN pg.AddNameManufactur = 1 AND tp.[ManufacturerID] NOT IN (1672, 1674, 1357) 
							 THEN m.Manufacturer + ' ' ELSE '' END +  
	/*Торговая марка*/
	CASE WHEN pg.AddNameTradeMark = 1 and ncc.TradeMark is not null AND ncc.TradeMark <> m.Manufacturer AND tp.[TradeMarkID] NOT IN (1313, 1009) 
		 THEN ncc.TradeMark + ' ' 
		 WHEN pg.AddNameTradeMark = 1 AND tm.TradeMark <> m.Manufacturer AND tp.[TradeMarkID] NOT IN (1313, 1009) 
			  THEN isnull(tm.TradeMark + ' ', '') ELSE '' END +
	isnull(vki.Viewforconstructor, '')

FROM            prd.[Products] AS tp LEFT OUTER JOIN
                         dbo.vwProductsDM AS p ON p.SKU_DAX_Code = tp.AxaptaCode LEFT JOIN
                         [WHSQLP01\SQLENT].[DM].[Dimensions].[CompetitorProducts] cp ON cp.[ProductCode] = tp.AxaptaCode JOIN
                         [Products].[ProductGroups] pg ON pg.ProductGroupID = tp.ProductGroupID  LEFT JOIN
						  prd.KeyComponents keyc on keyc.KeyComponentID=tp.KeyComponentID left join
                         [Prd].[SegmentGroup] sg ON sg.SegmentGroupID = tp.SegmentGroupID JOIN
                         [Products].[TradeSeries] ts ON ts .TradeSeriaID = tp.TradeSeriaID JOIN
                         [Products].[TradeMarks] tm ON tm.TradeMarkID = tp.TradeMarkID JOIN
                         Products.Forms f ON f.FormID = tp.FormID JOIN
                         [Products].[PackingTypes] pt ON pt.PackingTypeID = tp.PackingTypeID JOIN
                         [Products].[Manufacturers] m ON m.ManufacturerID = tp.ManufacturerID JOIN
						 location.Countries cn on cn.CountryID=m.CountryID 
						 join location.chains sch on tp.[SubChainID]= sch.ChainID JOIN
                         [Products].[Shell] sh ON sh.ShellID = tp.ShellID JOIN
                         [Products].[ProductTypes] pc ON tp.ProductTypeID = pc.ProductTypeID LEFT JOIN
                         [Products].[ManufacturerTypes] mt ON tp.ManufacturerID = mt.ManufacturerID AND tp.ProductTypeID = mt.ProductTypeID LEFT JOIN
                         [Products].[ViewKI] vki ON tp.ViewKiID = vki.ViewKIID LEFT OUTER JOIN
                         [Products].[SubProductGroups] spg ON spg.SubProductGroupID = tp.[ProductSubGroupID] LEFT JOIN
                         [prd].[RelationForDetailGroupName] rdn ON rdn.[Productgroupid] = tp.ProductGroupID AND tp.ProductSubGroupID = isnull(rdn.[Subproductgroupid], tp.ProductSubGroupID) AND tp.cookingtypeid = isnull(rdn.productcookingid, tp.cookingtypeid) 
                         LEFT JOIN
                         [Location].[Chains] ch ON tp.ChainID = ch.ChainID LEFT JOIN
                         nsi.ProductFormat pf ON pf.NSIId = tp.SAPProductTypeID LEFT JOIN
                         [prd].[WeightRangeFilter] wr ON ProductWeight >= wr.[From] AND ProductWeight < wr.[To] AND pg.ProductGroupID = wr.ProductGroupID AND wr.[WeigthType] = 1 /* для таблицы вес купола са*/ LEFT JOIN
                         [prd].[WeightRangeFilter] wr2 ON ProductWeight >= wr2.[From] AND ProductWeight < wr2.[To] AND pg.ProductGroupID = wr2.ProductGroupID AND wr2.[WeigthType] = 2 /* для диаграммы вес купола са*/ 
						 outer apply (select top 1 pn.ProductNameSrc
									from TertiarySales.prd.ProductNameSrcDynamic AS pn
									where tp.ProductCodeConverted = pn.ProductCode AND tp.ChainID = pn.ChainID 
										AND pn.[AddDate] BETWEEN tp.[AddDate] AND tp.SplitDate
									order by  pn.[AddDate]  desc
								)pn

						outer apply (select top 1 mn.ManufacturerSrc
									from TertiarySales.prd.ManufacturerSrcDynamic AS mn
									where tp.ProductCodeConverted = mn.ProductCode 
									AND tp.ChainID = mn.ChainID 
									AND mn.[AddDate] BETWEEN tp.[AddDate] AND tp.SplitDate
									order by  mn.[AddDate]  desc
								)mn
						 left join prd.halal h on h.id = tp.halalid LEFT JOIN
                         [prd].[CookingType] ct ON ct.CookingTypeID = tp.CookingTypeID LEFT JOIN
                         [NSI].[Categories] nsicat ON nsicat.NSIId = tp.NSICategoryID LEFT JOIN
                         [prd].[vwFullConstructorProducts] fullname ON fullname.productid = tp.ProductID
						 left join [facet].[MeatType] fmt on fmt.[FacetValueID] = tp.[FT_MeatType_ID]
						 left join [facet].[IsSmoked] fis on fis.[FacetValueID] = tp.[FT_IsSmoked_ID]
						 left join [facet].[ConsumptSituation] fсs on fсs.[FacetValueID] = tp.[FT_ConsumptSituation_ID]
						 left join [facet].[TasteInclusion] fti on fti.[FacetValueID] = tp.[FT_TasteInclusion_ID]
						 left join [facet].[MeatInclusion] fmi on fmi.[FacetValueID] = tp.[FT_MeatInclusion_ID]
						 left join [facet].[Chopped] fch on fch.[FacetValueID] = tp.[FT_Chopped_ID]
						 left join [facet].[Baby] fbab on fbab.[FacetValueID] = tp.[FT_Baby_ID]
						 left join [facet].[Name] fn1 on fn1.[FacetValueID] = tp.[FT_NameLvl1_ID]
						 left join [facet].[Name] fn2 on fn2.[FacetValueID] = tp.[FT_NameLvl2_ID]
						 left join [facet].[Name] fn3 on fn3.[FacetValueID] = tp.[FT_NameLvl3_ID]
						 left join [facet].[PackSize] fps on fps.[FacetValueID] = tp.[FT_PackSize_ID]
						 --left join [facet].[Thickness] fth on fth.[FacetValueID] = tp.[FT_Thickness_ID]
						 left join [facet].[Halal] fhal on fhal.[FacetValueID] = tp.[FT_Halal_ID]
						 left join [facet].[GOST] fgost on fgost.[FacetValueID] = tp.[FT_GOST_ID]
						 left join [facet].[PrdSize] fprs on fprs.[FacetValueID] = tp.[FT_PrdSize_ID]
						 left join [facet].[Fat] ffat on ffat.[FacetValueID] = tp.[FT_Fat_ID]
						 left join [facet].[Form] fform on fform.[FacetValueID] = tp.[FT_Form_ID]
						 left join [facet].[Strapped] fstpd on fstpd.[FacetValueID] = tp.[FT_Strapped_ID]
						 left join [facet].[Shell] fsh on fsh.[FacetValueID] = tp.[FT_Shell_ID]
						 LEFT JOIN [facet].[WeightSegment] fwseg ON (tp.ProductGroupID = fwseg.ProductGroupID) AND (tp.ProductWeight >= fwseg.FromValue AND tp.ProductWeight < fwseg.TOValue)
						 left join [facet].[SliceType] st on st.[FacetValueID] = tp.[FT_SliceType_ID]
						 left join [TertiarySales].[facet].[NameForeign] fnfor on fnfor.[FacetValueID] = tp.[FT_NameForeign_ID]
						 left join [TertiarySales].[facet].[NameUnique] fnun on fnun.[FacetValueID] = tp.[FT_NameUnique_ID]
						 left join [TertiarySales].[facet].[NameTaste] fntast on fntast.[FacetValueID] = tp.[FT_NameTaste_ID]
						 left join [TertiarySales].[facet].[Packing] fp on fp.[FacetValueID] = tp.[FT_Packing_ID]
						 ---пробыный вывод потенциальных EDLP/EDPP для сетей МАгнит и Пятерочка
						 left join ( 
							select distinct ProductID, max(PriceStrategyID) over (partition by ProductID) as PriceStrategyID  from [edpp].[ProductPriceStrategiesAllGeo]) pps on pps.ProductID = tp.ProductID
						 left join (
							select distinct ProductID, STRING_AGG(cast ([FromDate] as nvarchar (max))+':'+cast ([ToDate]as nvarchar (max)), ', ') as PriceStrategiesInterval 
							from [edpp].[ProductPriceStrategiesAllGeo] group by ProductID ) pps2 on pps2.ProductID = tp.ProductID

						 left join [prd].[PriceStrategies] pricS on pricS.PriceStrategyID = pps.PriceStrategyID

						 left join ( 
							select distinct ProductID, max(PriceStrategyIDAllGeo) over (partition by ProductID) as PriceStrategyIDAllGeo  from [edpp].[ProductPriceStrategiesRegions]) ppsr on ppsr.ProductID = tp.ProductID
						 
						 left join (select distinct ProductID, STRING_AGG(cast (Region as nvarchar (max)), ', ') as PriceStrategiesRegions 
							from(select distinct ProductID,r.Region
							from [edpp].[ProductPriceStrategiesRegions]  ppsr1 
							join [Location].[Regions] r on r.RegionID =  ppsr1.RegionID) t
                            group by ProductID)  ppsr2 on ppsr2.ProductID = tp.ProductID
						 
						 left join [prd].[PriceStrategies] pricSs on pricSs.[PriceStrategyID] = ppsr.PriceStrategyIDAllGeo
						 left join [TertiarySales].[prd].[viewNCClpsAttr] ncc on ncc.[DuplicatedProductID] = tp.DuplicatedProductID
						 --left join [TertiarySales].[Products].[CompanyGroup] GK on GK.[ManufacturerID]=tp.[ManufacturerID] ---12.03.2024 GK Илья дегтярь
		--where tp.[DuplicatedProductID]=140846				 
		
GO


