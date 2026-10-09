USE [DataEstrella];
--No se puede en mi sql server developer, pero, dejo aca por las dudas que lo quieran aplicar.
--El CDC sirve para llevar un itinerario de los cambios de los datos
EXEC sys.sp_cdc_enable_db; --Habilito CDC
--Habilito CDC por tabla
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'Categoria',
    @role_name     = NULL;
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'SubCategoria',
    @role_name     = NULL;
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'Cliente',
    @role_name     = NULL;
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'Producto',
    @role_name     = NULL;
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'OrdenVenta',
    @role_name     = NULL;