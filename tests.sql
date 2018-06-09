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

---
DECLARE @reservas INT, @estadias INT;
EXEC MATOTA.CheckRegimenHotelConstraint '2020-01-01',1,1, @reservas OUT, @estadias OUT;

select @reservas, @estadias

---
DECLARE @reservas INT, @estadias INT;
EXEC MATOTA.ReservasEstadiasEnPeriodo '2020-01-01',1,1, @reservas OUT, @estadias OUT;

select @reservas, @estadias