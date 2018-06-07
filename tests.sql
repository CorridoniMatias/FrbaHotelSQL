USE GD1C2018;
-- Test: Login incorrecto > 3 veces inhabilita usuario
select intentosPassword, habilitado from MATOTA.Usuario where idUsuario = 1
update MATOTA.Usuario set intentosPassword = 0, habilitado = 1

DECLARE @scode INT;
EXEC @scode = MATOTA.loginUsuario 'admin', 'test';
SELECT @scode

DECLARE @scode INT;
EXEC @scode = MATOTA.UpdatePassword 1, 'w23e'
select @scode