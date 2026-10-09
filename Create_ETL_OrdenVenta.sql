USE [DataEstrella]
GO
/****** Object:  StoredProcedure [dbo].[ETL_Cliente]    Script Date: 08/10/2026 14:31:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[ETL_OrdenVenta]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Inserta los datos nuevos
        INSERT INTO [DataEstrella].[dbo].[OrdenVenta] (
            [NroOrden]
      ,[FechaOrden]
      ,[CodigoCliente]
      ,[NombreApellido]
      ,[CodigoProducto]
      ,[DescripcionProducto]
      ,[Cantidad]
      ,[Precio]
      ,[Descuento]
        )
 SELECT DISTINCT
            FIS.[SalesOrderNumber],
            FIS.[OrderDate],
            DC.[CustomerKey],
            DC.[FirstName] + ' ' + DC.[LastName],
            DP.[ProductKey],
            DP.[SpanishProductName],
            FIS.[OrderQuantity],
            FIS.[UnitPrice],
            FIS.[DiscountAmount]
        FROM [AdventureWorks].[dbo].[FactInternetSales] FIS
        INNER JOIN [AdventureWorks].[dbo].[DimCustomer] DC 
            ON DC.[CustomerKey] = FIS.[CustomerKey]
        INNER JOIN [AdventureWorks].[dbo].[DimProduct] DP 
            ON DP.[ProductKey] = FIS.[ProductKey]
        WHERE NOT EXISTS (
            SELECT 1
            FROM [DataEstrella].[dbo].[OrdenVenta] Z
            WHERE Z.[NroOrden] = FIS.[SalesOrderNumber]
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
