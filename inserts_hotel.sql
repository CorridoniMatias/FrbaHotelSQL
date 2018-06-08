USE GD1C2018
set tran isolation level read uncommitted
begin tran ins
GO
CREATE SCHEMA MATOTA
GO
CREATE TABLE MATOTA.TipoDocumento (
	IdTipoDocumento INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	nombre NVARCHAR(30) NOT NULL
);

INSERT INTO MATOTA.TipoDocumento VALUES ('DNI'),('CI'), ('LE'), ('PASAPORTE')

CREATE TABLE MATOTA.Usuario
(
	idUsuario 		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
username 		NVARCHAR(10) NOT NULL UNIQUE,
 	password 		CHAR(64) NOT NULL,
	nombre 		NVARCHAR(82) NOT NULL,
	apellido 		NVARCHAR(82) NOT NULL,
idTipoDocumento 	INT NOT NULL REFERENCES MATOTA.TipoDocumento,
numeroDocumento	NVARCHAR(20) NOT NULL,
mail			NVARCHAR(255) NOT NULL,
telefono		NVARCHAR(80) NOT NULL,
calle			NVARCHAR(255) NOT NULL,
nroCalle		INT NOT NULL,
piso			INT,
departamento		NVARCHAR(3),
localidad		NVARCHAR(255) NOT NULL,
pais			NVARCHAR(60) NOT NULL,
fechaNacimiento	DATETIME NOT NULL,
habilitado 		BIT NOT NULL DEFAULT 0,
intentosPassword 	SMALLINT DEFAULT 0
);

-- Usuario generico administrador "admin" con password "w23e"
INSERT INTO MATOTA.Usuario VALUES (
	'admin',
	'E6B87050BFCB8143FCB8DB0170A4DC9ED00D904DDD3E2A4AD1B1E8DC0FDC9BE7',
	'Usuario',
	'Administrador',
	1,
	'0000000000',
	'admin@admin.com',
	'123456',
'calle',
'1234',
null,
null,
'CABA',
'ARGENTINA',
'1900-01-01',
1,
0
)

CREATE TABLE MATOTA.Hotel (
	idHotel			INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	nombre		NVARCHAR(82),
	mail			NVARCHAR(255),
telefono		NVARCHAR(80),
calle			NVARCHAR(255),
nroCalle		NUMERIC(18,0),
ciudad			NVARCHAR(255),
pais			NVARCHAR(60),
cantidadEstrellas	NUMERIC(18,0),
fechaCreacion		DATE,
recargaEstrellas	NUMERIC(18,0)
); 

CREATE TABLE MATOTA.InactividadHotel (
	idInactividadHotel	INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	fechaInicio		DATETIME NOT NULL,
fechaFin		DATETIME NOT NULL,
motivo			NVARCHAR(255) NOT NULL,
idHotel			INT REFERENCES MATOTA.Hotel		
); 



CREATE TABLE MATOTA.HotelesUsuario (
idUsuario	INT NOT NULL REFERENCES MATOTA.Usuario,
idHotel		INT NOT NULL REFERENCES MATOTA.Hotel
PRIMARY KEY (idUsuario,idHotel)
);

CREATE TABLE MATOTA.UbicacionHabitacion
(
	idUbicacion INT PRIMARY KEY IDENTITY(1,1),
descripcion NVARCHAR(255)
); 

INSERT INTO MATOTA.UbicacionHabitacion VALUES ('Frente'),('No Frente')

CREATE TABLE MATOTA.TipoHabitacion
(
	idTipoHabitacion NUMERIC(18,0) PRIMARY KEY IDENTITY(1,1),
	cantidadPersonas NUMERIC(18,2),
	descripcion NVARCHAR(255) NOT NULL,
	porcentajeExtra NUMERIC(18,2)
); 


CREATE TABLE MATOTA.Habitacion
(
	idHotel INT NOT NULL REFERENCES MATOTA.Hotel,
	nroHabitacion NUMERIC(18,0) NOT NULL,
piso NUMERIC(18,0),
idUbicacion INT REFERENCES MATOTA.UbicacionHabitacion,
idTipoHabitacion NUMERIC(18,0) NOT NULL REFERENCES MATOTA.TipoHabitacion,
descripcion NVARCHAR(255),
	comodidades NVARCHAR(255),
	habilitado BIT,
	PRIMARY KEY (idHotel, nroHabitacion)
); 


CREATE TABLE MATOTA.Rol
(
	idRol INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	NOMBRE NVARCHAR(20) NOT NULL,
estado BIT NOT NULL,   
); 

INSERT INTO MATOTA.Rol VALUES ('Administrador',1),('Recepcionista',1),('Guest',1)

CREATE TABLE MATOTA.RolesUsuario 
(
	idUsuario INT NOT NULL REFERENCES MATOTA.Usuario,
	idRol INT NOT NULL REFERENCES MATOTA.Rol,
	PRIMARY KEY (idUsuario, idRol)
);

-- Seteamos el usuario admin que viene por defecto como administrador
INSERT INTO MATOTA.RolesUsuario VALUES (1,1)

CREATE TABLE MATOTA.Permiso
(
	idPermiso INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	nombre NVARCHAR(30) NOT NULL,
descripcion NVARCHAR(255) NOT NULL,  
); 

INSERT INTO MATOTA.Permiso VALUES 
('ABM de Rol', 'Permite crear, modificar y eliminar el acceso de un tipo de usuario a una
funcionalidad propia del sistema'),
('ABM Usuarios', 'Permite agregar, modificar y eliminar usuarios del sistema.'),
('ABM de Cliente', 'Permite crear, modificar y dar de baja un cliente del sistema'),
('ABM de Hotel', 'Permite crear, modificar y dar de baja un Hotel de la cadena.'),
('ABM de Habitación', 'Permite crear, modificar y dar de baja una habitación de hotel particular perteneciente a la cadena.'),
('ABM Régimen de estadía', 'Permite crear, modificar y dar de baja un tipo de régimen de estadía.'),
('Generar o Modificar un Reserva', 'Permite crear y modificar la reserva de un posible huesped'),
('Cancelar Reserva', 'Permite cancelar la reserva generada en algún momento y que la misma no haya sido utilizada con anterioridad'),
('Registrar Estadía', 'Permite registrar el check-in y el check-out de los huéspedes alojados en el Hotel.'),
('Registrar consumibles', 'Permite ingresar los productos y/o servicios que fueron consumidos y/o utilizados durante la estadía por los huéspedes de una determinado habitación.'),
('Facturar estadía', 'Permite emitir las facturas para el pago de estadía por parte del huésped al hotel en el cual se alojó.'),
('Listado Estadístico', 'Permite hacer el listado estadístico del TOP 5 de distintas cosas..')

CREATE TABLE MATOTA.PermisosRol
(
	idRol INT REFERENCES MATOTA.Rol,
	idPermiso INT REFERENCES MATOTA.Permiso
	PRIMARY KEY (idRol, idPermiso)
);

INSERT INTO MATOTA.PermisosRol VALUES 
(1,2),(1,4),(1,5),(1,6),(1,12), (2,3),(2,7),(2,8),(2,9),(2,10),(2,11),(3,7),(3,8)

CREATE TABLE MATOTA.Cliente
(
	idCliente		INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	nombre 		NVARCHAR(255) NOT NULL,
	apellido 		NVARCHAR(255) NOT NULL,
idTipoDocumento 	INT NOT NULL REFERENCES MATOTA.TipoDocumento,
numeroDocumento	NUMERIC(18,0) NOT NULL,
mail			NVARCHAR(255) NOT NULL UNIQUE,
telefono		VARCHAR(80),
calle			NVARCHAR(255) NOT NULL,
nroCalle		NUMERIC(18,0) NOT NULL,
piso			NUMERIC(18,0) NOT NULL,
departamento		NVARCHAR(50) NOT NULL,
localidad		NVARCHAR(255),
pais			NVARCHAR(60),
nacionalidad		NVARCHAR(255) NOT NULL ,
fechaNacimiento	DATETIME NOT NULL,
habilitado		BIT NOT NULL DEFAULT (1),
valido 			BIT NOT NULL DEFAULT(1)
);



CREATE TABLE MATOTA.Regimen
(
	idRegimen INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	nombre NVARCHAR(50),
precioBase NUMERIC(18,2) NOT NULL,
estado BIT NOT NULL
);

CREATE TABLE MATOTA.RegimenHotel(
idHotel		INT NOT NULL REFERENCES MATOTA.Hotel,
idRegimen	INT NOT NULL REFERENCES MATOTA.Regimen
PRIMARY KEY(idHotel, idRegimen)
); 



CREATE TABLE MATOTA.EstadoReserva
(
	idEstadoReserva INT PRIMARY KEY IDENTITY(1,1),
descripcion NVARCHAR(255) NOT NULL
); 

INSERT INTO MATOTA.EstadoReserva VALUES
('Reserva correcta'),
('Reserva modificada (la misma sufrió algún cambio y no es la misma al momento de su creación)'),
('Reserva cancelada por Recepción'),
('Reserva cancelada por Cliente'),
('Reserva cancelada por No-Show'),
('Reserva con ingreso (efectivizada)'),
('Reserva Migrada')


CREATE TABLE MATOTA.Reserva
(
	idReserva NUMERIC(18,0) NOT NULL PRIMARY KEY IDENTITY(1,1),
fechaReserva DATETIME,
fechaDesde  DATETIME NOT NULL,
fechaHasta DATETIME,
cantidadNoches NUMERIC(18,0) NOT NULL,
idRegimen INT NOT NULL REFERENCES MATOTA.Regimen,
idEstadoReserva INT REFERENCES MATOTA.EstadoReserva,
idCliente INT NOT NULL REFERENCES MATOTA.Cliente,
precioBaseReserva NUMERIC(18,2),
cantidadPersonas INT,
); 
CREATE TABLE MATOTA.ReservaCancelada(
	idReserva	NUMERIC(18,0) NOT NULL PRIMARY KEY REFERENCES MATOTA.Reserva,
motivo		NVARCHAR(500) NOT NULL,
fecha		DATETIME NOT NULL,
idUsuario	INT NOT NULL REFERENCES MATOTA.Usuario
);

CREATE TABLE MATOTA.LogReserva (
	idLogReserva INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	momento DATETIME NOT NULL,
	idUsuario INT REFERENCES MATOTA.Usuario,
	idReserva NUMERIC(18,0) REFERENCES MATOTA.Reserva
); 

CREATE TABLE MATOTA.ReservaHabitacion
(
	idReservaHabitacion INT PRIMARY KEY IDENTITY(1,1),
	idReserva NUMERIC(18,0) NOT NULL REFERENCES MATOTA.Reserva,
	idHotel INT NOT NULL,
	nroHabitacion NUMERIC(18,0) NOT NULL,
	FOREIGN KEY (idHotel, nroHabitacion) REFERENCES MATOTA.Habitacion (idHotel, nroHabitacion) 
); 

CREATE TABLE MATOTA.Consumible
(
	codigoConsumible NUMERIC(18,0) PRIMARY KEY IDENTITY(1,1),
	descripcion NVARCHAR(255) NOT NULL,
	precio NUMERIC(18,2) NOT NULL
); 

CREATE TABLE MATOTA.ConsumiblesEstadia
(
	idConsumibleEstadia INT PRIMARY KEY IDENTITY(1,1),
	codigoConsumible NUMERIC(18,0) NOT NULL REFERENCES MATOTA.Consumible,
	cantidad INT NOT NULL,
	idReservaHabitacion INT NOT NULL REFERENCES MATOTA.ReservaHabitacion,
	precioAlMomento NUMERIC(18,2)
); 

CREATE TABLE MATOTA.Estadia
(
	idEstadia INT NOT NULL PRIMARY KEY IDENTITY(1,1),
idReserva NUMERIC(18,0) REFERENCES MATOTA.Reserva,
fechaIngreso DATETIME NOT NULL,
fechaSalida DATETIME,
cantidadNoches NUMERIC(18,0) NOT NULL,
	idUsuario INT REFERENCES MATOTA.Usuario
);

CREATE TABLE MATOTA.ClientesEstadia
(
	idEstadia INT REFERENCES MATOTA.Estadia,
	idCliente INT REFERENCES MATOTA.Cliente,
	PRIMARY KEY (idEstadia, idCliente)
); 

CREATE TABLE MATOTA.FormaDePago
(
	idFormaDePago INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	nombre NVARCHAR(20) NOT NULL 
); 

INSERT INTO MATOTA.FormaDePago VALUES ('Desconocido'), ('Tarjeta de Credito'), ('Tarjeta de Debito'), ('Efectivo')


CREATE TABLE MATOTA.Factura
(
	idFactura NUMERIC(18,0) NOT NULL PRIMARY KEY IDENTITY(1,1),
	idEstadia INT REFERENCES MATOTA.Estadia,
	fecha DATETIME NOT NULL,
	idFormaDePago INT REFERENCES MATOTA.FormaDePago,
	total NUMERIC(18,2) NOT NULL,
	migrado BIT NOT NULL DEFAULT(0)
); 

CREATE TABLE MATOTA.ItemFactura
(
	idItemFactura INT PRIMARY KEY IDENTITY(1,1),
	idFactura NUMERIC(18,0) NOT NULL REFERENCES MATOTA.Factura,
	idConsumibleEstadia INT REFERENCES MATOTA.ConsumiblesEstadia,
	descripcion VARCHAR(255) NOT NULL,
	cantidad NUMERIC(18,0) NOT NULL,
	monto NUMERIC(18,2) NOT NULL 
); 

commit