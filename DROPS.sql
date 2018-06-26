USE GD1C2018;
-- TRIGGERS
DROP TRIGGER MATOTA.OnUsuarioUpdate
-- FUNCTIONS & PROCEDURES
DROP FUNCTION	MATOTA.GetGuestRoleID
DROP FUNCTION	MATOTA.ReservaEsValida
DROP FUNCTION	MATOTA.GetInactividadesEnPeriodo
DROP FUNCTION	MATOTA.CantNoches
DROP FUNCTION	MATOTA.PrecioHabitacion
DROP FUNCTION   MATOTA.personasHabitacion
DROP FUNCTION   MATOTA.CrearContraseña
DROP FUNCTION   MATOTA.FechaCorrectaParaModificarReserva
DROP PROCEDURE	MATOTA.ReservaEsValidaCheckIn
DROP PROCEDURE	MATOTA.HotelesMayorDiasInactivo
DROP PROCEDURE	MATOTA.HotelesMayorCantConsumibles
DROP PROCEDURE	MATOTA.PeriodoTrimestre
DROP PROCEDURE	MATOTA.HotelesReservasCanceladas
DROP PROCEDURE	MATOTA.GetEstadiaForHabitacion
DROP PROCEDURE	MATOTA.loginUsuario
DROP PROCEDURE	MATOTA.EfectivizarReserva
DROP PROCEDURE	MATOTA.DatosBaseCheckIn
DROP PROCEDURE	MATOTA.ActualizarReservasVencidas
DROP PROCEDURE  MATOTA.habilitarHabitacionesDeReservasVencidas
DROP PROCEDURE	MATOTA.UpdatePassword
DROP PROCEDURE	MATOTA.altaCliente
DROP PROCEDURE	MATOTA.UpdateCliente
DROP PROCEDURE	MATOTA.getTipoDoc
DROP PROCEDURE	MATOTA.altaHabitacion
DROP PROCEDURE	MATOTA.CheckRegimenHotelConstraint
DROP PROCEDURE	MATOTA.ReservasEstadiasEnPeriodo
DROP PROCEDURE	MATOTA.UpdateHabitacion
DROP PROCEDURE	MATOTA.habitacionParaReserva
DROP PROCEDURE  MATOTA.AltaReserva
DROP PROCEDURE  MATOTA.agregarHabitacionesReservadas
DROP PROCEDURE  MATOTA.CrearUsuario
DROP PROCEDURE  MATOTA.GetHabitacionesReserva
DROP PROCEDURE  MATOTA.UpdateReserva
DROP PROCEDURE  MATOTA.QuitarHabitacionesReserva
DROP PROCEDURE  MATOTA.CancelarReserva
DROP PROCEDURE  MATOTA.HabitacionesMasOcupadas
DROP PROCEDURE  MATOTA.ClientesConMasPuntos
DROP PROCEDURE  MATOTA.HabitacionesNoReservadas
DROP PROCEDURE  MATOTA.ListarHabitacionesReserva
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