USE [DataEstrella]
GO
/****** Object:  StoredProcedure [dbo].[ETL_Cliente]    Script Date: 08/10/2026 14:31:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[ETL_Cliente]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualización de registros (cerrar vigencia si cambió algo)
        UPDATE d
           SET d.fechahasta = GETDATE()
        FROM [DataEstrella].[dbo].[Cliente] d
        INNER JOIN (
     SELECT [CustomerKey]
      ,[FirstName]
      ,[LastName]
      ,[CustomerAlternateKey]
      ,[Phone]
      ,[AddressLine1]
  FROM [AdventureWorks].[dbo].[DimCustomer]
        ) X ON d.Codigo = X.CustomerKey
        WHERE d.Nombre <> X.[FirstName] 
        or d.Apellido <> X.[LastName] 
        or d.IdentificadorFiscal <> X.[CustomerAlternateKey] 
        or d.telefono<>X.Phone
        or d.direccion<>X.AddressLine1
        and d.fechahasta is null;

        -- Inserta los datos nuevos
        INSERT INTO [DataEstrella].[dbo].[Cliente] (
            [Codigo]
      ,[Nombre]
      ,[Apellido]
      ,[IdentificadorFiscal]
      ,[Telefono]
      ,[Direccion]
      ,[FechaHasta]
        )
        SELECT DISTINCT
         [CustomerKey]
      ,[FirstName]
      ,[LastName]
      ,[CustomerAlternateKey]
      ,[Phone]
      ,[AddressLine1]
      ,NULL as FechaHasta
  FROM [AdventureWorks].[dbo].[DimCustomer] X
        WHERE NOT EXISTS (
            SELECT 1
            FROM [DataEstrella].[dbo].[Cliente] Z
            WHERE Z.Codigo = X.[CustomerKey]
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
