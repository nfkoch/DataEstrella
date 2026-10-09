--La fecha hasta en las tablas esta para indicar la vigencia del mismo, la logica es que sino tiene valor  (NULL) el registro es el activo, si tiene valor es el historico.
Create table SubCategoria (
Codigo int,
Descripcion varchar(20),
fechahasta date,
Constraint pk_SubCategoria primary key(Codigo));

create table Categoria(
Codigo int,
Descripcion nvarchar(50),
CodigoSubCategoria int,
fechaHasta date,
Constraint pk_Categoria primary key (Codigo),
Constraint fk_CategoriaSubCategoria foreign key(CodigoSubCategoria) references SubCategoria(codigo));

Create table Producto(
Codigo int,
Descripcion nvarchar(50),
CodigoCategoria int,
FechaHasta date,
Constraint pk_Producto primary key(Codigo),
Constraint fk_Producto_Categoria foreign key(CodigoCategoria) references Categoria (Codigo));

Create table Cliente(
Codigo int,
Nombre varchar(30),
Apellido varchar(30),
IdentificadorFiscal varchar(20),
Telefono varchar(20),
Direccion varchar(50),
FechaHasta date,
Constraint pk_Cliente primary key(Codigo));

Create table OrdenVenta(
NroOrden varchar(20),
FechaOrden date,
CodigoCliente int,
NombreApellido varchar(30),
CodigoProducto int,
DescripcionProducto varchar(30),
Cantidad float,
Precio float,
Descuento float,
SubTotal AS (Cantidad * Precio * (1 - Descuento/100)) PERSISTED,
Constraint pk_OrdenVenta Primary Key(NroOrden),
Constraint fk_OrdenVentaCliente foreign key(CodigoCliente) references Cliente(Codigo),
Constraint fk_OrdenVentaProducto foreign key(CodigoProducto) references Producto(Codigo));