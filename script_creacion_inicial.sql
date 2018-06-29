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

INSERT INTO MATOTA.Rol VALUES ('Administrador',1),('Recepcionista',1),('Guest',1),('AdministradorGeneral',1)

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

USE GD1C2018;
GO
CREATE PROCEDURE MATOTA.loginUsuario(@username varchar(10), @password varchar(20)) AS
BEGIN
	DECLARE @pwd CHAR(64), @enabled BIT, @userid INT;
	SELECT @pwd = password, @enabled = habilitado, @userid = idUsuario FROM MATOTA.Usuario WHERE username = @username;

	IF(@enabled = 0)
		RETURN -1;

	IF(@pwd = (SELECT CONVERT(NVARCHAR(64),HashBytes('SHA2_256', @password),2)) )
		BEGIN
			UPDATE MATOTA.Usuario SET intentosPassword = 0 WHERE username = @username;
			RETURN @userid;
		END

	UPDATE MATOTA.Usuario SET intentosPassword += 1 WHERE username = @username;
	RETURN 0;
END
GO
CREATE TRIGGER MATOTA.OnUsuarioUpdate ON MATOTA.Usuario
AFTER UPDATE AS
BEGIN
	IF(UPDATE(intentosPassword))
		BEGIN
			DECLARE @intentos SMALLINT, @usuario INT;
			SELECT TOP 1 @intentos = intentosPassword, @usuario = idUsuario FROM inserted;-- El top 1 es porque si alguien nos tira un update desde afuera explota todo (update de muchas filas).
			IF( @intentos = 3) 
				UPDATE MATOTA.Usuario SET habilitado = 0, intentosPassword = 0 WHERE idUsuario = @usuario
		END
END
GO

CREATE FUNCTION MATOTA.GetGuestRoleID()
RETURNS INT AS
BEGIN
	RETURN (SELECT idRol FROM MATOTA.Rol r WHERE r.NOMBRE = 'Guest')
END
GO

CREATE PROCEDURE MATOTA.altaCliente(@nombre nvarchar(255),@apellido nvarchar(255),@tipoDoc int,
									@numeroDocumento numeric(18,0),@mail nvarchar(255),@telefono varchar(80),
									@calle nvarchar(255),@nroCalle numeric(18,0),@piso numeric(18,0),@departamento nvarchar(50),
									@localidad nvarchar(255),@pais nvarchar(60),@nacionalidad nvarchar(255),@fechaNacimiento datetime)
AS
BEGIN
	IF EXISTS (SELECT idTipoDocumento,numeroDocumento FROM MATOTA.Cliente WHERE idTipoDocumento = @tipoDoc AND numeroDocumento = @numeroDocumento)
		RETURN -1;
	IF EXISTS (SELECT mail FROM MATOTA.Cliente WHERE mail = @mail)
		RETURN 0;
	INSERT INTO MATOTA.Cliente VALUES (@nombre,@apellido,@tipoDoc,@numeroDocumento,@mail,@telefono,@calle,@nroCalle,
									   @piso,@departamento,@localidad,@pais,@nacionalidad,@fechaNacimiento,1,1)
	RETURN SCOPE_IDENTITY();
END
GO
CREATE PROCEDURE MATOTA.UpdatePassword(@userid INT, @password VARCHAR(20)) AS
BEGIN
	UPDATE MATOTA.Usuario SET password = (SELECT CONVERT(NVARCHAR(64),HashBytes('SHA2_256', @password),2)) WHERE idUsuario = @userid;
	RETURN @@ROWCOUNT;
END
GO
CREATE PROCEDURE MATOTA.UpdateCliente(@nombre nvarchar(255),@apellido nvarchar(255),@tipoDoc int,
									@numeroDocumento numeric(18,0),@mail nvarchar(255),@telefono varchar(80),
									@calle nvarchar(255),@nroCalle numeric(18,0),@piso numeric(18,0),@departamento nvarchar(50),
									@localidad nvarchar(255),@pais nvarchar(60),@nacionalidad nvarchar(255),@fechaNacimiento datetime,@habilitado bit,
									@tipoDocOriginal int,@numDoc numeric(18,0))
AS
BEGIN
	IF EXISTS (SELECT idTipoDocumento,numeroDocumento FROM MATOTA.Cliente WHERE idTipoDocumento = @tipoDoc AND numeroDocumento = @numeroDocumento AND idTipoDocumento !=@tipoDocOriginal AND numeroDocumento != @numDoc)
		RETURN -1;
	IF EXISTS (SELECT mail FROM MATOTA.Cliente WHERE mail = @mail AND idTipoDocumento != @tipoDocOriginal AND numeroDocumento != @numDoc)
		RETURN 0;
	UPDATE MATOTA.Cliente SET nombre = @nombre,apellido = @apellido,idTipoDocumento = @tipoDoc,numeroDocumento = @numeroDocumento,mail = @mail,
							  telefono = @telefono, calle = @calle,nroCalle = @nroCalle, piso = @piso, departamento = @departamento,localidad = @localidad,
							  pais = @pais, nacionalidad = @nacionalidad, fechaNacimiento = @fechaNacimiento , habilitado = @habilitado
	WHERE idTipoDocumento = @tipoDocOriginal AND numeroDocumento = @numDoc
	RETURN 1;
END
GO
CREATE PROCEDURE MATOTA.UpdateHabitacion(@idHotel int,@nroHabitacion numeric(18,0),@piso numeric(18,0),
									@idUbicacion int,@idTipoHabitacion numeric(18,0),@descripcion nvarchar(255),
									@comodidades nvarchar(255),@habilitado bit)
AS
BEGIN
	IF EXISTS (SELECT idHotel,nroHabitacion FROM MATOTA.Habitacion WHERE idHotel = @idHotel AND nroHabitacion = @nroHabitacion)
		RETURN 0;
	UPDATE MATOTA.Habitacion SET nroHabitacion = @nroHabitacion, piso = @piso, idUbicacion = @idUbicacion, descripcion = @descripcion,
							  comodidades = @comodidades, habilitado = @habilitado
	WHERE idHotel = @idHotel
	RETURN 1;
END
GO

CREATE PROCEDURE MATOTA.getTipoDoc(@idTipoDoc int)
AS
BEGIN
	SELECT nombre FROM MATOTA.TipoDocumento WHERE IdTipoDocumento = @idTipoDoc
END
GO

CREATE PROCEDURE MATOTA.altaHabitacion(@nroHabitacion numeric(18,0),@piso numeric(18,0),@idUbicacion int, @idTipoHabitacion numeric(18,0),@idHotel int,
								  @descripcion nvarchar(255),@comodidades nvarchar(255))
AS
BEGIN
	IF EXISTS(SELECT idHotel,nroHabitacion FROM MATOTA.Habitacion WHERE idHotel = @idHotel AND nroHabitacion = @nroHabitacion)
		RETURN 0;
	INSERT INTO MATOTA.Habitacion VALUES (@idHotel,@nroHabitacion,@piso,@idUbicacion,@idTipoHabitacion,@descripcion,@comodidades,1)
	RETURN 1;
END
GO
CREATE PROCEDURE MATOTA.CheckRegimenHotelConstraint(@fechaActual DATETIME, @idHotel INT, @idRegimen INT, @reservas INT OUT, @estadias INT OUT) AS
BEGIN
	--Cuenta la cant de reservas que hay activas, se considera activa si la fecha desde todavia no paso y no fue cancelada.
	SELECT @reservas = COUNT(re.idReserva) FROM MATOTA.Reserva re
	INNER JOIN MATOTA.EstadoReserva er ON (re.idEstadoReserva = er.idEstadoReserva)
	WHERE (@fechaActual <= re.fechaDesde )--OR @fechaActual <= DATEADD(DAY, re.cantidadNoches, re.fechaDesde) 
			AND re.idHotel = @idHotel AND re.idRegimen = @idRegimen
			AND er.descripcion NOT LIKE '%cancelada%'

	-- Cuenta las estadias en curso, esta en curso si la reserva asociada tiene estado efectivizada y la fecha actual es mayor a la fecha de inicio y todavia no hay fecha de salida.
	SELECT @estadias = COUNT(e.idEstadia) FROM MATOTA.Reserva re
	INNER JOIN MATOTA.EstadoReserva er ON (re.idEstadoReserva = er.idEstadoReserva)
	INNER JOIN MATOTA.Estadia e ON (e.idReserva = re.idReserva AND (e.fechaIngreso <= @fechaActual AND e.fechaSalida IS NULL))
	WHERE re.idHotel = @idHotel AND re.idRegimen = @idRegimen AND er.descripcion LIKE '%efectivizada%'
END
GO
CREATE FUNCTION MATOTA.GetInactividadesEnPeriodo(@fechaDesde DATETIME, @fechaHasta DATETIME, @idHotel INT)
RETURNS INT AS
BEGIN
	DECLARE @cant INT;
	SELECT @cant = COUNT(idInactividadHotel) FROM MATOTA.InactividadHotel
	WHERE idHotel = @idHotel AND ((fechaInicio >= @fechaDesde AND fechaInicio <= @fechaHasta) OR (fechaFin >= @fechaDesde AND fechaFin <= @fechaHasta))
	RETURN @cant;
END
GO
CREATE PROCEDURE MATOTA.ReservasEstadiasEnPeriodo(@fechaDesde DATETIME, @fechaHasta DATETIME, @idHotel INT, @reservas INT OUT, @estadias INT OUT, @inactividades INT OUT) AS
BEGIN
	--Cuenta la cant de reservas que hay activas, se considera activa si la fecha desde todavia no paso y no fue cancelada.
	SELECT @reservas = COUNT(re.idReserva) FROM MATOTA.Reserva re
	INNER JOIN MATOTA.EstadoReserva er ON (re.idEstadoReserva = er.idEstadoReserva)
	WHERE (@fechaDesde <= re.fechaDesde AND re.fechaDesde <= @fechaHasta )
			AND re.idHotel = @idHotel
			AND er.descripcion NOT LIKE '%cancelada%'

	-- Cuenta las estadias en curso, esta en curso si la reserva asociada tiene estado efectivizada y la fecha actual es mayor a la fecha de inicio y todavia no hay fecha de salida.
	SELECT @estadias = COUNT(e.idEstadia) FROM MATOTA.Reserva re
	INNER JOIN MATOTA.EstadoReserva er ON (re.idEstadoReserva = er.idEstadoReserva)
	INNER JOIN MATOTA.Estadia e ON (e.idReserva = re.idReserva AND (e.fechaIngreso <= @fechaHasta AND e.fechaSalida IS NULL))
	WHERE re.idHotel = @idHotel AND er.descripcion LIKE '%efectivizada%'

	EXEC @inactividades = MATOTA.GetInactividadesEnPeriodo @fechaDesde, @fechaHasta, @idHotel;
END
GO
CREATE PROCEDURE MATOTA.ActualizarReservasVencidas(@fechaSistema DATETIME) AS 
BEGIN
	DECLARE @estadoVencida INT;
	SELECT @estadoVencida = idEstadoReserva FROM MATOTA.EstadoReserva WHERE descripcion LIKE '%No-Show%';

	SELECT r.idReserva INTO #vencidas FROM MATOTA.Reserva r 
	LEFT JOIN MATOTA.Estadia e ON r.idReserva = e.idReserva
	WHERE r.fechaDesde < @fechaSistema AND idEstadia IS NULL AND r.idEstadoReserva != @estadoVencida

	UPDATE MATOTA.Reserva SET idEstadoReserva = @estadoVencida WHERE idReserva IN (SELECT * FROM #vencidas);
END
GO

CREATE PROCEDURE MATOTA.habilitarHabitacionesDeReservasVencidas
AS
BEGIN
	UPDATE MATOTA.Habitacion SET habilitado = 1 
	WHERE nroHabitacion IN (SELECT nroHabitacion FROM MATOTA.ReservaHabitacion rh JOIN MATOTA.Reserva r ON (rh.idReserva = r.idReserva) WHERE r.idEstadoReserva = 5)
END
GO
CREATE FUNCTION MATOTA.ReservaEsValida(@idReserva INT, @idHotel INT, @fechaSistema DATETIME)
RETURNS BIT AS
BEGIN
	DECLARE @valida BIT;

	SELECT @valida = COUNT(r.idReserva) FROM MATOTA.Reserva r
	LEFT JOIN MATOTA.Estadia e ON r.idReserva = e.idReserva
	WHERE r.idReserva = @idReserva AND r.idHotel = @idHotel AND fechaDesde = @fechaSistema AND idEstadia IS NULL;

	RETURN @valida
END
GO
CREATE PROCEDURE MATOTA.habitacionParaReserva(@idHotel int,@cantPersonasReserva int)
AS
BEGIN
	SELECT TOP 1 nroHabitacion FROM MATOTA.Habitacion h JOIN MATOTA.TipoHabitacion th ON (h.idTipoHabitacion = th.idTipoHabitacion) 
	WHERE idHotel = @idHotel AND th.cantidadPersonas >= @cantPersonasReserva AND h.habilitado = 1
END 
GO
CREATE FUNCTION MATOTA.PrecioHabitacion(@idHotel int,@nroHabitacion int,@cantPersonas int,@idRegimen int)
RETURNS NUMERIC(10,2) 
AS
BEGIN
	DECLARE @precio NUMERIC(10,2),@recargaEstrellas numeric(18,0),@porcentajeHabitacion numeric(18,2),@precioBase numeric(18,2);
	SET @recargaEstrellas = (SELECT TOP 1 recargaEstrellas FROM MATOTA.Hotel WHERE idHotel = @idHotel)
	SET @porcentajeHabitacion = (SELECT TOP 1 porcentajeExtra FROM MATOTA.TipoHabitacion th JOIN MATOTA.Habitacion h ON (th.idTipoHabitacion = h.idTipoHabitacion) WHERE h.nroHabitacion = @nroHabitacion and h.idHotel = @idHotel)
	SET @precioBase = (SELECT TOP 1 precioBase FROM MATOTA.Regimen WHERE idRegimen = @idRegimen)
	SET @precio = (@recargaEstrellas*@porcentajeHabitacion*@cantPersonas) + @precioBase
	RETURN @precio
END
GO
CREATE FUNCTION MATOTA.CantNoches(@fechaInicio datetime,@fechaFin datetime)
RETURNS INT 
AS
BEGIN
	RETURN DATEDIFF(DAY,@fechaInicio,@fechaFin)
END
GO
CREATE PROCEDURE MATOTA.DatosBaseCheckIn(@idReserva INT, @cantidadPersonas INT OUT, @idCliente INT OUT, @nombreCliente NVARCHAR(255) OUT, @apellidoCliente NVARCHAR(255) OUT) AS
BEGIN
	SELECT @cantidadPersonas = COALESCE(r.cantidadPersonas, -1), 
			@idCliente = COALESCE(c.idCliente, -1),
			@nombreCliente = c.nombre,
			@apellidoCliente = c.apellido
	FROM MATOTA.Reserva r
	LEFT JOIN MATOTA.Cliente c ON c.idCliente = r.idCliente
	WHERE r.idReserva = @idReserva;
END
GO
CREATE PROCEDURE MATOTA.EfectivizarReserva(@idReserva INT) AS
BEGIN
	DECLARE @estadoEfectivizada INT;
	SELECT @estadoEfectivizada = idEstadoReserva FROM MATOTA.EstadoReserva WHERE descripcion LIKE '%efectivizada%';

	UPDATE MATOTA.Reserva SET idEstadoReserva = @estadoEfectivizada WHERE idReserva = @idReserva

	RETURN @@ROWCOUNT;
END
GO
CREATE PROCEDURE MATOTA.GetEstadiaForHabitacion(@nroHabitacion NUMERIC(18,0), @idHotel INT, @fechaSistema DATETIME, @idEstadia INT OUT, @idReservaHabitacion INT OUT) AS
BEGIN
	SELECT TOP 1 @idEstadia = e.idEstadia, @idReservaHabitacion = re.idReservaHabitacion FROM MATOTA.ReservaHabitacion re
		INNER JOIN MATOTA.Reserva r ON re.idReserva = r.idReserva 
		INNER JOIN MATOTA.Estadia e ON e.idReserva = r.idReserva 
	WHERE re.nroHabitacion = @nroHabitacion AND re.idHotel = @idHotel AND e.fechaSalida IS NULL AND  e.fechaIngreso <= @fechaSistema
	ORDER BY e.fechaIngreso DESC
END
GO
CREATE FUNCTION MATOTA.personasHabitacion (@idHotel int , @nroHabitacion int)
RETURNS INT AS
BEGIN
	DECLARE @idTipoHabitacion int
	SET @idTipoHabitacion = (SELECT idTipoHabitacion FROM MATOTA.Habitacion WHERE nroHabitacion = @nroHabitacion and idHotel=@idHotel)
	RETURN  CASE
				WHEN @idTipoHabitacion = 1001 THEN 1
				WHEN @idTipoHabitacion = 1002 THEN 2
				WHEN @idTipoHabitacion = 1003 THEN 3
				WHEN @idTipoHabitacion = 1004 THEN 4
				WHEN @idTipoHabitacion = 1005 THEN 5
				END
END
GO

CREATE PROCEDURE MATOTA.AltaReserva(@idHotel int,@fechaReserva datetime,@fechaDesde datetime,@fechaHasta datetime,@cantidadNoches int,@idRegimen int,@idCliente int,@precioBase numeric(18,2),@cantidadPersonas int)
AS
BEGIN
	INSERT INTO MATOTA.Reserva VALUES (@fechaReserva,@fechaDesde,@fechaHasta,@cantidadNoches,@idRegimen,@idHotel,1,@idCliente,@precioBase,@cantidadPersonas)
	RETURN SCOPE_IDENTITY();
END
GO

CREATE PROCEDURE MATOTA.agregarHabitacionesReservadas (@nroHabitacion int,@idReserva int, @idHotel int)
AS
BEGIN
	IF NOT EXISTS (SELECT nroHabitacion FROM MATOTA.ReservaHabitacion WHERE idReserva = @idReserva AND idHotel = @idHotel AND nroHabitacion = @nroHabitacion)
	BEGIN
	INSERT INTO MATOTA.ReservaHabitacion VALUES (@idReserva,@idHotel,@nroHabitacion)
	END
END
GO

CREATE FUNCTION MATOTA.CrearContraseña (@password VARCHAR(20))
RETURNS NVARCHAR(64)
AS
BEGIN
	RETURN (SELECT CONVERT(NVARCHAR(64),HashBytes('SHA2_256', @password),2))
END
GO

CREATE PROCEDURE MATOTA.CrearUsuario (@username NVARCHAR(10), @password VARCHAR(20), @nombre NVARCHAR(82), @apellido NVARCHAR(82), @idTipoDocumento INT, @numeroDocumento NVARCHAR(20), @mail NVARCHAR(255),
@telefono NVARCHAR(80), @calle NVARCHAR(255), @nroCalle INT, @localidad NVARCHAR(255), @pais NVARCHAR(60), @fechaNacimiento DATETIME, @piso INT = NULL, @departamento NVARCHAR(3) = NULL)
AS
BEGIN
	INSERT INTO MATOTA.Usuario (username, password, nombre, apellido, idTipoDocumento, numeroDocumento, mail, telefono, calle, nroCalle, piso, departamento, localidad, pais, fechaNacimiento, habilitado)
	VALUES (@username, MATOTA.CrearContraseña(@password) , @nombre, @apellido, @idTipoDocumento, @numeroDocumento, @mail, @telefono, @calle, @nroCalle, @piso, @departamento, @localidad, @pais, @fechaNacimiento, 1)
	RETURN (SELECT idUsuario FROM MATOTA.Usuario u WHERE u.username = @username)
END
GO

CREATE PROCEDURE MATOTA.UpdateReserva(@idReserva int,@fechaDesde datetime,@fechaHasta datetime,@cantNoches int,@idRegimen int,@precioBaseReserva numeric(18,2),@cantidadPersonas int)
AS
BEGIN	
	UPDATE MATOTA.Reserva SET fechaDesde = @fechaDesde,fechaHasta = @fechaHasta,
	cantidadNoches = @cantNoches,idRegimen=@idRegimen,idEstadoReserva = 2,precioBaseReserva = @precioBaseReserva,cantidadPersonas = @cantidadPersonas
	WHERE idReserva = @idReserva
	RETURN 1;
END
GO

CREATE PROCEDURE MATOTA.QuitarHabitacionesReserva(@nroHabitacion int,@idReserva int, @idHotel int)
AS
BEGIN
	DELETE FROM MATOTA.ReservaHabitacion WHERE nroHabitacion = @nroHabitacion AND idReserva = @idReserva AND idHotel = @idHotel
	UPDATE MATOTA.Habitacion SET habilitado = 1 WHERE nroHabitacion = @nroHabitacion AND idHotel = @idHotel
	RETURN 1
END
GO

CREATE PROCEDURE MATOTA.GetHabitacionesReserva(@idReserva numeric(18,0))
AS
BEGIN
	SELECT nroHabitacion FROM MATOTA.ReservaHabitacion WHERE idReserva = @idReserva
END
GO
CREATE PROCEDURE MATOTA.CancelarReserva(@idReserva numeric(18,0),@motivo nvarchar(500),@fecha datetime,@idUsuario int)
AS
BEGIN
	IF EXISTS (SELECT idReserva FROM MATOTA.ReservaCancelada WHERE idReserva = @idReserva)
		RETURN 0;
	ELSE
	BEGIN
		DECLARE @estadoReserva int
		IF (@idUsuario = -1)
		BEGIN
			SET @idUsuario = null
			SET @estadoReserva = 4
			INSERT INTO MATOTA.ReservaCancelada VALUES(@idReserva,@motivo,@fecha,@idUsuario)
		END
		ELSE
		BEGIN
			INSERT INTO MATOTA.ReservaCancelada VALUES(@idReserva,@motivo,@fecha,@idUsuario)
			SET @estadoReserva = 3
		END
		UPDATE MATOTA.Reserva SET idEstadoReserva = @estadoReserva
		RETURN 1;
	END
	
END
GO

CREATE PROCEDURE MATOTA.HabitacionesNoReservadas(@idHotel int,@fechaDesde datetime,@fechaHasta datetime)
AS
BEGIN
		SELECT h.nroHabitacion,th.descripcion Tipo,u.descripcion Ubicacion
		FROM MATOTA.Habitacion h JOIN MATOTA.TipoHabitacion th ON (h.idTipoHabitacion = th.idTipoHabitacion) JOIN MATOTA.UbicacionHabitacion u ON (h.idUbicacion = u.idUbicacion)
		WHERE h.idHotel = @idHotel AND h.nroHabitacion NOT IN 
									(SELECT distinct h.nroHabitacion FROM MATOTA.Habitacion h,MATOTA.Reserva r,Matota.ReservaHabitacion rh WHERE h.idHotel = @idHotel AND h.nroHabitacion = rh.nroHabitacion
									 AND r.idReserva = rh.idReserva AND(
									 (@fechaDesde BETWEEN r.fechaDesde AND r.fechaHasta) OR 
									 (@fechaHasta BETWEEN r.fechaDesde AND r.fechaHasta) OR
									 (@fechaDesde <= r.fechaDesde AND @fechaHasta >= r.fechaHasta)))

END
GO

CREATE FUNCTION MATOTA.FechaCorrectaParaModificarReserva(@idReserva int,@fechaSistema datetime)
RETURNS BIT
AS
BEGIN
	DECLARE @fechaDesde datetime
	SET @fechaDesde = (SELECT fechaDesde FROM MATOTA.Reserva WHERE idReserva = @idReserva)
	IF(@fechaDesde - @fechaSistema >=1)
		RETURN 1;
	RETURN 0;
END
GO


-- Estadisticas
CREATE PROCEDURE MATOTA.PeriodoTrimestre(@nroTrimestre INT, @year INT, @fdesde DATE OUT, @fhasta DATE OUT) AS
BEGIN
	DECLARE @desde TINYINT, @hasta TINYINT;

	IF @nroTrimestre = 1
	BEGIN
		SELECT @desde = 1, @hasta = 3
	END

	IF @nroTrimestre = 2
	BEGIN
		SELECT @desde = 4, @hasta = 6
	END

	IF @nroTrimestre = 3
	BEGIN
		SELECT @desde = 7, @hasta = 9
	END

	IF @nroTrimestre = 4
	BEGIN
		SELECT @desde = 10, @hasta = 12
	END

	SELECT @fdesde = DATEFROMPARTS(@year, @desde, 1), @fhasta = DATEFROMPARTS(@year, @hasta, (CASE  WHEN (@nroTrimestre = 1 OR @nroTrimestre = 4) THEN 31 ELSE 30 END))
END
GO

CREATE PROCEDURE MATOTA.HotelesReservasCanceladas(@nroTrimestre INT, @year INT) AS
BEGIN
	DECLARE	@desde DATE, @hasta DATE;
	EXEC MATOTA.PeriodoTrimestre @nroTrimestre, @year, @desde OUT, @hasta OUT

	SELECT TOP 5 h.nombre, h.calle, h.nroCalle, h.ciudad, h.pais, COUNT(r.idReserva) 'Reservas Canceladas' FROM MATOTA.Hotel h
		INNER JOIN MATOTA.Reserva r ON r.idHotel = h.idHotel
		INNER JOIN MATOTA.EstadoReserva er ON r.idEstadoReserva = er.idEstadoReserva
		WHERE er.descripcion LIKE '%cancelada%' AND r.fechaDesde BETWEEN @desde AND @hasta
		GROUP BY h.nombre, h.calle, h.nroCalle, h.ciudad, h.pais, h.idHotel
		ORDER BY 6 DESC
END
GO
CREATE PROCEDURE MATOTA.HotelesMayorCantConsumibles(@nroTrimestre INT, @year INT) AS
BEGIN
	DECLARE	@desde DATE, @hasta DATE;
	EXEC MATOTA.PeriodoTrimestre @nroTrimestre, @year, @desde OUT, @hasta OUT

	SELECT TOP 5 h.nombre, h.calle, h.nroCalle, h.ciudad, h.pais, COUNT(ce.idConsumibleEstadia) 'Consumibles Facturados' FROM MATOTA.Hotel h
		INNER JOIN MATOTA.ReservaHabitacion rh ON rh.idHotel = h.idHotel
		INNER JOIN MATOTA.ConsumiblesEstadia ce ON ce.idReservaHabitacion = rh.idReservaHabitacion
		INNER JOIN MATOTA.Reserva r ON r.idReserva = rh.idReserva
		WHERE r.fechaDesde BETWEEN @desde AND @hasta
		GROUP BY h.nombre, h.calle, h.nroCalle, h.ciudad, h.pais, h.idHotel
		ORDER BY 6 DESC
END
GO
CREATE PROCEDURE MATOTA.HotelesMayorDiasInactivo(@nroTrimestre INT, @year INT) AS
BEGIN
	DECLARE	@desde DATE, @hasta DATE;
	EXEC MATOTA.PeriodoTrimestre @nroTrimestre, @year, @desde OUT, @hasta OUT

	SELECT TOP 5 h.nombre, h.calle, h.nroCalle, h.ciudad, h.pais, SUM( DATEDIFF(DAY, ih.fechaInicio, ih.fechaFin) ) 'Dias Inactivo' FROM MATOTA.Hotel h
		INNER JOIN MATOTA.InactividadHotel ih ON ih.idHotel = h.idHotel
		WHERE ih.fechaInicio BETWEEN @desde AND @hasta AND ih.fechaFin BETWEEN @desde AND @hasta
		GROUP BY h.nombre, h.calle, h.nroCalle, h.ciudad, h.pais, h.idHotel
		ORDER BY 6 DESC
END
GO
CREATE PROCEDURE MATOTA.HabitacionesMasOcupadas(@nroTrimestre INT, @year INT) AS
BEGIN
	DECLARE	@desde DATE, @hasta DATE;
	EXEC MATOTA.PeriodoTrimestre @nroTrimestre, @year, @desde OUT, @hasta OUT

	SELECT TOP 5 h.nombre, h.calle, h.nroCalle, h.ciudad, h.pais, rh.nroHabitacion,
	SUM(
		CASE 
			WHEN e.fechaSalida IS NULL THEN e.cantidadNoches
			ELSE DATEDIFF(DAY, e.fechaIngreso, e.fechaSalida)
		END
		) 
	'Dias Ocupada', 
	COUNT (*) 'Veces Ocupada' 
	FROM MATOTA.ReservaHabitacion rh 
	INNER JOIN MATOTA.Estadia e ON rh.idReserva = e.idReserva
	INNER JOIN MATOTA.Hotel h ON rh.idHotel = h.idHotel
	WHERE e.fechaIngreso BETWEEN @desde AND @hasta 
	AND (CASE
			WHEN e.fechaSalida IS NULL THEN (e.fechaIngreso + e.cantidadNoches) 
			ELSE e.fechaSalida 
		END) BETWEEN @desde AND @hasta
	GROUP BY h.nombre, h.calle, h.nroCalle, h.ciudad, h.pais, rh.nroHabitacion
	ORDER BY 7 DESC, 8 DESC
END
GO

CREATE PROCEDURE MATOTA.ClientesConMasPuntos (@nroTrimestre INT, @year INT) AS
BEGIN
	DECLARE	@desde DATE, @hasta DATE;
	EXEC MATOTA.PeriodoTrimestre @nroTrimestre, @year, @desde OUT, @hasta OUT

	SELECT TOP 5 c.nombre, c.apellido, td.nombre 'Tipo Documento', c.numeroDocumento, SUM(
	CAST(itmf.cantidad * itmf.monto 
	*
	(
	CASE
		WHEN itmf.descripcion = 'Estadia' THEN e.cantidadNoches / 20.0
		ELSE 1 / 10.0
	END
	) 
	AS INT)) 'Puntos'
	FROM MATOTA.Cliente c
	INNER JOIN MATOTA.TipoDocumento td	ON c.idTipoDocumento = td.IdTipoDocumento
	INNER JOIN MATOTA.Reserva r			ON c.idCliente = r.idCliente
	INNER JOIN MATOTA.Estadia e			ON r.idReserva = e.idReserva
	INNER JOIN MATOTA.Factura f			ON e.idEstadia = f.idEstadia
	INNER JOIN MATOTA.ItemFactura itmf	ON f.idFactura = itmf.idFactura
	WHERE f.fecha BETWEEN @desde AND @hasta
	GROUP BY c.nombre, c.apellido, td.nombre, c.numeroDocumento
	ORDER BY 'Puntos' DESC
END
