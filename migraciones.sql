use GD1C2018
set tran isolation level read uncommitted
begin tran migracion
-- Migrar Tipos de Habitacion:
SET IDENTITY_INSERT MATOTA.TipoHabitacion ON 

INSERT INTO MATOTA.TipoHabitacion (idTipoHabitacion, descripcion, porcentajeExtra)
SELECT DISTINCT(Habitacion_Tipo_Codigo), Habitacion_Tipo_Descripcion, Habitacion_Tipo_Porcentual FROM gd_esquema.Maestra ORDER BY 1

SET IDENTITY_INSERT MATOTA.TipoHabitacion OFF

-- Migrar Hoteles
INSERT INTO MATOTA.Hotel (ciudad, calle, nroCalle, cantidadEstrellas, recargaEstrellas)
SELECT Hotel_Ciudad, Hotel_Calle, Hotel_Nro_Calle,  Hotel_CantEstrella, Hotel_Recarga_Estrella 
FROM gd_esquema.Maestra GROUP BY Hotel_Calle, Hotel_Nro_Calle, Hotel_Ciudad, Hotel_CantEstrella, Hotel_Recarga_Estrella

--Migrar Regímenes

INSERT INTO MATOTA.Regimen (nombre, precioBase, estado)
SELECT DISTINCT Regimen_Descripcion, Regimen_Precio, 1
FROM gd_esquema.Maestra 

--Migrar RegimenHotel
INSERT INTO MATOTA.RegimenHotel (idHotel, idRegimen)
SELECT h.idHotel, r.idRegimen FROM MATOTA.Hotel h, MATOTA.Regimen r, gd_esquema.Maestra gd
WHERE h.ciudad=gd.Hotel_ciudad 
AND h.calle=gd.Hotel_Calle 
AND h.nroCalle=gd.Hotel_Nro_Calle
AND r.nombre=gd.Regimen_Descripcion
GROUP BY h.idHotel, r.idRegimen

-- Migrar Habitaciones intentar con case

DECLARE @FRENTE int = (SELECT idUbicacion FROM MATOTA.UbicacionHabitacion WHERE descripcion = 'Frente')

DECLARE @NOFRENTE int = (SELECT idUbicacion FROM MATOTA.UbicacionHabitacion WHERE descripcion = 'No Frente')


INSERT INTO MATOTA.Habitacion (idHotel,nroHabitacion,piso, idTipoHabitacion, habilitado, idUbicacion)
SELECT h.idHotel, ma.Habitacion_Numero, ma.Habitacion_Piso, t.idTipoHabitacion, 1, 
'Ubicacion' = CASE 
WHEN ma.Habitacion_Frente = 'S' THEN @FRENTE 
WHEN ma.Habitacion_Frente = 'N' THEN @NOFRENTE
END

FROM MATOTA.Hotel h, gd_esquema.Maestra ma, MATOTA.UbicacionHabitacion u, MATOTA.TipoHabitacion t
WHERE h.ciudad=ma.Hotel_ciudad 
AND h.calle=ma.Hotel_Calle 
AND h.nroCalle=ma.Hotel_Nro_Calle
AND t.idTipoHabitacion=ma.Habitacion_Tipo_Codigo
GROUP BY h.idHotel, ma.Habitacion_Numero, ma.Habitacion_Piso, t.idTipoHabitacion, ma.Habitacion_Frente


--Migrar consumibles
SET IDENTITY_INSERT MATOTA.Consumible ON 

INSERT INTO MATOTA.Consumible (codigoConsumible, descripcion, precio)
SELECT DISTINCT Consumible_Codigo, Consumible_Descripcion, Consumible_Precio FROM gd_esquema.Maestra 
WHERE Consumible_Codigo IS NOT NULL
ORDER BY 1

SET IDENTITY_INSERT MATOTA.Consumible  OFF

--Migracion clientes

SELECT Cliente_Pasaporte_Nro INTO #PasaportesUnicos FROM gd_esquema.Maestra GROUP BY Cliente_Pasaporte_Nro
										HAVING COUNT(distinct Cliente_Apellido) = 1 AND COUNT(distinct Cliente_Nombre) = 1

-- Optimizacion de obtencion de pasaportes
CREATE INDEX idx_pasaportes ON #PasaportesUnicos (Cliente_Pasaporte_Nro)

SELECT Cliente_Mail INTO #MailsUnicos FROM gd_esquema.Maestra GROUP BY Cliente_Mail
							HAVING COUNT(DISTINCT Cliente_Pasaporte_Nro) = 1


DECLARE @tipopasaporte INT = (SELECT idTipoDocumento FROM MATOTA.TipoDocumento WHERE nombre = 'PASAPORTE')


INSERT INTO MATOTA.Cliente (numeroDocumento, idTipoDocumento, apellido, nombre, mail, fechaNacimiento, calle, nroCalle, piso, departamento, nacionalidad)
-- Todos bien
SELECT DISTINCT Cliente_Pasaporte_Nro,@tipopasaporte, Cliente_Apellido, Cliente_Nombre, Cliente_Mail, Cliente_Fecha_Nac, Cliente_Dom_Calle,
		Cliente_Nro_Calle, Cliente_Piso, Cliente_Depto, Cliente_Nacionalidad
FROM gd_esquema.Maestra 
	WHERE EXISTS (SELECT * FROM #PasaportesUnicos pu WHERE pu.Cliente_Pasaporte_Nro = gd_esquema.Maestra.Cliente_Pasaporte_Nro) 
	AND Cliente_Mail IN (SELECT * FROM #MailsUnicos)			
ORDER BY Cliente_Pasaporte_Nro


INSERT INTO MATOTA.Cliente (numeroDocumento, idTipoDocumento, apellido, nombre, mail, fechaNacimiento, calle, nroCalle, piso, departamento, nacionalidad, valido)
-- Mails Repetidos
SELECT DISTINCT Cliente_Pasaporte_Nro,@tipopasaporte, Cliente_Apellido, Cliente_Nombre, 'Mail repetido '+ CAST(Cliente_Pasaporte_Nro AS varchar(10))+': '+Cliente_Mail, Cliente_Fecha_Nac, Cliente_Dom_Calle,
		Cliente_Nro_Calle, Cliente_Piso, Cliente_Depto, Cliente_Nacionalidad,0
FROM gd_esquema.Maestra 
	WHERE EXISTS (SELECT * FROM #PasaportesUnicos pu WHERE pu.Cliente_Pasaporte_Nro = gd_esquema.Maestra.Cliente_Pasaporte_Nro) 
	AND Cliente_Mail NOT IN (SELECT * FROM #MailsUnicos)			
ORDER BY Cliente_Pasaporte_Nro


INSERT INTO MATOTA.Cliente (numeroDocumento, idTipoDocumento, apellido, nombre, mail, fechaNacimiento, calle, nroCalle, piso, departamento, nacionalidad, valido)
-- Pasaporte Repetidos
SELECT DISTINCT Cliente_Pasaporte_Nro,@tipopasaporte, Cliente_Apellido, Cliente_Nombre, Cliente_Mail, Cliente_Fecha_Nac, Cliente_Dom_Calle,
		Cliente_Nro_Calle, Cliente_Piso, Cliente_Depto, Cliente_Nacionalidad,0
FROM gd_esquema.Maestra 
	WHERE NOT EXISTS (SELECT * FROM #PasaportesUnicos pu WHERE pu.Cliente_Pasaporte_Nro = gd_esquema.Maestra.Cliente_Pasaporte_Nro) 
	AND Cliente_Mail IN (SELECT * FROM #MailsUnicos)			
ORDER BY Cliente_Pasaporte_Nro

INSERT INTO MATOTA.Cliente (numeroDocumento, idTipoDocumento, apellido, nombre, mail, fechaNacimiento, calle, nroCalle, piso, departamento, nacionalidad, valido)
-- Pasaporte y Mail Repetido
SELECT DISTINCT Cliente_Pasaporte_Nro, @tipopasaporte,Cliente_Apellido, Cliente_Nombre, 'Mail repetido '+ CAST((SCOPE_IDENTITY()) AS varchar(10)) + ': '+Cliente_Mail, Cliente_Fecha_Nac, Cliente_Dom_Calle,
		Cliente_Nro_Calle, Cliente_Piso, Cliente_Depto, Cliente_Nacionalidad,0
FROM gd_esquema.Maestra 
	WHERE NOT EXISTS (SELECT * FROM #PasaportesUnicos pu WHERE pu.Cliente_Pasaporte_Nro = gd_esquema.Maestra.Cliente_Pasaporte_Nro) 
	AND Cliente_Mail NOT IN (SELECT * FROM #MailsUnicos)			
ORDER BY Cliente_Pasaporte_Nro

-- Migrar Reservas

DECLARE @ESTADORESERVA INT = (SELECT idEstadoReserva FROM MATOTA.EstadoReserva WHERE descripcion = 'Reserva Migrada')

SET IDENTITY_INSERT MATOTA.Reserva ON
INSERT INTO MATOTA.Reserva (idReserva, fechaDesde, cantidadNoches, idRegimen, idEstadoReserva, idCliente, precioBaseReserva)
SELECT DISTINCT Reserva_Codigo, Reserva_Fecha_Inicio, Reserva_Cant_Noches, re.idRegimen, @ESTADORESERVA, cl.idCliente, Regimen_Precio FROM gd_esquema.Maestra
INNER JOIN MATOTA.Regimen re ON re.Nombre = Regimen_Descripcion
INNER JOIN MATOTA.Cliente cl ON (cl.idTipoDocumento = @tipopasaporte AND cl.numeroDocumento = Cliente_Pasaporte_Nro AND cl.apellido = Cliente_Apellido AND cl.nombre = Cliente_Nombre)
SET IDENTITY_INSERT MATOTA.Reserva OFF


-- Migrar Estadias

INSERT INTO MATOTA.Estadia (idReserva, fechaIngreso, cantidadNoches)
select distinct Reserva_Codigo, Estadia_Fecha_Inicio, Estadia_Cant_Noches FROM gd_esquema.Maestra
WHERE Estadia_Cant_Noches IS NOT NULL

INSERT INTO MATOTA.ClientesEstadia 
SELECT e.idEstadia, r.idCliente FROM MATOTA.Estadia e 
INNER JOIN MATOTA.Reserva r ON e.idReserva = r.idReserva


--FACTURAS
SET IDENTITY_INSERT MATOTA.Factura ON

INSERT INTO MATOTA.Factura (idFactura, idEstadia, fecha, total, migrado)
SELECT DISTINCT m.Factura_Nro, e.idEstadia, m.Factura_Fecha, m.Factura_Total, 1
FROM gd_esquema.Maestra m
INNER JOIN MATOTA.Estadia e ON e.idReserva = m.Reserva_Codigo
WHERE m.Factura_Nro IS NOT NULL

SET IDENTITY_INSERT MATOTA.Factura OFF

-- RESERVAS HABITACION
INSERT INTO MATOTA.ReservaHabitacion (idReserva, idHotel, nroHabitacion)
SELECT DISTINCT Reserva_Codigo, h.idHotel, Habitacion_Numero FROM gd_esquema.Maestra
INNER JOIN MATOTA.Hotel h ON Hotel_Calle = h.calle AND Hotel_Nro_Calle = h.nroCalle AND Hotel_Ciudad = h.ciudad

-- CONSUMIBLES ESTADIA
INSERT INTO MATOTA.ConsumiblesEstadia (codigoConsumible, cantidad, idReservaHabitacion, precioAlMomento)
SELECT Consumible_Codigo, 
				Item_Factura_Cantidad, 
				(SELECT idReservaHabitacion FROM MATOTA.ReservaHabitacion rh 
					INNER JOIN MATOTA.Hotel h ON rh.idHotel = h.idHotel
				WHERE rh.idReserva = gd_esquema.Maestra.Reserva_Codigo AND rh.nroHabitacion = gd_esquema.Maestra.Habitacion_Numero
					AND h.calle = gd_esquema.Maestra.Hotel_Calle AND h.nroCalle = gd_esquema.Maestra.Hotel_Nro_Calle AND h.ciudad = gd_esquema.Maestra.Hotel_Ciudad
					) idReservaHabitacion,	
				Item_Factura_Monto
				 FROM gd_esquema.Maestra WHERE Consumible_Codigo IS NOT NULL


-- ITEMS FACTURA
INSERT INTO MATOTA.ItemFactura(idFactura, descripcion, idConsumibleEstadia, cantidad, monto)
SELECT DISTINCT Factura_Nro, COALESCE(Consumible_Descripcion, 'Estadia') descr, ce.idConsumibleEstadia, Item_Factura_Cantidad, Item_Factura_Monto FROM gd_esquema.Maestra
LEFT JOIN MATOTA.Hotel h ON (h.calle = gd_esquema.Maestra.Hotel_Calle AND h.nroCalle = gd_esquema.Maestra.Hotel_Nro_Calle AND h.ciudad = gd_esquema.Maestra.Hotel_Ciudad)
LEFT JOIN MATOTA.ReservaHabitacion rh ON (rh.idHotel = h.idHotel AND rh.idReserva = Reserva_Codigo AND rh.nroHabitacion = Habitacion_Numero)
LEFT JOIN MATOTA.ConsumiblesEstadia ce ON (ce.idReservaHabitacion = rh.idReservaHabitacion AND ce.cantidad = Item_Factura_Cantidad AND ce.codigoConsumible = Consumible_Codigo AND ce.precioAlMomento = Item_Factura_Monto)
WHERE Factura_Nro IS NOT NULL 

commit tran migracion