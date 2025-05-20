WITH t AS (
    SELECT DISTINCT 
        [OutletID],
        [NSIID_Maindouble],
        [ChainID],
        [OutletAddress],
        [OutletTypeID],
        [Date],
        [OutletNumber],
        [DuplicatedOutletID],
        KolichDubley
    FROM (
        SELECT *,
               COUNT([OutletID]) OVER (PARTITION BY [DuplicatedOutletID]) AS KolichDubley
        FROM (
            SELECT DISTINCT 
                dt1.[OutletID],
                dt1.[NSIID_Maindouble],
                dt1.[OutletAddress],
                dt1.[Date],
                dt1.[ChainID],
                dt1.[OutletNumber],
                dt1.[OutletTypeID],
                dt1.[DuplicatedOutletID],
                dt2.[OutletID] AS OutletID2,
                dt2.[NSIID_Maindouble] AS NSIID_Maindouble2,
                dt2.[OutletAddress] AS OutletAddress2,
                dt2.[Date] AS DateT2,
                dt2.[OutletNumber] AS OutletNumber2,
                dt2.[OutletTypeID] AS OutletTypeID2,
                dt2.[DuplicatedOutletID] AS DuplicatedOutletID2
            FROM (
                SELECT DISTINCT 
                    f.[OutletID],
                    [NSIID_Maindouble],
                    [OutletAddress],
                    [ChainID],
                    [Date],
                    [OutletNumber],
                    [DuplicatedOutletID],
                    [OutletTypeID]
                FROM [TertiarySales].[fcts].[Facts] f
                JOIN (
                    SELECT RR.[OutletID],
                           [ChainID],
                           [OutletAddress],
                           [OutletNumber],
                           [NSIID_Maindouble],
                           [DuplicatedOutletID],
                           [OutletTypeID],
                           [CN]
                    FROM (
                        SELECT [OutletID],
                               [ChainID],
                               [OutletAddress],
                               [OutletNumber],
                               [DuplicatedOutletID],
                               [OutletTypeID],
                               [NSIID_Maindouble],
                               COUNT(*) OVER (PARTITION BY [DuplicatedOutletID]) AS CN
                        FROM [TertiarySales].[Location].[Outlets]
                    ) RR
                    WHERE CN > 1
                ) o ON o.OutletID = f.OutletID
            ) dt1

            JOIN (
                SELECT DISTINCT 
                    f.[OutletID],
                    [NSIID_Maindouble],
                    [OutletAddress],
                    [ChainID],
                    [Date],
                    [OutletNumber],
                    [DuplicatedOutletID],
                    [OutletTypeID]
                FROM [TertiarySales].[fcts].[Facts] f
                JOIN (
                    SELECT RR.[OutletID],
                           [ChainID],
                           [OutletAddress],
                           [OutletNumber],
                           [NSIID_Maindouble],
                           [DuplicatedOutletID],
                           [OutletTypeID],
                           [CN]
                    FROM (
                        SELECT [OutletID],
                               [ChainID],
                               [OutletAddress],
                               [OutletNumber],
                               [OutletTypeID],
                               [NSIID_Maindouble],
                               [DuplicatedOutletID],
                               COUNT(*) OVER (PARTITION BY [DuplicatedOutletID]) AS CN
                        FROM [TertiarySales].[Location].[Outlets]
                    ) RR
                    WHERE CN > 1
                ) o ON o.OutletID = f.OutletID
            ) dt2 
            ON dt1.[DuplicatedOutletID] = dt2.[DuplicatedOutletID]
            AND dt1.OutletID <> dt2.OutletID
            AND dt1.Date = dt2.Date
        ) tabl
    ) gg 
    WHERE KolichDubley > 1
)

SELECT *
FROM (
    SELECT *,
COUNT([NSIID_Maindouble]) OVER (PARTITION BY [NSIID_Maindouble]) AS KolichNsiDub
    FROM t
) atd
WHERE CASE 
          WHEN KolichDubley = KolichNsiDub THEN 0 
          ELSE 1 
      END = 1
ORDER BY [DuplicatedOutletID];