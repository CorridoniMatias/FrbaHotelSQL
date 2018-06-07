USE GD1C2018;
GO
CREATE PROCEDURE MATOTA.loginUsuario(@username varchar(10), @password varchar(20)) AS
BEGIN
	DECLARE @pwd CHAR(64), @enabled BIT;
	SELECT @pwd = password, @enabled = habilitado FROM MATOTA.Usuario WHERE username = @username;

	IF(@enabled = 0)
		RETURN -1;

	IF(@pwd = (SELECT CONVERT(NVARCHAR(64),HashBytes('SHA2_256', @password),2)) )
		BEGIN
			UPDATE MATOTA.Usuario SET intentosPassword = 0;
			RETURN 1;
		END

	UPDATE MATOTA.Usuario SET intentosPassword += 1;
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
