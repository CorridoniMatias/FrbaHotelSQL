USE GD1C2018;
-- TRIGGERS
DROP TRIGGER MATOTA.OnUsuarioUpdate
-- FUNCTIONS & PROCEDURES
DROP FUNCTION	MATOTA.GetGuestRoleID
DROP FUNCTION	MATOTA.ReservaEsValida
DROP FUNCTION	MATOTA.GetInactividadesEnPeriodo
DROP FUNCTION	MATOTA.CantNoches
DROP FUNCTION	MATOTA.GetEstadiaForHabitacion
DROP FUNCTION	MATOTA.PrecioHabitacion
DROP PROCEDURE	MATOTA.loginUsuario
DROP PROCEDURE	MATOTA.EfectivizarReserva
DROP PROCEDURE	MATOTA.DatosBaseCheckIn
DROP PROCEDURE	MATOTA.ActualizarReservasVencidas
DROP PROCEDURE	MATOTA.UpdatePassword
DROP PROCEDURE	MATOTA.altaCliente
DROP PROCEDURE	MATOTA.UpdateCliente
DROP PROCEDURE	MATOTA.getTipoDoc
DROP PROCEDURE	MATOTA.altaHabitacion
DROP PROCEDURE	MATOTA.CheckRegimenHotelConstraint
DROP PROCEDURE	MATOTA.ReservasEstadiasEnPeriodo
DROP PROCEDURE	MATOTA.UpdateHabitacion
DROP PROCEDURE	MATOTA.habitacionParaReserva
-- TYPES
--TABLES & SCHEMA
DROP TABLE MATOTA.ItemFactura
DROP TABLE MATOTA.Factura
DROP TABLE MATOTA.FormaDePago
DROP TABLE MATOTA.ClientesEstadia
DROP TABLE MATOTA.Estadia
DROP TABLE MATOTA.ConsumiblesEstadia
DROP TABLE MATOTA.Consumible
DROP TABLE MATOTA.ReservaHabitacion
DROP TABLE MATOTA.LogReserva
DROP TABLE MATOTA.ReservaCancelada
DROP TABLE MATOTA.Reserva
DROP TABLE MATOTA.EstadoReserva
DROP TABLE MATOTA.RegimenHotel
DROP TABLE MATOTA.Regimen
DROP TABLE MATOTA.Cliente
DROP TABLE MATOTA.PermisosRol
DROP TABLE MATOTA.Permiso
DROP TABLE MATOTA.RolesUsuario 
DROP TABLE MATOTA.Rol
DROP TABLE MATOTA.Habitacion
DROP TABLE MATOTA.TipoHabitacion
DROP TABLE MATOTA.UbicacionHabitacion
DROP TABLE MATOTA.HotelesUsuario
DROP TABLE MATOTA.InactividadHotel 
DROP TABLE MATOTA.Hotel
DROP TABLE MATOTA.Usuario
DROP TABLE MATOTA.TipoDocumento
DROP TABLE #PasaportesUnicos
DROP TABLE #MailsUnicos
DROP SCHEMA MATOTA