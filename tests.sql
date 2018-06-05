USE GD1C2018;
-- Test: Login incorrecto > 3 veces inhabilita usuario
select intentosPassword, habilitado from MATOTA.Usuario where idUsuario = 1

DECLARE @scode INT;
EXEC @scode = MATOTA.loginUsuario 'admin', 'wS23e';
SELECT @scode