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

CREATE TYPE MATOTA.TablaPermisos AS TABLE (
	idPermiso INT
)

GO

CREATE PROCEDURE MATOTA.crearRol (@nombre NVARCHAR(20), @permisos MATOTA.TablaPermisos READONLY, @estado BIT) AS
BEGIN
	DECLARE @idRol INT;
	IF(EXISTS(SELECT * FROM MATOTA.Rol WHERE nombre = @nombre))
		RETURN -1;
	INSERT INTO MATOTA.Rol (nombre, estado) VALUES (@nombre, @estado)
	SELECT @idRol = idRol FROM MATOTA.Rol r WHERE r.NOMBRE = @nombre
	INSERT INTO MATOTA.PermisosRol SELECT DISTINCT @idRol, idPermiso FROM @permisos
	RETURN 1;
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
	RETURN 1;
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

CREATE PROCEDURE MATOTA.agregarNombresHotel
AS
BEGIN
	UPDATE MATOTA.Hotel SET
	nombre = CASE 
				WHEN idHotel = 1 THEN 'Matota'
				WHEN idHotel = 2 THEN 'Pepy'
				WHEN idHotel = 3 THEN 'Calafate'
				WHEN idHotel = 4 THEN 'Huemul'
				WHEN idHotel = 5 THEN 'Genérico'
				WHEN idHotel = 6 THEN 'King'
				WHEN idHotel = 7 THEN 'Super Hotel'
				WHEN idHotel = 8 THEN 'Refugio'
				WHEN idHotel = 9 THEN 'Hotel'
				WHEN idHotel = 10 THEN 'Deportes'
				WHEN idHotel = 11 THEN 'GDD'
				WHEN idHotel = 12 THEN 'TGC'
				WHEN idHotel = 13 THEN 'Inolvidable'
				WHEN idHotel = 14 THEN 'PdP'
				WHEN idHotel = 15 THEN 'Panchocho'
	END
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
CREATE PROCEDURE MATOTA.ReservasEstadiasEnPeriodo(@fechaDesde DATETIME, @fechaHasta DATETIME, @idHotel INT, @reservas INT OUT, @estadias INT OUT) AS
BEGIN
	--Cuenta la cant de reservas que hay activas, se considera activa si la fecha desde todavia no paso y no fue cancelada.
	SELECT @reservas = COUNT(re.idReserva) FROM MATOTA.Reserva re
	INNER JOIN MATOTA.EstadoReserva er ON (re.idEstadoReserva = er.idEstadoReserva)
	WHERE (@fechaDesde <= re.fechaDesde AND re.fechaDesde <= @fechaHasta )--OR @fechaActual <= DATEADD(DAY, re.cantidadNoches, re.fechaDesde) 
			AND re.idHotel = @idHotel AND re.idRegimen = @idRegimen
			AND er.descripcion NOT LIKE '%cancelada%'

	-- Cuenta las estadias en curso, esta en curso si la reserva asociada tiene estado efectivizada y la fecha actual es mayor a la fecha de inicio y todavia no hay fecha de salida.
	SELECT @estadias = COUNT(e.idEstadia) FROM MATOTA.Reserva re
	INNER JOIN MATOTA.EstadoReserva er ON (re.idEstadoReserva = er.idEstadoReserva)
	INNER JOIN MATOTA.Estadia e ON (e.idReserva = re.idReserva AND (e.fechaIngreso >= @fechaDesde AND e.fechaSalida IS NULL))
	WHERE re.idHotel = @idHotel AND re.idRegimen = @idRegimen AND er.descripcion LIKE '%efectivizada%'
END
GO
