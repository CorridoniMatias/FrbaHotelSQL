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
-------------------------------------------
INSERT INTO MATOTA.Reserva 
(fechaReserva, fechaDesde, fechaHasta, cantidadNoches, idRegimen, idHotel, idEstadoReserva, idCliente, precioBaseReserva, cantidadPersonas) 
VALUES
(GETDATE(), '2017-01-01', GETDATE(), 1, 1, 16, 1, 96945, 17, 3)

select * from MATOTA.Cliente
select * from MATOTA.Reserva

update matota.Reserva set idHotel = 12 where idReserva = 106945

select * from matota.Reserva r left join matota.Estadia e on r.idReserva = e.idReserva where r.idReserva = 106945

select * from matota.ClientesEstadia ce inner join MATOTA.Cliente c on c.idCliente = ce.idCliente where ce.idEstadia = 86301

select e.cantidadNoches, r.cantidadNoches, e.fechaIngreso from matota.Estadia e inner join MATOTA.Reserva r on r.idReserva = e.idReserva
order by 3

---------------------------------------------------------------------------------------
DECLARE @estadoEfectivizada INT;
exec @estadoEfectivizada = MATOTA.GetEstadiaForHabitacion 10,2,'2018-01-01'
select @estadoEfectivizada