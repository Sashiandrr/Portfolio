USE [TertiarySales]
GO
/****** Object:  StoredProcedure [data].[spUpdateInnerDupProductID]    Script Date: 20.05.2025 14:53:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [data].[spUpdateInnerDupProductID]
@log_it INT = 1,
@log_success INT = 1,
@log_error INT = 1	
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY 
	DECLARE @proc_label UNIQUEIDENTIFIER = 'E3BB2C34-E25A-43E3-8829-E7E0B216A2E9'
	DECLARE @success_proc NVARCHAR(MAX) = (SELECT OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID))

	UPDATE prd
	SET prd.[InnerDupProductID] = update_prd.[InnerDupProductID]
	FROM prd.Products prd
	JOIN (
		SELECT p.ProductID,
			InnerDupProductID = CASE WHEN [Флаг Полный конструктор] = 'Да' THEN MinID ELSE p.productid END
		FROM prd.Products AS p
		JOIN (
			SELECT ProductID, [Флаг Полный конструктор], MinID 
			FROM (
				SELECT mp.ProductID, [Флаг Полный конструктор],
					MinID = MIN(mp.ProductID) OVER (PARTITION BY [NameConstructorWeight],pp.ChainID)
				FROM [TertiarySales].[model].[Products] AS mp
				JOIN [prd].[Products] AS pp ON pp.ProductID = mp.ProductID
			) AS temp1
		) AS temp2 ON temp2.ProductID = p.ProductID
	) AS update_prd 
		ON update_prd.ProductID = prd.ProductID 
			AND (prd.[InnerDupProductID] IS NULL OR prd.[InnerDupProductID] <> update_prd.[InnerDupProductID])

	IF @log_it = 1
		BEGIN
			IF @log_success = 1
				BEGIN
					INSERT INTO [TertiarySales].[logs].[Logs] 
						SELECT * FROM [logs].[funSetUserSPRunSuccess](
							GETDATE(), -- Date 
							0, -- StatusID (SUCCESS)
							1, -- ActionID (USER_SP_RUN)
							USER_NAME(), -- UserName
							'Успешное выполнение процедуры авторасчета InnerDupProductID',
							@success_proc, @proc_label
							)	 
				END
		END
	RETURN 1
END TRY
BEGIN CATCH 
	DECLARE @error_msg  NVARCHAR(MAX) = ERROR_MESSAGE()  
	DECLARE @error_state NVARCHAR(MAX) = ERROR_STATE()
	DECLARE @error_proc NVARCHAR(MAX) = ERROR_PROCEDURE()
	RAISERROR (@error_msg, 16, 1)

	IF @log_it = 1
		BEGIN
			IF @log_error = 1
				BEGIN
					INSERT INTO [TertiarySales].[logs].[Logs] 
						SELECT * FROM [logs].[funSetUserSPRunError](
							GETDATE(),-- Date 
							1, -- StatusID (ERROR)
							1, -- ActionID (USER_SP_RUN)
							USER_NAME(), -- UserName
							'Ошибка при выполнении процедуры авторасчета InnerDupProductID',
							@error_msg, @error_state, @error_proc, @proc_label 
						)					
				END
		END
	RAISERROR (@error_msg, 16, 1)
	RETURN -1
END CATCH  
END
