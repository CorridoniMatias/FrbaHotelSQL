USE GD1C2018;
-- TRIGGERS
DROP TRIGGER MATOTA.OnUsuarioUpdate
-- FUNCTIONS & PROCEDURES
DROP PROCEDURE MATOTA.loginUsuario
DROP FUNCTION MATOTA.GetGuestRoleID
DROP PROCEDURE MATOTA.UpdatePassword
DROP PROCEDURE MATOTA.altaCliente
DROP PROCEDURE MATOTA.crearRol
-- TYPES
DROP TYPE MATOTA.TablaPermisos
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