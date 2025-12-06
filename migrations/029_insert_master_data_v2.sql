-- ========================================
-- INSERCIÓN DE DATOS MAESTROS V2 (CORREGIDO)
-- ========================================

-- 1. SEDES (Agregando código)
INSERT INTO sede (codigo, nombre, direccion, activa) VALUES
('CENTRAL', 'Central', 'Ciudad de Guatemala', true),
('MAZATE', 'Mazatenango', 'Mazatenango, Suchitepéquez', true),
('POPTUN', 'Poptún', 'Poptún, Petén', true),
('SANCRIS', 'San Cristóbal', 'San Cristóbal Verapaz, Alta Verapaz', true),
('XELA', 'Quetzaltenango', 'Quetzaltenango', true),
('COATE', 'Coatepeque', 'Coatepeque, Quetzaltenango', true),
('PALIN', 'Palin Escuintla', 'Palín, Escuintla', true),
('MORALES', 'Morales', 'Morales, Izabal', true),
('RIODULCE', 'Rio Dulce', 'Río Dulce, Izabal', true)
ON CONFLICT (codigo) DO NOTHING;

-- 2. TIPOS DE VEHÍCULOS (Usando 'activo')
INSERT INTO tipo_vehiculo (nombre, activo) VALUES
('Motocicleta', true), ('Jaula Cañera', true), ('Rastra', true), ('Bicicleta', true),
('Jeep', true), ('Bus escolar', true), ('Maquinaria', true), ('Bus turismo', true),
('Tractor', true), ('Ambulancia', true), ('Camionetilla', true), ('Pulman', true),
('Autopatrulla PNC', true), ('Bus extraurbano', true), ('Bus urbano', true),
('Camioneta agricola', true), ('Cisterna', true), ('Furgon', true), ('Mototaxi', true),
('Microbus', true), ('Motobicicleta', true), ('Plataforma', true), ('Panel', true),
('Unidad de PROVIAL', true), ('Grúa', true), ('Bus institucional', true),
('Cuatrimoto', true), ('Doble remolque', true), ('Tesla', true), ('Peaton', true),
('Fugado', true), ('Sedan', true), ('Pick-up', true), ('Camión', true),
('Bus', true), ('Cabezal', true), ('Otro', true)
ON CONFLICT (nombre) DO NOTHING;

-- 3. RUTAS
INSERT INTO ruta (codigo, nombre, descripcion, activa) VALUES
('CA-1 Occidente', 'CA-1 Occidente', 'Carretera Centroamericana 1 - Tramo Occidente', true),
('CA-1 Oriente', 'CA-1 Oriente', 'Carretera Centroamericana 1 - Tramo Oriente', true),
('CA-2 Occidente', 'CA-2 Occidente', 'Carretera Centroamericana 2 - Tramo Occidente', true),
('CA-9 Norte', 'CA-9 Norte', 'Carretera Centroamericana 9 - Tramo Norte', true),
('CA-9 Sur', 'CA-9 Sur', 'Carretera Centroamericana 9 - Tramo Sur', true)
ON CONFLICT (codigo) DO NOTHING;

-- 4. UNIDADES
-- Primero obtenemos el ID de la sede Central para usarlo
DO $$
DECLARE
    sede_central_id INTEGER;
BEGIN
    SELECT id INTO sede_central_id FROM sede WHERE codigo = 'CENTRAL' LIMIT 1;
    
    IF sede_central_id IS NOT NULL THEN
        INSERT INTO unidad (codigo, tipo_unidad, marca, modelo, placa, capacidad_combustible, odometro_actual, combustible_actual, activa, sede_id) VALUES
        -- Motos
        ('M001', 'MOTOCICLETA', 'Honda', 2020, 'M001XXX', 15, 10000, 10.0, true, sede_central_id),
        ('M002', 'MOTOCICLETA', 'Suzuki', 2021, 'M002XXX', 15, 8000, 12.0, true, sede_central_id),
        ('M003', 'MOTOCICLETA', 'Honda', 2019, 'M003XXX', 15, 15000, 8.0, true, sede_central_id),
        ('M004', 'MOTOCICLETA', 'Italika', 2022, 'M004XXX', 15, 5000, 14.0, true, sede_central_id),
        ('M005', 'MOTOCICLETA', 'Suzuki', 2020, 'M005XXX', 15, 12000, 11.0, true, sede_central_id),
        ('M006', 'MOTOCICLETA', 'Honda', 2021, 'M006XXX', 15, 9000, 13.0, true, sede_central_id),
        ('M007', 'MOTOCICLETA', 'Suzuki', 2022, 'M007XXX', 15, 3000, 15.0, true, sede_central_id),
        -- Pickups 1100s
        ('1104', 'PICK-UP', 'Toyota', 2018, 'P1104XX', 80, 150000, 60.0, true, sede_central_id),
        ('1105', 'PICK-UP', 'Toyota', 2019, 'P1105XX', 80, 120000, 55.0, true, sede_central_id),
        ('1106', 'PICK-UP', 'Nissan', 2020, 'P1106XX', 80, 100000, 70.0, true, sede_central_id),
        ('1107', 'PICK-UP', 'Ford', 2018, 'P1107XX', 80, 160000, 45.0, true, sede_central_id),
        ('1108', 'PICK-UP', 'Toyota', 2021, 'P1108XX', 80, 80000, 75.0, true, sede_central_id),
        ('1109', 'PICK-UP', 'Chevrolet', 2019, 'P1109XX', 80, 130000, 50.0, true, sede_central_id),
        ('1110', 'PICK-UP', 'Nissan', 2020, 'P1110XX', 80, 110000, 65.0, true, sede_central_id),
        ('1111', 'PICK-UP', 'Toyota', 2018, 'P1111XX', 80, 155000, 40.0, true, sede_central_id),
        ('1112', 'PICK-UP', 'Ford', 2021, 'P1112XX', 80, 75000, 70.0, true, sede_central_id),
        ('1113', 'PICK-UP', 'Toyota', 2019, 'P1113XX', 80, 125000, 58.0, true, sede_central_id),
        ('1114', 'PICK-UP', 'Nissan', 2020, 'P1114XX', 80, 105000, 62.0, true, sede_central_id),
        ('1115', 'PICK-UP', 'Chevrolet', 2018, 'P1115XX', 80, 165000, 35.0, true, sede_central_id),
        ('1116', 'PICK-UP', 'Toyota', 2021, 'P1116XX', 80, 70000, 72.0, true, sede_central_id),
        ('1117', 'PICK-UP', 'Ford', 2019, 'P1117XX', 80, 135000, 48.0, true, sede_central_id),
        ('1118', 'PICK-UP', 'Nissan', 2020, 'P1118XX', 80, 115000, 60.0, true, sede_central_id),
        ('1119', 'PICK-UP', 'Toyota', 2018, 'P1119XX', 80, 170000, 30.0, true, sede_central_id),
        ('1120', 'PICK-UP', 'Chevrolet', 2021, 'P1120XX', 80, 65000, 75.0, true, sede_central_id),
        ('1121', 'PICK-UP', 'Toyota', 2019, 'P1121XX', 80, 140000, 52.0, true, sede_central_id),
        ('1122', 'PICK-UP', 'Nissan', 2020, 'P1122XX', 80, 108000, 68.0, true, sede_central_id),
        ('1123', 'PICK-UP', 'Ford', 2018, 'P1123XX', 80, 175000, 25.0, true, sede_central_id),
        ('1124', 'PICK-UP', 'Toyota', 2021, 'P1124XX', 80, 72000, 78.0, true, sede_central_id),
        ('1125', 'PICK-UP', 'Chevrolet', 2019, 'P1125XX', 80, 145000, 42.0, true, sede_central_id),
        ('1126', 'PICK-UP', 'Nissan', 2020, 'P1126XX', 80, 112000, 64.0, true, sede_central_id),
        ('1127', 'PICK-UP', 'Toyota', 2018, 'P1127XX', 80, 180000, 20.0, true, sede_central_id),
        ('1128', 'PICK-UP', 'Ford', 2021, 'P1128XX', 80, 68000, 76.0, true, sede_central_id),
        ('1129', 'PICK-UP', 'Toyota', 2019, 'P1129XX', 80, 150000, 38.0, true, sede_central_id),
        ('1130', 'PICK-UP', 'Nissan', 2020, 'P1130XX', 80, 118000, 66.0, true, sede_central_id),
        ('1131', 'PICK-UP', 'Chevrolet', 2018, 'P1131XX', 80, 185000, 15.0, true, sede_central_id),
        ('1132', 'PICK-UP', 'Toyota', 2021, 'P1132XX', 80, 60000, 80.0, true, sede_central_id),
        ('1133', 'PICK-UP', 'Ford', 2019, 'P1133XX', 80, 155000, 36.0, true, sede_central_id),
        ('1134', 'PICK-UP', 'Nissan', 2020, 'P1134XX', 80, 122000, 62.0, true, sede_central_id),
        ('1135', 'PICK-UP', 'Toyota', 2018, 'P1135XX', 80, 190000, 10.0, true, sede_central_id),
        ('1137', 'PICK-UP', 'Chevrolet', 2021, 'P1137XX', 80, 55000, 78.0, true, sede_central_id),
        ('1138', 'PICK-UP', 'Toyota', 2019, 'P1138XX', 80, 160000, 34.0, true, sede_central_id),
        ('1139', 'PICK-UP', 'Nissan', 2020, 'P1139XX', 80, 125000, 58.0, true, sede_central_id),
        -- Camionetas 1170s
        ('1170', 'CAMIONETA', 'Toyota', 2020, 'P1170XX', 100, 95000, 70.0, true, sede_central_id),
        ('1171', 'CAMIONETA', 'Nissan', 2021, 'P1171XX', 100, 85000, 75.0, true, sede_central_id),
        ('1172', 'CAMIONETA', 'Ford', 2019, 'P1172XX', 100, 105000, 65.0, true, sede_central_id),
        ('1173', 'CAMIONETA', 'Toyota', 2020, 'P1173XX', 100, 90000, 72.0, true, sede_central_id),
        ('1174', 'CAMIONETA', 'Chevrolet', 2021, 'P1174XX', 100, 80000, 78.0, true, sede_central_id),
        ('1175', 'CAMIONETA', 'Nissan', 2019, 'P1175XX', 100, 110000, 60.0, true, sede_central_id),
        ('1176', 'CAMIONETA', 'Toyota', 2020, 'P1176XX', 100, 88000, 74.0, true, sede_central_id),
        -- Unidades 00X
        ('002', 'PICK-UP', 'Toyota', 2020, 'P002XXX', 80, 100000, 60.0, true, sede_central_id),
        ('003', 'PICK-UP', 'Nissan', 2019, 'P003XXX', 80, 120000, 55.0, true, sede_central_id),
        ('004', 'PICK-UP', 'Ford', 2021, 'P004XXX', 80, 75000, 70.0, true, sede_central_id),
        ('005', 'PICK-UP', 'Toyota', 2018, 'P005XXX', 80, 150000, 45.0, true, sede_central_id),
        ('006', 'PICK-UP', 'Chevrolet', 2020, 'P006XXX', 80, 95000, 65.0, true, sede_central_id),
        ('007', 'PICK-UP', 'Nissan', 2019, 'P007XXX', 80, 115000, 58.0, true, sede_central_id),
        ('008', 'PICK-UP', 'Toyota', 2021, 'P008XXX', 80, 70000, 75.0, true, sede_central_id),
        ('009', 'PICK-UP', 'Ford', 2018, 'P009XXX', 80, 160000, 40.0, true, sede_central_id),
        ('010', 'PICK-UP', 'Chevrolet', 2020, 'P010XXX', 80, 98000, 62.0, true, sede_central_id),
        ('011', 'PICK-UP', 'Nissan', 2019, 'P011XXX', 80, 118000, 56.0, true, sede_central_id),
        ('012', 'PICK-UP', 'Toyota', 2021, 'P012XXX', 80, 68000, 78.0, true, sede_central_id),
        ('013', 'PICK-UP', 'Ford', 2018, 'P013XXX', 80, 165000, 38.0, true, sede_central_id),
        ('014', 'PICK-UP', 'Chevrolet', 2020, 'P014XXX', 80, 92000, 68.0, true, sede_central_id),
        ('015', 'PICK-UP', 'Nissan', 2019, 'P015XXX', 80, 122000, 54.0, true, sede_central_id),
        ('016', 'PICK-UP', 'Toyota', 2021, 'P016XXX', 80, 65000, 80.0, true, sede_central_id),
        ('017', 'PICK-UP', 'Ford', 2018, 'P017XXX', 80, 170000, 35.0, true, sede_central_id),
        ('018', 'PICK-UP', 'Chevrolet', 2020, 'P018XXX', 80, 88000, 72.0, true, sede_central_id),
        ('019', 'PICK-UP', 'Nissan', 2019, 'P019XXX', 80, 125000, 52.0, true, sede_central_id),
        ('020', 'PICK-UP', 'Toyota', 2021, 'P020XXX', 80, 62000, 78.0, true, sede_central_id),
        ('021', 'PICK-UP', 'Ford', 2018, 'P021XXX', 80, 175000, 32.0, true, sede_central_id),
        ('022', 'PICK-UP', 'Chevrolet', 2020, 'P022XXX', 80, 85000, 75.0, true, sede_central_id),
        ('023', 'PICK-UP', 'Nissan', 2019, 'P023XXX', 80, 128000, 50.0, true, sede_central_id),
        ('024', 'PICK-UP', 'Toyota', 2021, 'P024XXX', 80, 58000, 80.0, true, sede_central_id),
        ('025', 'PICK-UP', 'Ford', 2018, 'P025XXX', 80, 180000, 28.0, true, sede_central_id),
        ('026', 'PICK-UP', 'Chevrolet', 2020, 'P026XXX', 80, 82000, 76.0, true, sede_central_id),
        ('027', 'PICK-UP', 'Nissan', 2019, 'P027XXX', 80, 132000, 48.0, true, sede_central_id),
        ('028', 'PICK-UP', 'Toyota', 2021, 'P028XXX', 80, 55000, 78.0, true, sede_central_id),
        ('029', 'PICK-UP', 'Ford', 2018, 'P029XXX', 80, 185000, 25.0, true, sede_central_id),
        ('030', 'PICK-UP', 'Chevrolet', 2020, 'P030XXX', 80, 78000, 80.0, true, sede_central_id),
        -- Peatonal
        ('Peatonal', 'PEATONAL', NULL, NULL, NULL, 0, 0, 0.0, true, sede_central_id)
        ON CONFLICT (codigo) DO NOTHING;
    END IF;
END $$;

-- ========================================
-- RESUMEN
-- ========================================
SELECT 'Sedes: ' || COUNT(*) FROM sede;
SELECT 'Tipos: ' || COUNT(*) FROM tipo_vehiculo;
SELECT 'Rutas: ' || COUNT(*) FROM ruta;
SELECT 'Unidades: ' || COUNT(*) FROM unidad;
