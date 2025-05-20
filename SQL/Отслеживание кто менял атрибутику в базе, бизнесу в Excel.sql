declare  @data1 as nvarchar(max) ='2024-10-01 17:27:38.420'

Select * from (SELECT
  [Id],
  [RecordDate],
  CASE
    WHEN [ColumnName] = 'ProductSubGroupID' THEN 'Смена Группы'
    WHEN [ColumnName] = 'ProductGroupID' THEN 'Смена Подгруппы'
    WHEN [ColumnName] = 'FormID' THEN 'Смена Формы'
    WHEN [ColumnName] = 'ShellID' THEN 'Смена Оболочки'
    WHEN [ColumnName] = 'ViewKIID' THEN 'Смена ВидаКИ'
    WHEN [ColumnName] = 'PackingTypeID' THEN 'Смена Вес/Фиксвес'
    WHEN [ColumnName] = 'ProductTypeID' THEN 'Смена Категории'
    WHEN [ColumnName] = 'ManufacturerID' THEN 'Смена Производителя'
    WHEN [ColumnName] = 'TradeMarkID' THEN 'Смена Марки'
  END AS [Что поменяли],
  t1.[ProductID],
  [UserName],
  CASE
    WHEN [ColumnName] = 'ProductSubGroupID' THEN SubProductGroup
    WHEN [ColumnName] = 'ProductGroupID' THEN gr.ProductGroup
    WHEN [ColumnName] = 'FormID' THEN f.Name
    WHEN [ColumnName] = 'ShellID' THEN sh.ShellName
    WHEN [ColumnName] = 'ViewKIID' THEN vi.ViewKI
    WHEN [ColumnName] = 'PackingTypeID' THEN pak.PackingType
    WHEN [ColumnName] = 'ProductTypeID' THEN ProductTypeName
    WHEN [ColumnName] = 'ManufacturerID' THEN mu.Manufacturer
    WHEN [ColumnName] = 'TradeMarkID' THEN mark.TradeMark
  END AS [БЫло],
  CASE
    WHEN [ColumnName] = 'ProductSubGroupID' THEN mts.Подгруппа
    WHEN [ColumnName] = 'ProductGroupID' THEN mts.[ProductGroup]
    WHEN [ColumnName] = 'FormID' THEN mts.[Форма продукта]
    WHEN [ColumnName] = 'ShellID' THEN mts.ShellName
    WHEN [ColumnName] = 'ViewKIID' THEN mts.ViewKI
    WHEN [ColumnName] = 'PackingTypeID' THEN mts.PackingType
    WHEN [ColumnName] = 'ProductTypeID' THEN mts.Category
    WHEN [ColumnName] = 'ManufacturerID' THEN mts.Manufacturer
    WHEN [ColumnName] = 'TradeMarkID' THEN mts.TradeMark
  END AS [Стало],
  mts.NameConstructorWeight AS [Конструтор наименования с весом]
FROM
  (
    SELECT
      *
    FROM
      [TertiarySales].[logs].[TblChanges_prdProducts] lg
    WHERE
      [RecordDate] > '2024-10-01 17:27:38.420'
      AND [ColumnName] NOT IN (
        'NCClpsProductID',
        'DuplicatedProductID',
        'InnerDupProductID',
        'ProductVariantsID',
        'ProductWeight',
		'SaleProductWeightPC',
        'ShortNameForConstructor'


      )
  ) t1
  LEFT JOIN [TertiarySales].Products.SubProductGroups SUBgr ON SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99) = SUBgr.SubProductGroupID and [ColumnName]='ProductSubGroupID'
  LEFT JOIN [TertiarySales].Products.ProductGroups gr ON SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99) = gr.ProductGroupID and  [ColumnName]='ProductGroupID'
  LEFT JOIN [TertiarySales].Products.Forms f ON SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99) = f.FormID and  [ColumnName]='FormID '
  LEFT JOIN [TertiarySales].Products.Shell sh ON SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99) = sh.ShellID  and [ColumnName]='ShellID'
  LEFT JOIN [TertiarySales].Products.Manufacturers mu ON SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99) = mu.ManufacturerID and  [ColumnName]='ManufacturerID'
  LEFT JOIN [TertiarySales].Products.TradeMarks mark ON SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99) = mark.TradeMarkID  and [ColumnName]='TradeMarkID'
  LEFT JOIN [TertiarySales].Products.ViewKI vi ON SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99) = vi.ViewKIID  and [ColumnName]='ViewKIID'
  LEFT JOIN [TertiarySales].Products.PackingTypes pak ON SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99) = pak.PackingTypeID and  [ColumnName]='PackingTypeID'
  LEFT JOIN [TertiarySales].Products.ProductTypes categ ON SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99) = categ.ProductTypeID and  [ColumnName]='ProductTypeID'
  LEFT JOIN to_model.viewProductsMTS mts ON mts.[ProductID] = t1.[ProductID] 
UNION 
SELECT
      [Id],
  [RecordDate],
  CASE
    WHEN [ColumnName] = 'ProductWeight' THEN 'Смена Веса'
    WHEN [ColumnName] = 'ShortNameForConstructor' THEN 'Смена Конструтора'
  END AS [Что поменяли],
  lg.[ProductID],
  [UserName],
  CASE
    WHEN [ColumnName] = 'ProductWeight' THEN SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99)
    WHEN [ColumnName] = 'ShortNameForConstructor' THEN SUBSTRING (SUBSTRING ([ValueOld], 1, len ([ValueOld]) -1), 10, 99)
    ELSE [ColumnName]
  END AS [БЫло],
  CASE
    WHEN [ColumnName] = 'ProductWeight' THEN mts.ProductWeight
    WHEN [ColumnName] = 'ShortNameForConstructor' THEN mts.NameConstructor
    ELSE [ColumnName]
  END AS [Стало],
  mts.NameConstructorWeight AS [Конструтор наименования с весом]
FROM
  [TertiarySales].[logs].[TblChanges_prdProducts] lg
  LEFT JOIN to_model.viewProductsMTS mts ON mts.[ProductID] = lg.[ProductID]
WHERE
  [RecordDate] > '2024-10-01 17:27:38.420'
  AND [ColumnName] IN ('ProductWeight', 'ShortNameForConstructor')) a2 where Стало is not null
