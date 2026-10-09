USE [DataEstrella]
GO
/****** Object:  StoredProcedure [dbo].[ETL_SubCategoria]    Script Date: 08/10/2026 14:31:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[ETL_SubCategoria]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualización de registros (cerrar vigencia si cambió algo)
        UPDATE d
           SET d.fechahasta = GETDATE()
        FROM DataEstrella.dbo.SubCategoria d
        INNER JOIN (
         SELECT [ProductCategoryKey]
      ,[SpanishProductCategoryName]
  FROM [AdventureWorks].[dbo].[DimProductCategory]
        ) X ON d.Codigo = X.ProductCategoryKey
        WHERE d.Descripcion <> X.SpanishProductCategoryName and d.fechahasta is null;

        -- Inserta los datos nuevos
        INSERT INTO DataEstrella.dbo.SubCategoria (
            Codigo,
            Descripcion,
            FechaHasta
        )
        SELECT DISTINCT
           [ProductCategoryKey]
          ,[SpanishProductCategoryName]
          ,NULL as FechaHasta
        FROM [AdventureWorks].[dbo].[DimProductCategory] X
        WHERE NOT EXISTS (
            SELECT 1
            FROM DataEstrella.dbo.SubCategoria Z
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
