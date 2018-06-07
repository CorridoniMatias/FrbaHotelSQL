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
	--IF EXISTS (SELECT idTipoDocumento,numeroDocumento FROM MATOTA.Cliente WHERE idTipoDocumento = @tipoDoc AND numeroDocumento = @numeroDocumento)
		--RETURN -1;
	--IF EXISTS (SELECT mail FROM MATOTA.Cliente WHERE mail = @mail)
		--RETURN 0;
	INSERT INTO MATOTA.Cliente VALUES (@nombre,@apellido,@tipoDoc,@numeroDocumento,@mail,@telefono,@calle,@nroCalle,
									   @piso,@departamento,@localidad,@pais,@nacionalidad,@fechaNacimiento,1,1)
	RETURN 1;
END
GO

CREATE PROCEDURE MATOTA.listarTipoDoc
AS
BEGIN
	SELECT * FROM MATOTA.TipoDocumento
END
GO
