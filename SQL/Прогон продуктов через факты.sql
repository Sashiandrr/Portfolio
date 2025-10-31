WITH mainrec AS (
	SELECT TOP(100)
		[ИД рецептурное Уникальное],
		[ИД рецептурное общее] 
	FROM (
		SELECT    
			[ИД рецептурное Уникальное],
			[ИД рецептурное общее],
			COUNT([ИД рецептурное Уникальное]) OVER (PARTITION BY [ИД рецептурное общее]) AS [cn]
		FROM [WHSQLP02].[MarketingReportDWH].[TML].[TMLforTwoSales'] t (NOLOCK)
		GROUP BY [ИД рецептурное Уникальное],[ИД рецептурное общее]
	) t 
	WHERE cn > 1
), sales AS (
	SELECT
		c.[Year],
		f.[SK_Date_ID],
		f.[SalesPlaceID],
		f.[SK_Distributor_ID],
		f.[SK_Position_ID],
		f.[SKU_SKU_ID],
		f.[Weight], --отгружено кг
		f.[Quantity],  -- отгружено шт
	    f.[WeightBonus], --бонус кг 31.10.2025
        f.[QTYBonus], --бонус шт 31.10.2025
        f.[CostBonus], --бонус руб 31.10.2025
		f.[Amount], --отгружено рую
		f.[Returns], --возврат кг
		f.[Quantity_R], --возвращено шт
		f.[Amount_R], --возвращено руб
		f.[Docno],
		t.[OblastTM] + CAST(p.[SAPRecipeSKUID] AS NVARCHAR(10)) AS [fortmlkey],
		t.[OblastTM] + CAST(ISNULL([ИД рецептурное общее], p.[SAPRecipeSKUID]) AS NVARCHAR(10)) AS [fortml],
		ISNULL(N'nsi' + CAST([NSI_FK_Double] AS NVARCHAR(64)), N'sp'+CAST(tt.TT_Chicago_Code AS NVARCHAR(64))) + '-' + f.[SKU_SKU_ID] AS [skutt],
		ISNULL(N'nsi' + CAST([NSI_FK_Double] AS NVARCHAR(50)), N'sp'+CAST(tt.TT_Chicago_Code AS NVARCHAR(50))) AS [forakb],
		ISNULL(N'nsi' + CAST([NSI_FK_Double] AS NVARCHAR(50)), N'sp'+CAST(tt.TT_Chicago_Code AS NVARCHAR(50))) + '-' + p.[SalesUnitCode] AS [forakb_epcode], --[SalesUnitCode] - [ЕП Код]
		ISNULL(N'nsi' + CAST([NSI_FK_Double] AS NVARCHAR(50)), N'sp'+CAST(tt.TT_Chicago_Code AS NVARCHAR(50))) + CAST(f.[SK_Date_ID] AS NVARCHAR(8)) AS [ttdate]
	FROM [DM].[SalesAnalyst].[SellOut] f (NOLOCK)
	JOIN [DM].[SalesAnalyst].[BuyPoints] tt (NOLOCK) ON f.[SalesPlaceID] = tt.[SalesPlaceID] AND tt.[CategoryTT] = N'ТТ'
	JOIN [DM].[SalesAnalyst].[Distributors] d (NOLOCK) ON f.[SK_Distributor_ID] = d.[SK_Distributor_ID] 
		AND d.[StateName] IN (N'Данные корректны. Площадка сдана', N'Данные не корректны. Площадка сдана', N'Площадка закрыта', N'Внутреннее тестирование', N'Unknown')
	JOIN [DM].[SalesAnalyst].[Products] p (NOLOCK) ON f.[SKU_SKU_ID] = p.[SKU_DAX_Code]
	JOIN [DM].[SalesAnalyst].[Calendars] c (NOLOCK) ON f.[SK_Date_ID] = c.[SK_Date_ID] --AND c.[Year] = 2022 --!! Фильтр !!--
	LEFT JOIN [DM].[SalesAnalyst].[Positions] t (NOLOCK) ON tt.[TerritoryOfRespobilityCode] = t.[SK_Position_ID]
	LEFT JOIN mainrec mr ON p.[SAPRecipeSKUID] = mr.[ИД рецептурное Уникальное]
), sales_archive AS (
	SELECT
		c.[Year],
		f.[SK_Date_ID],
		f.[SalesPlaceID],
		f.[SK_Distributor_ID],
		f.[SK_Position_ID],
		f.[SKU_SKU_ID],
		f.[Weight],
		f.[Quantity],
		 f.[WeightBonus], --бонус кг
         f.[QTYBonus], --бонус шт
         f.[CostBonus], --бонус руб
		f.[Amount],
		f.[Returns],
		f.[Quantity_R],
		f.[Amount_R],
		f.[Docno],
		t.[OblastTM] + CAST(p.[SAPRecipeSKUID] AS NVARCHAR(10)) AS [fortmlkey],
		t.[OblastTM] + CAST(ISNULL([ИД рецептурное общее], p.[SAPRecipeSKUID]) AS NVARCHAR(10)) AS [fortml],
		ISNULL(N'nsi' + CAST([NSI_FK_Double] AS NVARCHAR(64)), N'sp'+CAST(tt.TT_Chicago_Code AS NVARCHAR(64))) + '-' + f.[SKU_SKU_ID] AS [skutt],
		ISNULL(N'nsi' + CAST([NSI_FK_Double] AS NVARCHAR(50)), N'sp'+CAST(tt.TT_Chicago_Code AS NVARCHAR(50))) AS [forakb],
		ISNULL(N'nsi' + CAST([NSI_FK_Double] AS NVARCHAR(50)), N'sp'+CAST(tt.TT_Chicago_Code AS NVARCHAR(50))) + '-' + p.[SalesUnitCode] AS [forakb_epcode], --[SalesUnitCode] - [ЕП Код]
		ISNULL(N'nsi' + CAST([NSI_FK_Double] AS NVARCHAR(50)), N'sp'+CAST(tt.TT_Chicago_Code AS NVARCHAR(50))) + CAST(f.[SK_Date_ID] AS NVARCHAR(8)) AS [ttdate]
	FROM [DM].[SalesAnalyst].[SellOut_Archive] f (NOLOCK)
	JOIN [DM].[SalesAnalyst].[BuyPoints] tt (NOLOCK) ON f.[SalesPlaceID] = tt.[SalesPlaceID] AND tt.[CategoryTT] = N'ТТ'
	JOIN [DM].[SalesAnalyst].[Distributors] d (NOLOCK) ON f.[SK_Distributor_ID] = d.[SK_Distributor_ID] 
		AND d.[StateName] IN (N'Данные корректны. Площадка сдана', N'Данные не корректны. Площадка сдана', N'Площадка закрыта', N'Внутреннее тестирование', N'Unknown')
	JOIN [DM].[SalesAnalyst].[Products] p (NOLOCK) ON f.[SKU_SKU_ID] = p.[SKU_DAX_Code]
	JOIN [DM].[SalesAnalyst].[Calendars] c (NOLOCK) ON f.[SK_Date_ID] = c.[SK_Date_ID] --AND c.[Year] = 2022 --!! Фильтр !!--
	LEFT JOIN [DM].[SalesAnalyst].[Positions] t (NOLOCK) ON tt.[TerritoryOfRespobilityCode] = t.[SK_Position_ID]
	LEFT JOIN mainrec mr ON p.[SAPRecipeSKUID] = mr.[ИД рецептурное Уникальное]
), positions AS (
	SELECT 
		p.[SK_Position_ID],
		p.[ResponsibilityArea] AS [Территория отвественности],
		p.[OblastTM] AS [oblast],
		p.[NDFIO],
		p.[DDFIO],
		CASE 
			WHEN p.[Level] = 4 THEN p.[ResponsibilityArea]
			WHEN p2.[Level] = 4 THEN p2.[ResponsibilityArea]
			WHEN p3.[Level] = 4 THEN p3.[ResponsibilityArea]
			WHEN p4.[Level] = 4 THEN p4.[ResponsibilityArea]
			WHEN p5.[Level] = 4 THEN p5.[ResponsibilityArea]
		END AS [НД],
		CASE WHEN p.[TeamType] = 'ЭТК' THEN p.[TPTFIO] ELSE '' END AS [ТПОтветственный],
		CASE WHEN p.[TPTFIO] = '' THEN NULL ELSE p.[TeamType] END AS [TeamType],
		ISNULL(
			r.[SortMarket],
			CASE WHEN LEN(p.[OblastTM]) > 3 THEN 'Россия' ELSE NULL END)
		AS [Зарубежье],
		CASE 
			WHEN r.[SortMarket] = 'Зарубежный' THEN r.[Name] 
			WHEN p.[OblastTM] = 'Не определено' THEN NULL 
			WHEN /*len(p.[OblastTM])>3*/r.[SortMarket] = 'Россия' THEN 'Россия' 
			WHEN LEN(p.[OblastTM]) > 3 THEN 'Россия' 
			ELSE NULL 
		END AS [Страна ТМ]
	FROM [DM].[SalesAnalyst].[Positions] p (NOLOCK)
	LEFT JOIN (
		SELECT DISTINCT 
			r.[RegionCode], 
			r.[SortMarket], 
			r.[Name]
		FROM [SalesAnalyst].[RegionNCI] r (NOLOCK) 
	) r ON r.[RegionCode] = CAST(RIGHT([OblastTMID], 4) AS INT) AND [OblastTMID] > 20000000
	LEFT JOIN [DM].[SalesAnalyst].[Positions] p2 (NOLOCK) ON p2.[SK_Position_ID] = p.[Parent_SK_Position_ID] 
	LEFT JOIN [DM].[SalesAnalyst].[Positions] p3 (NOLOCK) ON p3.[SK_Position_ID] = p2.[Parent_SK_Position_ID] 
	LEFT JOIN [DM].[SalesAnalyst].[Positions] p4 (NOLOCK) ON p4.[SK_Position_ID] = p3.[Parent_SK_Position_ID] 
	LEFT JOIN [DM].[SalesAnalyst].[Positions] p5 (NOLOCK) ON p5.[SK_Position_ID] = p4.[Parent_SK_Position_ID]
), ret AS (
	SELECT 
		r.[RetailChainID],
		iif(r.[Родитель] = 0, r.[Наименование розничной сети], r2.[Наименование розничной сети]) AS [Наименование розничной сети],
		r.[Код розничной сети]
	FROM [DM].[SalesAnalyst].[RetailChains] AS r (NOLOCK)
	JOIN [DM].[SalesAnalyst].[RetailChains] AS r2 (NOLOCK) ON r.[Родитель] = r2.[RetailChainID]
), tt AS (
	SELECT
		tt.[CategoryTT],
		CASE WHEN tt.[TT_Chicago_Code] IS NOT NULL THEN 'Чикаго' ELSE 'Третичка сбыт' END AS [Справочник], 
		tt.[TT_Chicago_Code],
		tt.[SalesPlaceID],
		tt.[Owner] AS [Владелец ТТ],
		tt.[Provider] AS [Поставщик],
		tt.[NameTT] AS [Наименование ТТ],
		tt.[TT_NSI_Code],
		ISNULL(tt.[AdressTT_Chicago], tt.[AdressTT]) AS [Адрес ТТ], --поменял[AdressTT_NSI] на [AdressTT_Chicago]
		tt.[AdressTT_Chicago],
		tt.[AdressTT],
		tt.[AdressTT_NSI] AS [ТТ адрес НСИ],
		tt.[ChaineName] AS [Сеть],
		tt.[ChainCode] AS [Код нси сети],
		ret.[Наименование розничной сети] AS [Родительская сеть],
		tt.[FormatTT] AS [Формат точки],
		tt.[RegionTT] AS [ОбластьТТ],
		tt.[CodeChannel],
		--ISNULL(er.[SalesChannel],tt.[SalesChannel]) [Канал продаж],
		tt.[SalesChannel] AS [Канал продаж],
		tt.[SalesChannelPlan] AS [Направление],
		tt.[TypeChannel] AS [Тип канала],
		CASE 
			WHEN tt.[TypeChannel] IN (N'Остальные локальные сети', N'Розница') THEN N'Розница'
			WHEN tt.[TypeChannel] IN (N'ОПТ') THEN N'ОПТ'
			WHEN tt.[TypeChannel] IN (N'Федеральные сети') AND [TT_Chicago_Code] IS NULL THEN N'НКК Сбыт'
			WHEN tt.[TypeChannel] IN (/*N'Остальные локальные сети',*/N'Топ-локальные сети') THEN N'ЛКК' -- Остальные локальные сети перенос в розницу запрос от алины 01.07.2025
			ELSE 'Остальное'
		END [Тип канала общий],
		t.[SK_Position_ID],
		t.[НД],
		t.[Территория отвественности],
		tt.[CategoryTT] AS [КатегорияТТ],
		t.[oblast] AS [ОбластьТМ], 
		t.[Зарубежье],
		t.[Страна ТМ],
		t.[NDFIO] AS [НД Ответственный],
		t.[DDFIO] AS [ДД Ответственный],
		tt.[RegionCalc],
		ISNULL(N'nsi' + CAST(tt.[NSI_FK_Double] AS NVARCHAR(50)), N'sp' + CAST(tt.[SalesPlaceID] AS NVARCHAR(50))) AS [foracb]
	FROM [DM].[SalesAnalyst].[BuyPoints] tt (NOLOCK)
	LEFT JOIN positions AS t ON tt.[TerritoryOfRespobilityCode] = t.[SK_Position_ID]
	LEFT JOIN ret ON tt.[ChainCode] = ret.[Код розничной сети]
)

SELECT 
	--COUNT(*) 
	--TOP(100)
	[SK_Date_ID],
	[SalesPlaceID],
	[SK_Distributor_ID],
	[SK_Position_ID],
	[SKU_SKU_ID],
	[Weight],
	[Quantity],
		 [WeightBonus], --бонус кг
         [QTYBonus], --бонус шт
         [CostBonus], --бонус руб
	[Amount],
	[Returns],
	[Quantity_R],
	[Amount_R],
	[Docno],
	[fortmlkey],
	[fortml],
	[skutt],
	[forakb],
	[forakb_epcode], --[SalesUnitCode] - [ЕП Код]
	[ttdate]
FROM sales_archive
WHERE [Year] = 2018