WITH TTT AS (
    SELECT DISTINCT
        [Сеть покупки],
        bbb.ProductID,
        [NameConstructorWeight_NOGOST],
        [TradeSeria],
        Nomer_const
    FROM (
        SELECT *,
               COUNT([Сеть покупки]) OVER (
                   PARTITION BY Nomer_const, [NameConstructorWeight_NOGOST], [Сеть покупки]
               ) AS KOL_SET_const
        FROM (
            SELECT 
                modelZOT.[Сеть покупки],
                modelZOT.ProductID,
                modelZOT.[NameConstructorWeight_NOGOST],
                modelZOT.[TradeSeria],
                Nomer_const
            FROM [TertiarySales].[model].[Products_ZOTOV_TEST] modelZOT
            JOIN (
                SELECT *,
                       ROW_NUMBER() OVER (ORDER BY [NameConstructorWeight_NOGOST]) AS Nomer_const
                FROM (
                    SELECT DISTINCT
                        [TradeMark],
                        [ProductGroup],
                        [NameConstructorWeight_NOGOST],
                        cn
                    FROM (
                        SELECT *,
                               COUNT([TradeSeria]) OVER (PARTITION BY [NameConstructorWeight_NOGOST]) AS cn
                        FROM (
                            SELECT DISTINCT
								[TradeMark],
                                [ProductGroup],
                                [TradeSeria],
                                [NameConstructorWeight_NOGOST]
                            FROM [TertiarySales].[model].[Products_ZOTOV_TEST]
                            WHERE [ProductGroup] IN (
                                'Колбасы вареные', 'Колбасы копченые',
                                'Колбасы сыровяленые', 'Колбасы сырокопченые',
                                'Пельмени', 'Деликатесы', 'Сосиски', 'Сардельки'
                            )
                            AND [TradeMark] <> 'СТМ Глобус'
                            AND [TradeMark] <> 'Не определено'
                        ) aa
                    ) bb
                    WHERE cn > 1
                ) cc
            ) dd ON modelZOT.[NameConstructorWeight_NOGOST] = dd.[NameConstructorWeight_NOGOST]
        ) aaa
    ) bbb
)

SELECT
    tabl_osn.[Сеть покупки],
    tabl_osn.ProductID,
    tabl_osn.[NameConstructorWeight_NOGOST],
    tabl_osn.[TradeSeria],
    Nomer_const,
    KOL_per,
    [ProductName],
    [ManufacturerSource],
    ishod.[NameConstructorWeight]
FROM (
    SELECT DISTINCT
        [Сеть покупки],
        TTT.ProductID,
        [NameConstructorWeight_NOGOST],
        [TradeSeria],
        Nomer_const
    FROM TTT
) tabl_osn
LEFT JOIN (
    SELECT DISTINCT
        ProductID_1,
        [Сеть_покупки_1],
        NameConstructorWeight_1,
        [TradeSeria_1],
        Nomer_const_1,
        KOL_per
    FROM (
        SELECT *,
               COUNT([Date_1]) OVER (PARTITION BY ProductID_1) AS KOL_per
        FROM (
            SELECT 
                tabl1.ProductID AS ProductID_1,
                tabl2.ProductID AS ProductID_2,
                tabl1.[Сеть покупки] AS [Сеть_покупки_1],
                tabl1.[NameConstructorWeight_NOGOST] AS NameConstructorWeight_1,
                tabl1.[TradeSeria] AS [TradeSeria_1],
                tabl1.Nomer_const AS Nomer_const_1,
                tabl1.[Date] AS [Date_1]
            FROM (
                SELECT DISTINCT
                    [Сеть покупки],
                    TTT.ProductID,
                    [NameConstructorWeight_NOGOST],
                    [TradeSeria],
                    Nomer_const,
                    [Date]
                FROM TTT
                JOIN [TertiarySales].[fcts].[Facts] fact ON TTT.ProductID = fact.ProductID
            ) tabl1
            JOIN (
                SELECT DISTINCT
                    [Сеть покупки],
                    TTT.ProductID,
                    [NameConstructorWeight_NOGOST],
                    [TradeSeria],
                    Nomer_const,
                    [Date]
                FROM TTT
                JOIN [TertiarySales].[fcts].[Facts] fact ON TTT.ProductID = fact.ProductID
) tabl2 ON tabl2.ProductID <> tabl1.ProductID
                   AND tabl2.[Date] = tabl1.[Date]
                   AND tabl1.[NameConstructorWeight_NOGOST] = tabl2.[NameConstructorWeight_NOGOST]
                   AND tabl1.[Сеть покупки] = tabl2.[Сеть покупки]
        ) DDD
    ) eee
) fff ON tabl_osn.ProductID = fff.ProductID_1
JOIN [TertiarySales].[model].[Products] ishod ON tabl_osn.ProductID = ishod.ProductID
ORDER BY Nomer_const, tabl_osn.[NameConstructorWeight_NOGOST], tabl_osn.[Сеть покупки];