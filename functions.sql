USE GD1C2018;

CREATE FUNCTION MATOTA.loginUsuario(@username varchar(10), @password varchar(20))
RETURNS BIT
BEGIN
	DECLARE @pwd CHAR(64);
	SELECT @pwd = password FROM MATOTA.Usuario WHERE username = @username;

	IF(@pwd = (SELECT CONVERT(NVARCHAR(64),HashBytes('SHA2_256', @password),2)) )
		RETURN 1;
	ELSE
		BEGIN
			UPDATE MATOTA.Usuario SET intentosPassword += 1;
			RETURN 0;
		END
END

CREATE TRIGGER MATOTA.OnUsuarioUpdate ON MATOTA.Usuario
AFTER UPDATE AS
BEGIN
	IF(UPDATE(intentosPassword))
		IF( (SELECT TOP 1 intentosPassword FROM inserted) == 3)
			UPDATE MATOTA.Usuario SET habilitado = 0 WHERE 
END