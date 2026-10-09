USE [DataEstrella]
GO
/****** Object:  StoredProcedure [dbo].[ETL_SubCategoria]    Script Date: 08/10/2026 14:31:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[ETL_Categoria]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualización de registros (cerrar vigencia si cambió algo)
        UPDATE d
           SET d.fechahasta = GETDATE()
        FROM DataEstrella.dbo.Categoria d
        INNER JOIN (
         SELECT [ProductSubcategoryKey]
      ,[SpanishProductSubcategoryName]
      ,[ProductCategoryKey]
  FROM [AdventureWorks].[dbo].[DimProductSubcategory]
        ) X ON d.Codigo = X.ProductCategoryKey
        WHERE d.Descripcion <> X.SpanishProductSubcategoryName and d.fechahasta is null;

        -- Inserta los datos nuevos
        INSERT INTO DataEstrella.dbo.Categoria (
            Codigo,
            Descripcion,
            CodigoSubCategoria,
            FechaHasta
        )
        SELECT DISTINCT
          [ProductSubcategoryKey]
      ,[SpanishProductSubcategoryName]
      ,[ProductCategoryKey]
          ,NULL as FechaHasta
        FROM [AdventureWorks].[dbo].[DimProductSubcategory] X
        WHERE NOT EXISTS (
            SELECT 1
            FROM DataEstrella.dbo.Categoria Z
            WHERE Z.Codigo = X.[ProductCategoryKey]
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
