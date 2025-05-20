USE [TertiarySales]
GO
/****** Object:  Trigger [prd].[trigProducts_UpdateColumns]    Script Date: 20.05.2025 13:29:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER TRIGGER [prd].[trigProducts_UpdateColumns]
   ON [prd].[Products]
   AFTER UPDATE
AS 
BEGIN
       SET NOCOUNT ON;
       -- ОБРАБОТКА ИЗМЕНЕНИЯ ProductVariantID
       -- Надо получить ProductID не только для продуктов, 
       -- где ProductVariantID изменился, но и те у которых 
       -- он имел старое значение (например, для пересчета реф. цены).
       IF UPDATE([ProductVariantsID]) 
       BEGIN         
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld])
             SELECT DISTINCT GETDATE(), 'ProductVariantsID', prd.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(vids.PVID_Old AS NVARCHAR(MAX)) + '}' 
             FROM TertiarySales.prd.Products AS prd
             JOIN (
                    SELECT i.ProductVariantsID AS PVID_New, d.ProductVariantsID AS PVID_Old 
                    FROM INSERTED AS i
                    JOIN DELETED AS d ON i.ProductID = d.ProductID 
                           AND i.ProductVariantsID <> d.ProductVariantsID  
             ) vids ON prd.ProductVariantsID = vids.PVID_New 
                    OR prd.ProductVariantsID = vids.PVID_Old  
       END
       --Изменение варианта продукта внутрисеточного
       IF UPDATE([NCClpsProductID]) 
       BEGIN         
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld])
             SELECT DISTINCT GETDATE(), 'NCClpsProductID', prd.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(vids.NCCPID_Old AS NVARCHAR(MAX)) + '}' 
             FROM TertiarySales.prd.Products AS prd
             JOIN (
                    SELECT i.NCClpsProductID AS NCCPID_New, d.NCClpsProductID AS NCCPID_Old 
                    FROM INSERTED AS i
                    JOIN DELETED AS d ON i.ProductID = d.ProductID 
                           AND i.NCClpsProductID <> d.NCClpsProductID  
             ) vids ON prd.NCClpsProductID = vids.NCCPID_New 
                    OR prd.NCClpsProductID = vids.NCCPID_Old  
       END
	        --Изменение варианта продукта внутрисеточного
       IF UPDATE([InnerDupProductID]) 
       BEGIN         
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld])
             SELECT DISTINCT GETDATE(), 'InnerDupProductID', prd.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(vids.IDPID_Old AS NVARCHAR(MAX)) + '}' 
             FROM TertiarySales.prd.Products AS prd
             JOIN (
                    SELECT i.InnerDupProductID AS IDPID_New, d.InnerDupProductID AS IDPID_Old 
                    FROM INSERTED AS i
                    JOIN DELETED AS d ON i.ProductID = d.ProductID 
                           AND i.InnerDupProductID <> d.InnerDupProductID  
             ) vids ON prd.InnerDupProductID = vids.IDPID_New 
                    OR prd.InnerDupProductID = vids.IDPID_Old  
       END

       -- ОБРАБОТКА ИЗМЕНЕНИЯ DuplicatedProductID
       IF UPDATE(DuplicatedProductID) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'DuplicatedProductID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.DuplicatedProductID AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.DuplicatedProductID <> d.DuplicatedProductID
       END
       -- ОБРАБОТКА ИЗМЕНЕНИЯ PackingTypeID 
       -- Используем базовый шаблон запроса.
       -- Варианты:
       --     1. При смене типа весовки необходимо пересчитать поле Quantity в фактах.
       IF UPDATE(PackingTypeID) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'PackingTypeID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.PackingTypeID AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.PackingTypeID <> d.PackingTypeID
       END

       -- ОБРАБОТКА ИЗМЕНЕНИЯ ProductWeight 
       IF UPDATE(ProductWeight) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'ProductWeight', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.ProductWeight AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.ProductWeight <> d.ProductWeight
       END
       -- ОБРАБОТКА ИЗМЕНЕНИЯ SaleProductWeightPC.
       -- Варианты:
       --     1. При смене вуса куска необходимо пересчитать поле Quantity в фактах.
       IF UPDATE(SaleProductWeightPC) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'SaleProductWeightPC', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.SaleProductWeightPC AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND (
                    (i.SaleProductWeightPC <> d.SaleProductWeightPC) 
                    OR (i.SaleProductWeightPC IS NULL AND d.SaleProductWeightPC IS NOT NULL)
                    OR (i.SaleProductWeightPC IS NOT NULL AND d.SaleProductWeightPC IS NULL)
                    )
       END

-- ОБРАБОТКА ИЗМЕНЕНИЯ [ManufacturerID] -- ОБРАБОТКА ИЗМЕНЕНИЯ [ManufacturerID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ManufacturerID]
IF UPDATE(ManufacturerID) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'ManufacturerID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.ManufacturerID AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.ManufacturerID <> d.ManufacturerID
       END


-- ОБРАБОТКА ИЗМЕНЕНИЯ [TradeMarkID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [TradeMarkID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [TradeMarkID]
IF UPDATE(TradeMarkID) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'TradeMarkID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.TradeMarkID AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.TradeMarkID <> d.TradeMarkID
       END


-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductTypeID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductTypeID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductTypeID]
	   IF UPDATE(ProductTypeID) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'ProductTypeID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.ProductTypeID AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.ProductTypeID <> d.ProductTypeID
       END

	   -- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductGroupID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductGroupID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductGroupID]
	   IF UPDATE(ProductGroupID) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'ProductGroupID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.ProductGroupID AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.ProductGroupID <> d.ProductGroupID
       END

-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductTypeID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductTypeID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductTypeID]
	   IF UPDATE(ProductTypeID) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'ProductTypeID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.ProductTypeID AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.ProductTypeID <> d.ProductTypeID
       END



-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductSubGroupID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductSubGroupID]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ProductSubGroupID]
	   IF UPDATE(ProductSubGroupID) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'ProductSubGroupID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.ProductSubGroupID AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.ProductSubGroupID <> d.ProductSubGroupID
       END


-- ОБРАБОТКА ИЗМЕНЕНИЯ [ShortNameForConstructor]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ShortNameForConstructor]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ShortNameForConstructor]
	   IF UPDATE(ShortNameForConstructor) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'ShortNameForConstructor', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.ShortNameForConstructor AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.ShortNameForConstructor <> d.ShortNameForConstructor
       END

-- ОБРАБОТКА ИЗМЕНЕНИЯ [ФОРМА]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ShortNameForConstructor]-- ОБРАБОТКА ИЗМЕНЕНИЯ [Форма]
	   	   IF UPDATE([FormID]) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'FormID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.[FormID] AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.[FormID] <> d.[FormID]
       END
-- ОБРАБОТКА ИЗМЕНЕНИЯ [ОБОЛОЧКА]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ShortNameForConstructor]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ОБОЛОЧКА]
	   	   IF UPDATE([ShellID]) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'ShellID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.[ShellID] AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.[ShellID] <> d.[ShellID]
       END
-- ОБРАБОТКА ИЗМЕНЕНИЯ [[ViewKIID]]-- ОБРАБОТКА ИЗМЕНЕНИЯ [ShortNameForConstructor]-- ОБРАБОТКА ИЗМЕНЕНИЯ [[ViewKIID]]
	   	   IF UPDATE([ViewKIID]) 
       BEGIN
             INSERT INTO [logs].[TblChanges_prdProducts] ([RecordDate],[ColumnName],[ProductID],[UserName], [ValueOld]) 
             SELECT DISTINCT GETDATE(), 'ViewKIID', i.ProductID, 
                    ORIGINAL_LOGIN(), '{"Value": ' + CAST(d.[ViewKIID] AS NVARCHAR(MAX)) + '}' 
             FROM INSERTED AS i
             JOIN DELETED AS d ON i.ProductID = d.ProductID 
                    AND i.[ViewKIID] <> d.[ViewKIID]
       END


END
