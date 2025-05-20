USE [TertiarySales]
GO
/****** Object:  StoredProcedure [facet].[spUpdateFacetByLogs]    Script Date: 25.07.2024 17:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [facet].[spUpdateFacetByLogs]


AS
BEGIN

SET NOCOUNT ON;
 /* UPDATE prd
SET prd.[DuplicatedProductID] = update_prd.[DuplicatedProductID]
FROM prd.products prd
JOIN (
	SELECT p.ProductID,
		[DuplicatedProductID] = CASE WHEN [Флаг Полный конструктор] = 'Да' THEN MinID ELSE p.productid END
	FROM prd.Products AS p
	JOIN (
		SELECT ProductID, [Флаг Полный конструктор], MinID 
		FROM (
			SELECT mp.ProductID, [Флаг Полный конструктор],
			MinID = MIN(mp.ProductID) OVER (PARTITION BY [NameConstructorWeight])
			FROM [TertiarySales].[model].[Products] AS mp
			JOIN [prd].[Products] AS pp ON pp.ProductID = mp.ProductID
		) AS temp1
	) AS temp2 ON temp2.ProductID = p.ProductID
) AS update_prd 
ON update_prd.ProductID = prd.ProductID 
	AND (prd.[DuplicatedProductID] IS NULL OR prd.[DuplicatedProductID]<> update_prd.[DuplicatedProductID])*/

-- Обработка фасетов на основе изменений продуктовых атрибутов из таблицы логов

declare @Amount_day int = '-10' 
declare @from_date DATE = (DATEADD(day, @Amount_day, convert(date, GETDATE()))) -- ЕСли NULL, то за все периоды
declare @to_date DATE = (DATEADD(day, +1, convert(date, GETDATE())))



declare @ID_Dobl_Update as nvarchar(max) ='select 
distinct [ProductID]
  FROM [TertiarySales].[logs].[TblChanges_prdProducts]  as LOGS 
where  (LOGS.RecordDate BETWEEN '''+cast(@from_date AS nvarchar(max))+''' AND '''+cast(@to_date AS nvarchar(max))+''' and (
[ColumnName]=''DuplicatedProductID''  ))  and  ( not exists (select [ChangeID] from [TertiarySales].[dbo].[ZOT_facet_upd] t2 where t2.[ChangeID] =LOGS.[Id] ))'

declare @Ins_ID_DUBL table (ProductID int)
insert into @Ins_ID_DUBL  EXECUTE sp_executesql @ID_Dobl_Update


/*_____апдейт нулл на не нулл но вместо условия на нулл будут айти с фитром на группу Вареные колбасы_________*/

	update [TertiarySales].[prd].[Products] set
       [FT_MeatType_ID]=Tabl_na_Update.[FT_MeatType_ID]
      ,[FT_IsSmoked_ID]=Tabl_na_Update.[FT_IsSmoked_ID]
      ,[FT_ConsumptSituation_ID]=Tabl_na_Update.[FT_ConsumptSituation_ID]
      ,[FT_TasteInclusion_ID]=Tabl_na_Update.[FT_TasteInclusion_ID]
      ,[FT_MeatInclusion_ID]=Tabl_na_Update.[FT_MeatInclusion_ID]
      ,[FT_Chopped_ID]=Tabl_na_Update.[FT_Chopped_ID]
      ,[FT_Baby_ID]=Tabl_na_Update.[FT_Baby_ID]
      ,[FT_NameLvl1_ID]=Tabl_na_Update.[FT_NameLvl1_ID]
      ,[FT_NameLvl2_ID]=Tabl_na_Update.[FT_NameLvl2_ID]
      ,[FT_NameLvl3_ID]=Tabl_na_Update.[FT_NameLvl3_ID]
      ,[FT_PackSize_ID]=Tabl_na_Update.[FT_PackSize_ID]
      ,[FT_Halal_ID]=Tabl_na_Update.[FT_Halal_ID]
      ,[FT_GOST_ID]=Tabl_na_Update.[FT_GOST_ID]
	   ,[FT_Fat_ID]=Tabl_na_Update.[FT_Fat_ID]
	    ,[FT_Form_ID]=Tabl_na_Update.[FT_Form_ID]
		 ,[FT_Strapped_ID]=Tabl_na_Update.[FT_Strapped_ID]
		  ,[FT_Shell_ID]=Tabl_na_Update.[FT_Shell_ID]
		   ,[FT_Category_ID]=Tabl_na_Update.[FT_Category_ID]
										  from [TertiarySales].[prd].[Products] prd join  (
											select /*выборка столбцов которые только для варнеок, они будут апдейтины, это для тех у кого сменился только дубль*/
											[ProductID],
											 nully.NameConstructorWeight1 ,
											prodNOTnull.[DuplicatedProductID], 
											prodNOTnull.[FT_MeatType_ID] ,
											prodNOTnull.[FT_IsSmoked_ID] ,
											prodNOTnull.[FT_ConsumptSituation_ID] ,
											prodNOTnull.[FT_TasteInclusion_ID] ,
											prodNOTnull.[FT_MeatInclusion_ID] ,
											prodNOTnull.[FT_Chopped_ID] ,
											prodNOTnull.[FT_Baby_ID] ,
											prodNOTnull.[FT_NameLvl1_ID] ,
											prodNOTnull.[FT_NameLvl2_ID] ,
											prodNOTnull.[FT_NameLvl3_ID] ,
											prodNOTnull.[FT_PackSize_ID] ,
											prodNOTnull.[FT_Halal_ID] ,
											prodNOTnull.[FT_GOST_ID] ,
											 prodNOTnull.FT_Fat_ID,
											 prodNOTnull.FT_Form_ID,
											 prodNOTnull.FT_Strapped_ID,
											 prodNOTnull.FT_Shell_ID,
											 prodNOTnull.FT_Category_ID from (
SELECT prd.[ProductID], /*продукты у которыхфасеты ВСЕ нуловые, ищем их чтобы сджойниться к СКЮ с уже определными фасетами, выполнятется после правки ошибок с разынми фасетами */
		 NameConstructorWeight as NameConstructorWeight1 ,
		[DuplicatedProductID] ,
		[FT_MeatType_ID] ,
		[FT_IsSmoked_ID] ,
		[FT_ConsumptSituation_ID] ,
		[FT_TasteInclusion_ID] ,
		[FT_MeatInclusion_ID] ,
		[FT_Chopped_ID] ,
		[FT_Baby_ID] ,
		[FT_NameLvl1_ID] ,
		[FT_NameLvl2_ID] ,
		[FT_NameLvl3_ID] ,
		[FT_PackSize_ID] ,
		[FT_Halal_ID] ,
		[FT_GOST_ID] ,
		 FT_Fat_ID,
		 FT_Form_ID,
		 FT_Strapped_ID,
		 FT_Shell_ID,
		 FT_Category_ID
	FROM [TertiarySales].[prd].[Products] prd
	JOIN model.Products model
		ON model.[ProductID]=prd.[ProductID] join @Ins_ID_DUBL as DUB on DUB.[ProductID]=prd.[ProductID] 
	WHERE prd.[ProductGroupID]=16 ) nully
left  JOIN 
	(select * from (select  COUNT (*) 
	    over (partition by DuplicatedProductID) kol_dubley,* from(
SELECT DISTINCT -- тут идет поиск всех СКЮ у котрых фасеты не НУЛЛ полностью, с ними будет джойнится таблица выше 
	    NameConstructorWeight as NameConstructorWeight ,
		DuplicatedProductID,
	   	[FT_MeatType_ID] ,
		[FT_IsSmoked_ID] ,
		[FT_ConsumptSituation_ID] ,
		[FT_TasteInclusion_ID] ,
		[FT_MeatInclusion_ID] ,
		[FT_Chopped_ID] ,
		[FT_Baby_ID] ,
		[FT_NameLvl1_ID] ,
		[FT_NameLvl2_ID] ,
		[FT_NameLvl3_ID] ,
		[FT_PackSize_ID] ,
		[FT_Halal_ID] ,
		[FT_GOST_ID] ,
		FT_Fat_ID,
		FT_Form_ID,
		FT_Strapped_ID,
		FT_Shell_ID,
		FT_Category_ID
	FROM [TertiarySales].[prd].[Products] prdclassic
	JOIN model.Products model
		ON model.[ProductID]=prdclassic.[ProductID]
	WHERE prdclassic.[ProductGroupID]=16
			AND ([FT_MeatType_ID] is NOT null
			AND [FT_IsSmoked_ID] is NOT null
			AND [FT_ConsumptSituation_ID] is NOT null
			AND [FT_TasteInclusion_ID] is NOT null
			AND [FT_MeatInclusion_ID] is NOT null
			AND [FT_Chopped_ID] is NOT null
			AND [FT_Baby_ID] is NOT null
			AND [FT_NameLvl1_ID] is NOT null
			AND [FT_NameLvl2_ID] is NOT null
			AND [FT_NameLvl3_ID] is NOT null
			AND [FT_PackSize_ID]is NOT null
			AND [FT_Halal_ID] is NOT null
			AND [FT_GOST_ID] is NOT null
			AND FT_Fat_ID is NOT NULL
			AND FT_Form_ID is  NOT NULL
			AND FT_Strapped_ID is NOT NULL
			AND FT_Shell_ID is NOT NULL
			AND FT_Category_ID is not null) and ( not exists (select [ProductID] from @Ins_ID_DUBL t2 where t2.[ProductID] =prdclassic.[ProductID])) ) as Tabl_count_dubl )Tab2_count_dubl where kol_dubley=1
			
 ) prodNOTnull ON prodNOTnull.DuplicatedProductID=nully.DuplicatedProductID 
) Tabl_na_Update on Tabl_na_Update.[ProductID]=prd.[ProductID]

/*_____апдейт нулл на не нулл но вместо условия на нулл будут айти с фитром на группу Вареные колбасы_________*/

/*_____СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ__________*/
	update [TertiarySales].[prd].[Products] set
       [FT_MeatType_ID]=Tabl_na_Update.[FT_MeatType_ID]
      ,[FT_IsSmoked_ID]=Tabl_na_Update.[FT_IsSmoked_ID]
      ,[FT_ConsumptSituation_ID]=Tabl_na_Update.[FT_ConsumptSituation_ID]
      ,[FT_TasteInclusion_ID]=Tabl_na_Update.[FT_TasteInclusion_ID]
      ,[FT_MeatInclusion_ID]=Tabl_na_Update.[FT_MeatInclusion_ID]
      ,[FT_Chopped_ID]=Tabl_na_Update.[FT_Chopped_ID]
      ,[FT_Baby_ID]=Tabl_na_Update.[FT_Baby_ID]
      ,[FT_NameLvl1_ID]=Tabl_na_Update.[FT_NameLvl1_ID]
      ,[FT_NameLvl2_ID]=Tabl_na_Update.[FT_NameLvl2_ID]
      ,[FT_NameLvl3_ID]=Tabl_na_Update.[FT_NameLvl3_ID]
      ,[FT_PackSize_ID]=Tabl_na_Update.[FT_PackSize_ID]
      ,[FT_Halal_ID]=Tabl_na_Update.[FT_Halal_ID]
      ,[FT_GOST_ID]=Tabl_na_Update.[FT_GOST_ID]
	   ,[FT_PrdSize_ID]=Tabl_na_Update.[FT_PrdSize_ID]
	    ,[FT_Category_ID]=Tabl_na_Update.[FT_Category_ID]
		,[FT_Shell_ID]=Tabl_na_Update.[FT_Shell_ID]
										  from [TertiarySales].[prd].[Products] prd join  (
											select /*выборка столбцов которые только для варнеок, они будут апдейтины, это для тех у кого сменился только дубль*/
											[ProductID],
											 nully.NameConstructorWeight1 ,
											prodNOTnull.[DuplicatedProductID], 
											prodNOTnull.[FT_MeatType_ID] ,
											prodNOTnull.[FT_IsSmoked_ID] ,
											prodNOTnull.[FT_ConsumptSituation_ID] ,
											prodNOTnull.[FT_TasteInclusion_ID] ,
											prodNOTnull.[FT_MeatInclusion_ID] ,
											prodNOTnull.[FT_Chopped_ID] ,
											prodNOTnull.[FT_Baby_ID] ,
											prodNOTnull.[FT_NameLvl1_ID] ,
											prodNOTnull.[FT_NameLvl2_ID] ,
											prodNOTnull.[FT_NameLvl3_ID] ,
											prodNOTnull.[FT_PackSize_ID] ,
											prodNOTnull.[FT_Halal_ID] ,
											prodNOTnull.[FT_GOST_ID] ,
											 prodNOTnull.[FT_PrdSize_ID],
											 prodNOTnull.[FT_Category_ID],
											 prodNOTnull.[FT_Shell_ID]from (
SELECT prd.[ProductID], /*продукты у которыхфасеты ВСЕ нуловые, ищем их чтобы сджойниться к СКЮ с уже определными фасетами, выполнятется после правки ошибок с разынми фасетами */
		 NameConstructorWeight as NameConstructorWeight1 ,
		[DuplicatedProductID] ,
		[FT_MeatType_ID] ,
		[FT_IsSmoked_ID] ,
		[FT_ConsumptSituation_ID] ,
		[FT_TasteInclusion_ID] ,
		[FT_MeatInclusion_ID] ,
		[FT_Chopped_ID] ,
		[FT_Baby_ID] ,
		[FT_NameLvl1_ID] ,
		[FT_NameLvl2_ID] ,
		[FT_NameLvl3_ID] ,
		[FT_PackSize_ID] ,
		[FT_Halal_ID] ,
		[FT_GOST_ID] ,
	    [FT_PrdSize_ID],
		[FT_Category_ID],
		[FT_Shell_ID]
	FROM [TertiarySales].[prd].[Products] prd
	JOIN model.Products model
		ON model.[ProductID]=prd.[ProductID] join @Ins_ID_DUBL as DUB on DUB.[ProductID]=prd.[ProductID] 
	WHERE prd.[ProductGroupID]=38 ) nully
left  JOIN 
	(select * from (select  COUNT (*) 
	    over (partition by DuplicatedProductID) kol_dubley,* from(
SELECT DISTINCT -- тут идет поиск всех СКЮ у котрых фасеты не НУЛЛ полностью, с ними будет джойнится таблица выше 
	    NameConstructorWeight as NameConstructorWeight ,
		DuplicatedProductID,
	   	[FT_MeatType_ID] ,
		[FT_IsSmoked_ID] ,
		[FT_ConsumptSituation_ID] ,
		[FT_TasteInclusion_ID] ,
		[FT_MeatInclusion_ID] ,
		[FT_Chopped_ID] ,
		[FT_Baby_ID] ,
		[FT_NameLvl1_ID] ,
		[FT_NameLvl2_ID] ,
		[FT_NameLvl3_ID] ,
		[FT_PackSize_ID] ,
		[FT_Halal_ID] ,
		[FT_GOST_ID] ,
		[FT_PrdSize_ID],
		[FT_Category_ID],
		[FT_Shell_ID]
	FROM [TertiarySales].[prd].[Products] prdclassic
	JOIN model.Products model
		ON model.[ProductID]=prdclassic.[ProductID]
	WHERE prdclassic.[ProductGroupID]=38
			AND ([FT_MeatType_ID] is NOT null
			AND [FT_IsSmoked_ID] is NOT null
			AND [FT_ConsumptSituation_ID] is NOT null
			AND [FT_TasteInclusion_ID] is NOT null
			AND [FT_MeatInclusion_ID] is NOT null
			AND [FT_Chopped_ID] is NOT null
			AND [FT_Baby_ID] is NOT null
			AND [FT_NameLvl1_ID] is NOT null
			AND [FT_NameLvl2_ID] is NOT null
			AND [FT_NameLvl3_ID] is NOT null
			AND [FT_PackSize_ID]is NOT null
			AND [FT_Halal_ID] is NOT null
			AND [FT_GOST_ID] is NOT null
			AND [FT_PrdSize_ID] is NOT NULL
			and [FT_Category_ID] is not null
			AND [FT_Shell_ID] is not null
		) and ( not exists (select [ProductID] from @Ins_ID_DUBL t2 where t2.[ProductID] =prdclassic.[ProductID])) ) as Tabl_count_dubl )Tab2_count_dubl where kol_dubley=1
			
 ) prodNOTnull ON prodNOTnull.DuplicatedProductID=nully.DuplicatedProductID 
) Tabl_na_Update on Tabl_na_Update.[ProductID]=prd.[ProductID]
/*_____СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ_СОСКИ__________*/



/*_____Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые__________*/
	update [TertiarySales].[prd].[Products] set
             [FT_MeatType_ID]=Tabl_na_Update.[FT_MeatType_ID]
            ,[FT_IsSmoked_ID]=Tabl_na_Update.[FT_IsSmoked_ID]
            ,[FT_ConsumptSituation_ID]=Tabl_na_Update.[FT_ConsumptSituation_ID]
            ,[FT_TasteInclusion_ID]=Tabl_na_Update.[FT_TasteInclusion_ID]
            ,[FT_MeatInclusion_ID]=Tabl_na_Update.[FT_MeatInclusion_ID]
            ,[FT_Baby_ID]=Tabl_na_Update.[FT_Baby_ID]
      ,[FT_NameLvl1_ID]=Tabl_na_Update.[FT_NameLvl1_ID]
      ,[FT_NameLvl2_ID]=Tabl_na_Update.[FT_NameLvl2_ID]
      ,[FT_NameLvl3_ID]=Tabl_na_Update.[FT_NameLvl3_ID]
            ,[FT_PackSize_ID]=Tabl_na_Update.[FT_PackSize_ID]
            ,[FT_Halal_ID]=Tabl_na_Update.[FT_Halal_ID]
            ,[FT_GOST_ID]=Tabl_na_Update.[FT_GOST_ID]
            ,[FT_Fat_ID]=Tabl_na_Update.[FT_Fat_ID]
	        ,[FT_Form_ID]=Tabl_na_Update.[FT_Form_ID]
		    ,[FT_SliceType_ID]=Tabl_na_Update.[FT_SliceType_ID]
			,[FT_Category_ID]=Tabl_na_Update.[FT_Category_ID]
													  from [TertiarySales].[prd].[Products] prd join  (
											select /*выборка столбцов которые только для варнеок, они будут апдейтины, это для тех у кого сменился только дубль*/
											[ProductID],
											 nully.NameConstructorWeight1 ,
											prodNOTnull.[DuplicatedProductID], 
											prodNOTnull.[FT_MeatType_ID] ,
											prodNOTnull.[FT_IsSmoked_ID] ,
											prodNOTnull.[FT_ConsumptSituation_ID] ,
											prodNOTnull.[FT_TasteInclusion_ID] ,
											prodNOTnull.[FT_MeatInclusion_ID] ,
											prodNOTnull.[FT_Baby_ID] ,
									prodNOTnull.[FT_NameLvl1_ID] ,
									prodNOTnull.[FT_NameLvl2_ID] ,
									prodNOTnull.[FT_NameLvl3_ID] ,
											prodNOTnull.[FT_PackSize_ID] ,
											prodNOTnull.[FT_Halal_ID] ,
											prodNOTnull.[FT_GOST_ID] ,
											prodNOTnull.[FT_Fat_ID] ,
											prodNOTnull.[FT_Form_ID] ,
											prodNOTnull.[FT_SliceType_ID],
											prodNOTnull.[FT_Category_ID]
											 from (
SELECT prd.[ProductID], /*продукты у которыхфасеты ВСЕ нуловые, ищем их чтобы сджойниться к СКЮ с уже определными фасетами, выполнятется после правки ошибок с разынми фасетами */
		 NameConstructorWeight as NameConstructorWeight1 ,
		[DuplicatedProductID] ,
		[FT_MeatType_ID] ,
		[FT_IsSmoked_ID] ,
		[FT_ConsumptSituation_ID] ,
		[FT_TasteInclusion_ID] ,
		[FT_MeatInclusion_ID] ,
		[FT_Baby_ID] ,
	[FT_NameLvl1_ID] ,
	[FT_NameLvl2_ID] ,
	[FT_NameLvl3_ID] ,
		[FT_PackSize_ID] ,
		[FT_Halal_ID] ,
		[FT_GOST_ID] ,
		[FT_Fat_ID] ,
		[FT_Form_ID] ,
		[FT_SliceType_ID],
		[FT_Category_ID]
	FROM [TertiarySales].[prd].[Products] prd 
	JOIN model.Products model ON model.[ProductID]=prd.[ProductID] 
	JOIN @Ins_ID_DUBL as DUB on DUB.[ProductID]=prd.[ProductID] 
	WHERE prd.[ProductGroupID] in (17,39)            ) nully
    left JOIN          	                                            (select * from (select  COUNT (*)  over (partition by DuplicatedProductID) kol_dubley,* from(
SELECT DISTINCT -- тут идет поиск всех СКЮ у котрых фасеты не НУЛЛ полностью, с ними будет джойнится таблица выше 
	    NameConstructorWeight as NameConstructorWeight ,
		DuplicatedProductID,
	   		[FT_MeatType_ID] ,
			[FT_IsSmoked_ID] ,
			[FT_ConsumptSituation_ID] ,
			[FT_TasteInclusion_ID] ,
			[FT_MeatInclusion_ID] ,
			[FT_Baby_ID] ,
	[FT_NameLvl1_ID] ,
	[FT_NameLvl2_ID] ,
	[FT_NameLvl3_ID] ,
			[FT_PackSize_ID] ,
			[FT_Halal_ID] ,
			[FT_GOST_ID] ,
			[FT_Fat_ID] ,
			[FT_Form_ID] ,
			[FT_SliceType_ID],
			[FT_Category_ID]
	FROM [TertiarySales].[prd].[Products] prdclassic
	JOIN model.Products model	ON model.[ProductID]=prdclassic.[ProductID]
	WHERE prdclassic.[ProductGroupID] in (17,39)   AND 
		       ([FT_MeatType_ID]          is NOT null
			AND [FT_IsSmoked_ID]          is NOT null
			AND [FT_ConsumptSituation_ID] is NOT null
			AND [FT_TasteInclusion_ID]    is NOT null
			AND [FT_MeatInclusion_ID]     is NOT null
			AND [FT_Baby_ID]              is NOT null
	AND [FT_NameLvl1_ID]        is NOT null
	AND [FT_NameLvl2_ID]        is NOT null
	AND [FT_NameLvl3_ID]        is NOT null
AND [FT_PackSize_ID]  is NOT null
AND [FT_Halal_ID]     is NOT null
AND [FT_GOST_ID]      is NOT null
AND [FT_Fat_ID]       is NOT null
AND [FT_Form_ID]      is NOT null
AND [FT_SliceType_ID] is NOT null
and [FT_Category_ID] is not null
		) and ( not exists (select [ProductID] from @Ins_ID_DUBL t2 where t2.[ProductID] =prdclassic.[ProductID])) ) as Tabl_count_dubl )Tab2_count_dubl where kol_dubley=1
			
                                                                   ) prodNOTnull ON prodNOTnull.DuplicatedProductID=nully.DuplicatedProductID 
) Tabl_na_Update on Tabl_na_Update.[ProductID]=prd.[ProductID]

/*_____Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые_Копченые__________*/

/*_____Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени__________*/
update [TertiarySales].[prd].[Products] set
             [FT_MeatType_ID]=Tabl_na_Update.[FT_MeatType_ID]
            ,[FT_ConsumptSituation_ID]=Tabl_na_Update.[FT_ConsumptSituation_ID]
            ,[FT_TasteInclusion_ID]=Tabl_na_Update.[FT_TasteInclusion_ID]
            ,[FT_MeatInclusion_ID]=Tabl_na_Update.[FT_MeatInclusion_ID]
            ,[FT_Baby_ID]=Tabl_na_Update.[FT_Baby_ID]
      ,[FT_NameLvl1_ID]=Tabl_na_Update.[FT_NameLvl1_ID]
      ,[FT_NameLvl2_ID]=Tabl_na_Update.[FT_NameLvl2_ID]
      ,[FT_NameLvl3_ID]=Tabl_na_Update.[FT_NameLvl3_ID]
		,[FT_PackSize_ID]=Tabl_na_Update.[FT_PackSize_ID]
		,[FT_Halal_ID]=Tabl_na_Update.[FT_Halal_ID]
		,[FT_GOST_ID]=Tabl_na_Update.[FT_GOST_ID]
		,[FT_PrdSize_ID]=Tabl_na_Update.[FT_PrdSize_ID]
		,[FT_Form_ID]=Tabl_na_Update.[FT_Form_ID]
		,[FT_Packing_ID]=Tabl_na_Update.[FT_Packing_ID]
        ,[FT_NameForeign_ID]=Tabl_na_Update.[FT_NameForeign_ID]
        ,[FT_NameUnique_ID]=Tabl_na_Update.[FT_NameUnique_ID]
        ,[FT_NameTaste_ID]=Tabl_na_Update.[FT_NameTaste_ID]
		,[FT_Category_ID]=Tabl_na_Update.[FT_Category_ID]
													  from [TertiarySales].[prd].[Products] prd join  (
											select /*выборка столбцов которые только для варнеок, они будут апдейтины, это для тех у кого сменился только дубль*/
											[ProductID],
											  nully.NameConstructorWeight1 ,
											  prodNOTnull.[DuplicatedProductID], 
											prodNOTnull.[FT_MeatType_ID] ,
											prodNOTnull.[FT_ConsumptSituation_ID] ,
											prodNOTnull.[FT_TasteInclusion_ID] ,
											prodNOTnull.[FT_MeatInclusion_ID] ,
											prodNOTnull.[FT_Baby_ID] ,
									prodNOTnull.[FT_NameLvl1_ID] ,
									prodNOTnull.[FT_NameLvl2_ID] ,
									prodNOTnull.[FT_NameLvl3_ID] ,
								         	prodNOTnull.[FT_PackSize_ID] ,
											prodNOTnull.[FT_Halal_ID] ,
											prodNOTnull.[FT_GOST_ID] ,
											prodNOTnull.[FT_PrdSize_ID] ,
											prodNOTnull.[FT_Form_ID] ,
											prodNOTnull.[FT_Packing_ID] ,
											prodNOTnull.[FT_NameForeign_ID] ,
											prodNOTnull.[FT_NameUnique_ID] ,
											prodNOTnull.[FT_NameTaste_ID] ,
											prodNOTnull.[FT_Category_ID]
											 from (
SELECT prd.[ProductID], /*продукты у которыхфасеты ВСЕ нуловые, ищем их чтобы сджойниться к СКЮ с уже определными фасетами, выполнятется после правки ошибок с разынми фасетами */
		 NameConstructorWeight as NameConstructorWeight1 ,
		[DuplicatedProductID] ,
		[FT_MeatType_ID] ,
		[FT_ConsumptSituation_ID] ,
		[FT_TasteInclusion_ID] ,
		[FT_MeatInclusion_ID] ,
		[FT_Baby_ID] ,
	[FT_NameLvl1_ID] ,
	[FT_NameLvl2_ID] ,
	[FT_NameLvl3_ID] ,
		[FT_PackSize_ID] ,
		[FT_Halal_ID] ,
		[FT_GOST_ID] ,
		[FT_PrdSize_ID] ,
		[FT_Form_ID] ,
		[FT_Packing_ID] ,
        [FT_NameForeign_ID] ,
        [FT_NameUnique_ID] ,
        [FT_NameTaste_ID],
		[FT_Category_ID]
	FROM [TertiarySales].[prd].[Products] prd 
	JOIN model.Products model ON model.[ProductID]=prd.[ProductID] 
	JOIN @Ins_ID_DUBL as DUB on DUB.[ProductID]=prd.[ProductID] 
	WHERE prd.[ProductGroupID] in (13)            ) nully
    left JOIN          	                                            (select * from (select  COUNT (*)  over (partition by DuplicatedProductID) kol_dubley,* from(
SELECT DISTINCT -- тут идет поиск всех СКЮ у котрых фасеты не НУЛЛ полностью, с ними будет джойнится таблица выше 
	    NameConstructorWeight as NameConstructorWeight ,
		DuplicatedProductID,
	   		[FT_MeatType_ID] ,
			[FT_ConsumptSituation_ID] ,
			[FT_TasteInclusion_ID] ,
			[FT_MeatInclusion_ID] ,
			[FT_Baby_ID] ,
	[FT_NameLvl1_ID] ,
	[FT_NameLvl2_ID] ,
	[FT_NameLvl3_ID] ,
		[FT_PackSize_ID] ,
		[FT_Halal_ID] ,
		[FT_GOST_ID] ,
		[FT_PrdSize_ID] ,
		[FT_Form_ID] ,
		[FT_Packing_ID] ,
        [FT_NameForeign_ID] ,
        [FT_NameUnique_ID] ,
        [FT_NameTaste_ID] ,
		[FT_Category_ID]
	FROM [TertiarySales].[prd].[Products] prdclassic
	JOIN model.Products model	ON model.[ProductID]=prdclassic.[ProductID]
	WHERE prdclassic.[ProductGroupID] in (13)   AND 
		       ([FT_MeatType_ID]          is NOT null
			AND [FT_ConsumptSituation_ID] is NOT null
			AND [FT_TasteInclusion_ID]    is NOT null
			AND [FT_MeatInclusion_ID]     is NOT null
			AND [FT_Baby_ID]              is NOT null
	AND [FT_NameLvl1_ID]        is NOT null
	AND [FT_NameLvl2_ID]        is NOT null
	AND [FT_NameLvl3_ID]        is NOT null
			AND [FT_PackSize_ID]		  is NOT null
			AND [FT_Halal_ID]			  is NOT null
			AND [FT_GOST_ID]			  is NOT null
			AND [FT_PrdSize_ID]		      is NOT null
			AND [FT_Form_ID]		      is NOT null
			AND [FT_Packing_ID]		      is NOT null
			AND [FT_NameForeign_ID]       is NOT null
			AND [FT_NameUnique_ID]	      is NOT null
			AND [FT_NameTaste_ID]	      is NOT null
			and [FT_Category_ID] is not null
		) and ( not exists (select [ProductID] from @Ins_ID_DUBL t2 where t2.[ProductID] =prdclassic.[ProductID])) ) as Tabl_count_dubl )Tab2_count_dubl where kol_dubley=1
			
                                                                   ) prodNOTnull ON prodNOTnull.DuplicatedProductID=nully.DuplicatedProductID 
) Tabl_na_Update on Tabl_na_Update.[ProductID]=prd.[ProductID]

/*_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени_Пельмени*/



----------  insert into  [TertiarySales].[dbo].[ZOT_facet_upd](   --запуск после апдейта
----------       [ChangeID]
----------      ,[RecordDate]
----------      ,[ColumnName]
----------      ,[ProductID]
----------      ,[OperationName]
----------      ,[Type])			
---------- select LOGS.[Id],
----------LOGS.[RecordDate],
----------LOGS.[ColumnName],
----------LOGS.[ProductID],
----------[OperationName]='Facet', 
----------[Type]='FromLogs'
----------  FROM [TertiarySales].[logs].[TblChanges_prdProducts]  as LOGS 
----------where  (LOGS.RecordDate BETWEEN @from_date AND @to_date and (
----------[ColumnName]='DuplicatedProductID'  ))  and  ( not exists (select [ChangeID] from [TertiarySales].[dbo].[ZOT_facet_upd] t2 where t2.[ChangeID] =LOGS.[Id] ))  


end
