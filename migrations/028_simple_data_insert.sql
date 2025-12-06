-- ========================================
-- INSERCIÓN SIMPLE DE DATOS MAESTROS
-- Sin bloques DO, solo INSERTs directos
-- ========================================

-- 1. SEDES
INSERT INTO sede (nombre, direccion, activa) VALUES
('Central', 'Ciudad de Guatemala', true),
('Mazatenango', 'Mazatenango, Suchitepéquez', true),
('Poptún', 'Poptún, Petén', true),
('San Cristóbal', 'San Cristóbal Verapaz, Alta Verapaz', true),
('Quetzaltenango', 'Quetzaltenango', true),
('Coatepeque', 'Coatepeque, Quetzaltenango', true),
('Palin Escuintla', 'Palín, Escuintla', true),
('Morales', 'Morales, Izabal', true),
('Rio Dulce', 'Río Dulce, Izabal', true);

-- 2. TIPOS DE VEHÍCULOS
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
('Bus', true), ('Cabezal', true), ('Otro', true);

-- 3. RUTAS (solo las principales para empezar)
INSERT INTO ruta (codigo, nombre, descripcion, activa) VALUES
('CA-1 Occidente', 'CA-1 Occidente', 'Carretera Centroamericana 1 - Tramo Occidente', true),
('CA-1 Oriente', 'CA-1 Oriente', 'Carretera Centroamericana 1 - Tramo Oriente', true),
('CA-2 Occidente', 'CA-2 Occidente', 'Carretera Centroamericana 2 - Tramo Occidente', true),
('CA-9 Norte', 'CA-9 Norte', 'Carretera Centroamericana 9 - Tramo Norte', true),
('CA-9 Sur', 'CA-9 Sur', 'Carretera Centroamericana 9 - Tramo Sur', true);

-- 4. UNIDADES (usando sede_id = 1 que es Central)
INSERT INTO unidad (codigo, tipo_unidad, marca, modelo, placa, capacidad_combustible, odometro_actual, combustible_actual, activa, sede_id) VALUES
-- Motos
('M001', 'MOTOCICLETA', 'Honda', 2020, 'M001XXX', 15, 10000, 10.0, true, 1),
('M002', 'MOTOCICLETA', 'Suzuki', 2021, 'M002XXX', 15, 8000, 12.0, true, 1),
('M003', 'MOTOCICLETA', 'Honda', 2019, 'M003XXX', 15, 15000, 8.0, true, 1),
('M004', 'MOTOCICLETA', 'Italika', 2022, 'M004XXX', 15, 5000, 14.0, true, 1),
('M005', 'MOTOCICLETA', 'Suzuki', 2020, 'M005XXX', 15, 12000, 11.0, true, 1),
('M006', 'MOTOCICLETA', 'Honda', 2021, 'M006XXX', 15, 9000, 13.0, true, 1),
('M007', 'MOTOCICLETA', 'Suzuki', 2022, 'M007XXX', 15, 3000, 15.0, true, 1),
-- Pickups 1100s
('1104', 'PICK-UP', 'Toyota', 2018, 'P1104XX', 80, 150000, 60.0, true, 1),
('1105', 'PICK-UP', 'Toyota', 2019, 'P1105XX', 80, 120000, 55.0, true, 1),
('1106', 'PICK-UP', 'Nissan', 2020, 'P1106XX', 80, 100000, 70.0, true, 1),
('1107', 'PICK-UP', 'Ford', 2018, 'P1107XX', 80, 160000, 45.0, true, 1),
('1108', 'PICK-UP', 'Toyota', 2021, 'P1108XX', 80, 80000, 75.0, true, 1),
('1109', 'PICK-UP', 'Chevrolet', 2019, 'P1109XX', 80, 130000, 50.0, true, 1),
('1110', 'PICK-UP', 'Nissan', 2020, 'P1110XX', 80, 110000, 65.0, true, 1),
('1111', 'PICK-UP', 'Toyota', 2018, 'P1111XX', 80, 155000, 40.0, true, 1),
('1112', 'PICK-UP', 'Ford', 2021, 'P1112XX', 80, 75000, 70.0, true, 1),
('1113', 'PICK-UP', 'Toyota', 2019, 'P1113XX', 80, 125000, 58.0, true, 1),
('1114', 'PICK-UP', 'Nissan', 2020, 'P1114XX', 80, 105000, 62.0, true, 1),
('1115', 'PICK-UP', 'Chevrolet', 2018, 'P1115XX', 80, 165000, 35.0, true, 1),
('1116', 'PICK-UP', 'Toyota', 2021, 'P1116XX', 80, 70000, 72.0, true, 1),
('1117', 'PICK-UP', 'Ford', 2019, 'P1117XX', 80, 135000, 48.0, true, 1),
('1118', 'PICK-UP', 'Nissan', 2020, 'P1118XX', 80, 115000, 60.0, true, 1),
('1119', 'PICK-UP', 'Toyota', 2018, 'P1119XX', 80, 170000, 30.0, true, 1),
('1120', 'PICK-UP', 'Chevrolet', 2021, 'P1120XX', 80, 65000, 75.0, true, 1),
('1121', 'PICK-UP', 'Toyota', 2019, 'P1121XX', 80, 140000, 52.0, true, 1),
('1122', 'PICK-UP', 'Nissan', 2020, 'P1122XX', 80, 108000, 68.0, true, 1),
('1123', 'PICK-UP', 'Ford', 2018, 'P1123XX', 80, 175000, 25.0, true, 1),
('1124', 'PICK-UP', 'Toyota', 2021, 'P1124XX', 80, 72000, 78.0, true, 1),
('1125', 'PICK-UP', 'Chevrolet', 2019, 'P1125XX', 80, 145000, 42.0, true, 1),
('1126', 'PICK-UP', 'Nissan', 2020, 'P1126XX', 80, 112000, 64.0, true, 1),
('1127', 'PICK-UP', 'Toyota', 2018, 'P1127XX', 80, 180000, 20.0, true, 1),
('1128', 'PICK-UP', 'Ford', 2021, 'P1128XX', 80, 68000, 76.0, true, 1),
('1129', 'PICK-UP', 'Toyota', 2019, 'P1129XX', 80, 150000, 38.0, true, 1),
('1130', 'PICK-UP', 'Nissan', 2020, 'P1130XX', 80, 118000, 66.0, true, 1),
('1131', 'PICK-UP', 'Chevrolet', 2018, 'P1131XX', 80, 185000, 15.0, true, 1),
('1132', 'PICK-UP', 'Toyota', 2021, 'P1132XX', 80, 60000, 80.0, true, 1),
('1133', 'PICK-UP', 'Ford', 2019, 'P1133XX', 80, 155000, 36.0, true, 1),
('1134', 'PICK-UP', 'Nissan', 2020, 'P1134XX', 80, 122000, 62.0, true, 1),
('1135', 'PICK-UP', 'Toyota', 2018, 'P1135XX', 80, 190000, 10.0, true, 1),
('1137', 'PICK-UP', 'Chevrolet', 2021, 'P1137XX', 80, 55000, 78.0, true, 1),
('1138', 'PICK-UP', 'Toyota', 2019, 'P1138XX', 80, 160000, 34.0, true, 1),
('1139', 'PICK-UP', 'Nissan', 2020, 'P1139XX', 80, 125000, 58.0, true, 1),
-- Camionetas 1170s
('1170', 'CAMIONETA', 'Toyota', 2020, 'P1170XX', 100, 95000, 70.0, true, 1),
('1171', 'CAMIONETA', 'Nissan', 2021, 'P1171XX', 100, 85000, 75.0, true, 1),
('1172', 'CAMIONETA', 'Ford', 2019, 'P1172XX', 100, 105000, 65.0, true, 1),
('1173', 'CAMIONETA', 'Toyota', 2020, 'P1173XX', 100, 90000, 72.0, true, 1),
('1174', 'CAMIONETA', 'Chevrolet', 2021, 'P1174XX', 100, 80000, 78.0, true, 1),
('1175', 'CAMIONETA', 'Nissan', 2019, 'P1175XX', 100, 110000, 60.0, true, 1),
('1176', 'CAMIONETA', 'Toyota', 2020, 'P1176XX', 100, 88000, 74.0, true, 1),
-- Unidades 00X
('002', 'PICK-UP', 'Toyota', 2020, 'P002XXX', 80, 100000, 60.0, true, 1),
('003', 'PICK-UP', 'Nissan', 2019, 'P003XXX', 80, 120000, 55.0, true, 1),
('004', 'PICK-UP', 'Ford', 2021, 'P004XXX', 80, 75000, 70.0, true, 1),
('005', 'PICK-UP', 'Toyota', 2018, 'P005XXX', 80, 150000, 45.0, true, 1),
('006', 'PICK-UP', 'Chevrolet', 2020, 'P006XXX', 80, 95000, 65.0, true, 1),
('007', 'PICK-UP', 'Nissan', 2019, 'P007XXX', 80, 115000, 58.0, true, 1),
('008', 'PICK-UP', 'Toyota', 2021, 'P008XXX', 80, 70000, 75.0, true, 1),
('009', 'PICK-UP', 'Ford', 2018, 'P009XXX', 80, 160000, 40.0, true, 1),
('010', 'PICK-UP', 'Chevrolet', 2020, 'P010XXX', 80, 98000, 62.0, true, 1),
('011', 'PICK-UP', 'Nissan', 2019, 'P011XXX', 80, 118000, 56.0, true, 1),
('012', 'PICK-UP', 'Toyota', 2021, 'P012XXX', 80, 68000, 78.0, true, 1),
('013', 'PICK-UP', 'Ford', 2018, 'P013XXX', 80, 165000, 38.0, true, 1),
('014', 'PICK-UP', 'Chevrolet', 2020, 'P014XXX', 80, 92000, 68.0, true, 1),
('015', 'PICK-UP', 'Nissan', 2019, 'P015XXX', 80, 122000, 54.0, true, 1),
('016', 'PICK-UP', 'Toyota', 2021, 'P016XXX', 80, 65000, 80.0, true, 1),
('017', 'PICK-UP', 'Ford', 2018, 'P017XXX', 80, 170000, 35.0, true, 1),
('018', 'PICK-UP', 'Chevrolet', 2020, 'P018XXX', 80, 88000, 72.0, true, 1),
('019', 'PICK-UP', 'Nissan', 2019, 'P019XXX', 80, 125000, 52.0, true, 1),
('020', 'PICK-UP', 'Toyota', 2021, 'P020XXX', 80, 62000, 78.0, true, 1),
('021', 'PICK-UP', 'Ford', 2018, 'P021XXX', 80, 175000, 32.0, true, 1),
('022', 'PICK-UP', 'Chevrolet', 2020, 'P022XXX', 80, 85000, 75.0, true, 1),
('023', 'PICK-UP', 'Nissan', 2019, 'P023XXX', 80, 128000, 50.0, true, 1),
('024', 'PICK-UP', 'Toyota', 2021, 'P024XXX', 80, 58000, 80.0, true, 1),
('025', 'PICK-UP', 'Ford', 2018, 'P025XXX', 80, 180000, 28.0, true, 1),
('026', 'PICK-UP', 'Chevrolet', 2020, 'P026XXX', 80, 82000, 76.0, true, 1),
('027', 'PICK-UP', 'Nissan', 2019, 'P027XXX', 80, 132000, 48.0, true, 1),
('028', 'PICK-UP', 'Toyota', 2021, 'P028XXX', 80, 55000, 78.0, true, 1),
('029', 'PICK-UP', 'Ford', 2018, 'P029XXX', 80, 185000, 25.0, true, 1),
('030', 'PICK-UP', 'Chevrolet', 2020, 'P030XXX', 80, 78000, 80.0, true, 1),
-- Peatonal
('Peatonal', 'PEATONAL', NULL, NULL, NULL, 0, 0, 0.0, true, 1);

-- RESUMEN
SELECT 'Sedes: ' || COUNT(*) FROM sede;
SELECT 'Tipos: ' || COUNT(*) FROM tipo_vehiculo;
SELECT 'Rutas: ' || COUNT(*) FROM ruta;
SELECT 'Unidades: ' || COUNT(*) FROM unidad;
