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
CREATE PROCEDURE MATOTA.UpdateHabitacion(@idHotel int,@nroHabitacionAnterior numeric(18,0),@nroHabitacion numeric(18,0),@piso numeric(18,0),
									@idUbicacion int,@idTipoHabitacion numeric(18,0),@descripcion nvarchar(255),
									@comodidades nvarchar(255),@habilitado bit)
AS
BEGIN
	IF (@nroHabitacion = @nroHabitacionAnterior)
	BEGIN	
		UPDATE MATOTA.Habitacion SET piso = @piso, idUbicacion = @idUbicacion, descripcion = @descripcion,
							  comodidades = @comodidades, habilitado = @habilitado
		WHERE idHotel = @idHotel AND nroHabitacion = @nroHabitacion
		RETURN 1;
	END
	IF EXISTS (SELECT idHotel,nroHabitacion FROM MATOTA.Habitacion WHERE idHotel = @idHotel AND nroHabitacion = @nroHabitacion AND @nroHabitacion != @nroHabitacionAnterior)
		RETURN 0;
	IF EXISTS (SELECT r.idReservaHabitacion FROM MATOTA.ReservaHabitacion r JOIN MATOTA.Habitacion h ON h.nroHabitacion = r.nroHabitacion WHERE h.nroHabitacion = @nroHabitacionAnterior)
		RETURN -1;
	INSERT INTO MATOTA.Habitacion VALUES (@idHotel,@nroHabitacion,@piso,@idUbicacion,@idTipoHabitacion,@descripcion,@comodidades,@habilitado)
	DELETE FROM MATOTA.Habitacion WHERE idHotel = @idHotel AND nroHabitacion = @nroHabitacionAnterior
	RETURN 1
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
CREATE PROCEDURE MATOTA.ReservaEsValidaCheckIn(@idReserva INT, @idHotel INT, @fechaSistema DATETIME, @fechaInicio DATE OUT, @hotelReserva VARCHAR(255) OUT, @inhabilitadoHasta DATE OUT) AS
BEGIN
	SELECT @fechaInicio = NULL, @hotelReserva = NULL;
	SELECT @inhabilitadoHasta = fechaFin FROM MATOTA.InactividadHotel WHERE idHotel = @idHotel AND @fechaSistema BETWEEN fechaInicio AND fechaFin
	IF @inhabilitadoHasta IS NOT NULL
		RETURN -1; -- El hotel está inhabilitado en la fecha del sistema.

	DECLARE @idHotelReserva INT, @idEstadia INT;
	SELECT @idHotelReserva = NULL, @idEstadia = NULL;

	SELECT @fechaInicio = r.fechaDesde, @idHotelReserva = h.idHotel, @hotelReserva = h.nombre + '(ID: '+ CAST(h.idHotel AS varchar) + ')', @idEstadia = e.idEstadia FROM MATOTA.Reserva r
	INNER JOIN MATOTA.Hotel h ON r.idHotel = h.idHotel
	LEFT JOIN MATOTA.Estadia e ON r.idReserva = e.idReserva
	WHERE r.idReserva = @idReserva

	IF @fechaInicio IS NULL AND @idHotelReserva IS NULL
		RETURN -2; -- La reserva no fue encontrada.

	IF @idEstadia IS NOT NULL
		RETURN -5; -- La reserva ya fue efectivizada.

	IF @fechaInicio != @fechaSistema
		RETURN -3; -- La reserva no es para esta fecha.

	IF @idHotelReserva != @idHotel
		RETURN -4; -- La reseva no pertenece al hotel indicado.

	RETURN 1; -- Reserva valida.
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
		WHERE h.idHotel = @idHotel AND h.habilitado = 1 AND h.nroHabitacion NOT IN 
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
