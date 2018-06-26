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
	NOMBRE NVARCHAR(30) NOT NULL,
	estado BIT NOT NULL,   
); 

INSERT INTO MATOTA.Rol VALUES ('Administrador',1),('Recepcionista',1),('Guest',1),('Administrador General',1)

CREATE TABLE MATOTA.RolesUsuario 
(
	idUsuario INT NOT NULL REFERENCES MATOTA.Usuario,
	idRol INT NOT NULL REFERENCES MATOTA.Rol,
	PRIMARY KEY (idUsuario, idRol)
);

-- Seteamos el usuario admin que viene por defecto como administrador general
INSERT INTO MATOTA.RolesUsuario VALUES (1,4)

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
(1,2),(1,4),(1,5),(1,6),(1,12), (2,3),(2,7),(2,8),(2,9),(2,10),(2,11),(3,7),(3,8),(4,1),(4,2),(4,3),(4,4),(4,5),(4,6),(4,7),(4,8),(4,9),(4,10),(4,11),(4,12)

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
idRegimen INT NOT NULL,
idHotel INT NOT NULL,
idEstadoReserva INT REFERENCES MATOTA.EstadoReserva,
idCliente INT NOT NULL REFERENCES MATOTA.Cliente,
precioBaseReserva NUMERIC(18,2),
cantidadPersonas INT,
FOREIGN KEY (idHotel,idRegimen) REFERENCES MATOTA.RegimenHotel(idHotel, idRegimen)
); 

CREATE TABLE MATOTA.ReservaCancelada(
	idReserva	NUMERIC(18,0) NOT NULL PRIMARY KEY REFERENCES MATOTA.Reserva,
motivo		NVARCHAR(500) NOT NULL,
fecha		DATETIME NOT NULL,
idUsuario	INT REFERENCES MATOTA.Usuario
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
cantidadNoches NUMERIC(18,0),
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

set tran isolation level read uncommitted
begin tran migracion
-- Migrar Tipos de Habitacion:
SET IDENTITY_INSERT MATOTA.TipoHabitacion ON 

INSERT INTO MATOTA.TipoHabitacion (idTipoHabitacion, descripcion, porcentajeExtra)
SELECT DISTINCT(Habitacion_Tipo_Codigo), Habitacion_Tipo_Descripcion, Habitacion_Tipo_Porcentual FROM gd_esquema.Maestra ORDER BY 1

SET IDENTITY_INSERT MATOTA.TipoHabitacion OFF

-- Migrar Hoteles
INSERT INTO MATOTA.Hotel (ciudad, calle, nroCalle, cantidadEstrellas, recargaEstrellas)
SELECT Hotel_Ciudad, Hotel_Calle, Hotel_Nro_Calle,  Hotel_CantEstrella, Hotel_Recarga_Estrella 
FROM gd_esquema.Maestra GROUP BY Hotel_Calle, Hotel_Nro_Calle, Hotel_Ciudad, Hotel_CantEstrella, Hotel_Recarga_Estrella

--Migrar Regímenes

INSERT INTO MATOTA.Regimen (nombre, precioBase, estado)
SELECT DISTINCT Regimen_Descripcion, Regimen_Precio, 1
FROM gd_esquema.Maestra 

--Migrar RegimenHotel
INSERT INTO MATOTA.RegimenHotel (idHotel, idRegimen)
SELECT h.idHotel, r.idRegimen FROM MATOTA.Hotel h, MATOTA.Regimen r, gd_esquema.Maestra gd
WHERE h.ciudad=gd.Hotel_ciudad 
AND h.calle=gd.Hotel_Calle 
AND h.nroCalle=gd.Hotel_Nro_Calle
AND r.nombre=gd.Regimen_Descripcion
GROUP BY h.idHotel, r.idRegimen

-- Migrar Habitaciones intentar con case

DECLARE @FRENTE int = (SELECT idUbicacion FROM MATOTA.UbicacionHabitacion WHERE descripcion = 'Frente')

DECLARE @NOFRENTE int = (SELECT idUbicacion FROM MATOTA.UbicacionHabitacion WHERE descripcion = 'No Frente')


INSERT INTO MATOTA.Habitacion (idHotel,nroHabitacion,piso, idTipoHabitacion, habilitado, idUbicacion)
SELECT h.idHotel, ma.Habitacion_Numero, ma.Habitacion_Piso, t.idTipoHabitacion, 1, 
'Ubicacion' = CASE 
WHEN ma.Habitacion_Frente = 'S' THEN @FRENTE 
WHEN ma.Habitacion_Frente = 'N' THEN @NOFRENTE
END

FROM MATOTA.Hotel h, gd_esquema.Maestra ma, MATOTA.UbicacionHabitacion u, MATOTA.TipoHabitacion t
WHERE h.ciudad=ma.Hotel_ciudad 
AND h.calle=ma.Hotel_Calle 
AND h.nroCalle=ma.Hotel_Nro_Calle
AND t.idTipoHabitacion=ma.Habitacion_Tipo_Codigo
GROUP BY h.idHotel, ma.Habitacion_Numero, ma.Habitacion_Piso, t.idTipoHabitacion, ma.Habitacion_Frente


--Migrar consumibles
SET IDENTITY_INSERT MATOTA.Consumible ON 

INSERT INTO MATOTA.Consumible (codigoConsumible, descripcion, precio)
SELECT DISTINCT Consumible_Codigo, Consumible_Descripcion, Consumible_Precio FROM gd_esquema.Maestra 
WHERE Consumible_Codigo IS NOT NULL
ORDER BY 1

SET IDENTITY_INSERT MATOTA.Consumible  OFF

--Migracion clientes

SELECT Cliente_Pasaporte_Nro INTO #PasaportesUnicos FROM gd_esquema.Maestra GROUP BY Cliente_Pasaporte_Nro
										HAVING COUNT(distinct Cliente_Apellido) = 1 AND COUNT(distinct Cliente_Nombre) = 1

-- Optimizacion de obtencion de pasaportes
CREATE INDEX idx_pasaportes ON #PasaportesUnicos (Cliente_Pasaporte_Nro)

SELECT Cliente_Mail INTO #MailsUnicos FROM gd_esquema.Maestra GROUP BY Cliente_Mail
							HAVING COUNT(DISTINCT Cliente_Pasaporte_Nro) = 1


DECLARE @tipopasaporte INT = (SELECT idTipoDocumento FROM MATOTA.TipoDocumento WHERE nombre = 'PASAPORTE')


INSERT INTO MATOTA.Cliente (numeroDocumento, idTipoDocumento, apellido, nombre, mail, fechaNacimiento, calle, nroCalle, piso, departamento, nacionalidad)
-- Todos bien
SELECT DISTINCT Cliente_Pasaporte_Nro,@tipopasaporte, Cliente_Apellido, Cliente_Nombre, Cliente_Mail, Cliente_Fecha_Nac, Cliente_Dom_Calle,
		Cliente_Nro_Calle, Cliente_Piso, Cliente_Depto, Cliente_Nacionalidad
FROM gd_esquema.Maestra 
	WHERE EXISTS (SELECT * FROM #PasaportesUnicos pu WHERE pu.Cliente_Pasaporte_Nro = gd_esquema.Maestra.Cliente_Pasaporte_Nro) 
	AND Cliente_Mail IN (SELECT * FROM #MailsUnicos)			
ORDER BY Cliente_Pasaporte_Nro


INSERT INTO MATOTA.Cliente (numeroDocumento, idTipoDocumento, apellido, nombre, mail, fechaNacimiento, calle, nroCalle, piso, departamento, nacionalidad, valido)
-- Mails Repetidos
SELECT DISTINCT Cliente_Pasaporte_Nro,@tipopasaporte, Cliente_Apellido, Cliente_Nombre, 'Mail repetido '+ CAST(Cliente_Pasaporte_Nro AS varchar(10))+': '+Cliente_Mail, Cliente_Fecha_Nac, Cliente_Dom_Calle,
		Cliente_Nro_Calle, Cliente_Piso, Cliente_Depto, Cliente_Nacionalidad,0
FROM gd_esquema.Maestra 
	WHERE EXISTS (SELECT * FROM #PasaportesUnicos pu WHERE pu.Cliente_Pasaporte_Nro = gd_esquema.Maestra.Cliente_Pasaporte_Nro) 
	AND Cliente_Mail NOT IN (SELECT * FROM #MailsUnicos)			
ORDER BY Cliente_Pasaporte_Nro


INSERT INTO MATOTA.Cliente (numeroDocumento, idTipoDocumento, apellido, nombre, mail, fechaNacimiento, calle, nroCalle, piso, departamento, nacionalidad, valido)
-- Pasaporte Repetidos
SELECT DISTINCT Cliente_Pasaporte_Nro,@tipopasaporte, Cliente_Apellido, Cliente_Nombre, Cliente_Mail, Cliente_Fecha_Nac, Cliente_Dom_Calle,
		Cliente_Nro_Calle, Cliente_Piso, Cliente_Depto, Cliente_Nacionalidad,0
FROM gd_esquema.Maestra 
	WHERE NOT EXISTS (SELECT * FROM #PasaportesUnicos pu WHERE pu.Cliente_Pasaporte_Nro = gd_esquema.Maestra.Cliente_Pasaporte_Nro) 
	AND Cliente_Mail IN (SELECT * FROM #MailsUnicos)			
ORDER BY Cliente_Pasaporte_Nro

INSERT INTO MATOTA.Cliente (numeroDocumento, idTipoDocumento, apellido, nombre, mail, fechaNacimiento, calle, nroCalle, piso, departamento, nacionalidad, valido)
-- Pasaporte y Mail Repetido
SELECT DISTINCT Cliente_Pasaporte_Nro, @tipopasaporte,Cliente_Apellido, Cliente_Nombre, 'Mail repetido '+ CAST((SCOPE_IDENTITY()) AS varchar(10)) + ': '+Cliente_Mail, Cliente_Fecha_Nac, Cliente_Dom_Calle,
		Cliente_Nro_Calle, Cliente_Piso, Cliente_Depto, Cliente_Nacionalidad,0
FROM gd_esquema.Maestra 
	WHERE NOT EXISTS (SELECT * FROM #PasaportesUnicos pu WHERE pu.Cliente_Pasaporte_Nro = gd_esquema.Maestra.Cliente_Pasaporte_Nro) 
	AND Cliente_Mail NOT IN (SELECT * FROM #MailsUnicos)			
ORDER BY Cliente_Pasaporte_Nro

-- Migrar Reservas

DECLARE @ESTADORESERVA INT = (SELECT idEstadoReserva FROM MATOTA.EstadoReserva WHERE descripcion = 'Reserva Migrada')

SET IDENTITY_INSERT MATOTA.Reserva ON
INSERT INTO MATOTA.Reserva (idReserva, fechaDesde, cantidadNoches, idRegimen, idEstadoReserva, idCliente, precioBaseReserva, idHotel)
SELECT DISTINCT Reserva_Codigo, Reserva_Fecha_Inicio, Reserva_Cant_Noches, re.idRegimen, @ESTADORESERVA, cl.idCliente, Regimen_Precio, h.idHotel FROM gd_esquema.Maestra
INNER JOIN MATOTA.Regimen re ON re.Nombre = Regimen_Descripcion
INNER JOIN MATOTA.Cliente cl ON (cl.idTipoDocumento = @tipopasaporte AND cl.numeroDocumento = Cliente_Pasaporte_Nro AND cl.apellido = Cliente_Apellido AND cl.nombre = Cliente_Nombre)
INNER JOIN MATOTA.Hotel h ON Hotel_Calle = h.calle AND Hotel_Nro_Calle = h.nroCalle AND Hotel_Ciudad = h.ciudad
SET IDENTITY_INSERT MATOTA.Reserva OFF


-- Migrar Estadias

INSERT INTO MATOTA.Estadia (idReserva, fechaIngreso, cantidadNoches)
select distinct Reserva_Codigo, Estadia_Fecha_Inicio, Estadia_Cant_Noches FROM gd_esquema.Maestra
WHERE Estadia_Cant_Noches IS NOT NULL

INSERT INTO MATOTA.ClientesEstadia 
SELECT e.idEstadia, r.idCliente FROM MATOTA.Estadia e 
INNER JOIN MATOTA.Reserva r ON e.idReserva = r.idReserva

--FACTURAS
SET IDENTITY_INSERT MATOTA.Factura ON

INSERT INTO MATOTA.Factura (idFactura, idEstadia, fecha, total, migrado)
SELECT DISTINCT m.Factura_Nro, e.idEstadia, m.Factura_Fecha, m.Factura_Total, 1
FROM gd_esquema.Maestra m
INNER JOIN MATOTA.Estadia e ON e.idReserva = m.Reserva_Codigo
WHERE m.Factura_Nro IS NOT NULL

SET IDENTITY_INSERT MATOTA.Factura OFF


-- RESERVAS HABITACION
INSERT INTO MATOTA.ReservaHabitacion (idReserva, idHotel, nroHabitacion)
SELECT DISTINCT Reserva_Codigo, h.idHotel, Habitacion_Numero FROM gd_esquema.Maestra
INNER JOIN MATOTA.Hotel h ON Hotel_Calle = h.calle AND Hotel_Nro_Calle = h.nroCalle AND Hotel_Ciudad = h.ciudad

-- CONSUMIBLES ESTADIA
INSERT INTO MATOTA.ConsumiblesEstadia (codigoConsumible, cantidad, idReservaHabitacion, precioAlMomento)
SELECT Consumible_Codigo, 
				Item_Factura_Cantidad, 
				(SELECT idReservaHabitacion FROM MATOTA.ReservaHabitacion rh 
					INNER JOIN MATOTA.Hotel h ON rh.idHotel = h.idHotel
				WHERE rh.idReserva = gd_esquema.Maestra.Reserva_Codigo AND rh.nroHabitacion = gd_esquema.Maestra.Habitacion_Numero
					AND h.calle = gd_esquema.Maestra.Hotel_Calle AND h.nroCalle = gd_esquema.Maestra.Hotel_Nro_Calle AND h.ciudad = gd_esquema.Maestra.Hotel_Ciudad
					) idReservaHabitacion,	
				Item_Factura_Monto
				 FROM gd_esquema.Maestra WHERE Consumible_Codigo IS NOT NULL

-- ITEMS FACTURA
INSERT INTO MATOTA.ItemFactura(idFactura, descripcion, idConsumibleEstadia, cantidad, monto)
SELECT DISTINCT Factura_Nro, COALESCE(Consumible_Descripcion, 'Estadia') descr, ce.idConsumibleEstadia, Item_Factura_Cantidad, Item_Factura_Monto FROM gd_esquema.Maestra
LEFT JOIN MATOTA.Hotel h ON (h.calle = gd_esquema.Maestra.Hotel_Calle AND h.nroCalle = gd_esquema.Maestra.Hotel_Nro_Calle AND h.ciudad = gd_esquema.Maestra.Hotel_Ciudad)
LEFT JOIN MATOTA.ReservaHabitacion rh ON (rh.idHotel = h.idHotel AND rh.idReserva = Reserva_Codigo AND rh.nroHabitacion = Habitacion_Numero)
LEFT JOIN MATOTA.ConsumiblesEstadia ce ON (ce.idReservaHabitacion = rh.idReservaHabitacion AND ce.cantidad = Item_Factura_Cantidad AND ce.codigoConsumible = Consumible_Codigo AND ce.precioAlMomento = Item_Factura_Monto)
WHERE Factura_Nro IS NOT NULL 

commit tran migracion

-- Creacion de indices optimizadores de busquedas:
CREATE INDEX idx_idHotelInInactividad ON MATOTA.InactividadHotel (idHotel)
CREATE INDEX idx_hotel_habitacion ON MATOTA.ReservaHabitacion (idHotel, nroHabitacion)
CREATE INDEX idx_factura_itemfactura ON MATOTA.ItemFactura (idFactura)
CREATE INDEX idx_consumibleestadia_itemfactura ON MATOTA.ItemFactura (idConsumibleEstadia)