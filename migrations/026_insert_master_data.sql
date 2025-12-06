-- ========================================
-- SCRIPT DE DATOS MAESTROS
-- Marcas, Tipos de Vehículos, Unidades, Rutas, Sedes
-- ========================================

-- ========================================
-- 1. MARCAS DE VEHÍCULOS
-- ========================================
INSERT INTO marca (nombre, activa) VALUES
('Toyota', true),
('Honda', true),
('Nissan', true),
('Jeep', true),
('BMW', true),
('Mitsubishi', true),
('Suzuki', true),
('Hyundai', true),
('Mazda', true),
('Chevrolet', true),
('Freightliner', true),
('International', true),
('Volvo', true),
('Italika', true),
('Kia', true),
('Volkswagen', true),
('Ford', true),
('Audi', true),
('JAC', true),
('Hino', true),
('Otro', true)
ON CONFLICT (nombre) DO NOTHING;

-- ========================================
-- 2. TIPOS DE VEHÍCULOS
-- ========================================
INSERT INTO tipo_vehiculo (nombre, activo) VALUES
('Motocicleta', true),
('Jaula Cañera', true),
('Rastra', true),
('Bicicleta', true),
('Jeep', true),
('Bus escolar', true),
('Maquinaria', true),
('Bus turismo', true),
('Tractor', true),
('Ambulancia', true),
('Camionetilla', true),
('Pulman', true),
('Autopatrulla PNC', true),
('Bus extraurbano', true),
('Bus urbano', true),
('Camioneta agricola', true),
('Cisterna', true),
('Furgon', true),
('Mototaxi', true),
('Microbus', true),
('Motobicicleta', true),
('Plataforma', true),
('Panel', true),
('Unidad de PROVIAL', true),
('Grúa', true),
('Bus institucional', true),
('Cuatrimoto', true),
('Doble remolque', true),
('Tesla', true),
('Peaton', true),
('Fugado', true),
('Sedan', true),
('Pick-up', true),
('Camión', true),
('Bus', true),
('Cabezal', true),
('Otro', true)
ON CONFLICT (nombre) DO NOTHING;

-- ========================================
-- 3. SEDES
-- ========================================
INSERT INTO sede (nombre, direccion, activa) VALUES
('Central', 'Ciudad de Guatemala', true),
('Mazatenango', 'Mazatenango, Suchitepéquez', true),
('Poptún', 'Poptún, Petén', true),
('San Cristóbal', 'San Cristóbal Verapaz, Alta Verapaz', true),
('Quetzaltenango', 'Quetzaltenango', true),
('Coatepeque', 'Coatepeque, Quetzaltenango', true),
('Palin Escuintla', 'Palín, Escuintla', true),
('Morales', 'Morales, Izabal', true),
('Rio Dulce', 'Río Dulce, Izabal', true)
ON CONFLICT (nombre) DO NOTHING;

-- ========================================
-- 4. RUTAS
-- ========================================
INSERT INTO ruta (codigo, nombre, descripcion, activa) VALUES
('CA-1 Occidente', 'CA-1 Occidente', 'Carretera Centroamericana 1 - Tramo Occidente', true),
('CA-1 Oriente', 'CA-1 Oriente', 'Carretera Centroamericana 1 - Tramo Oriente', true),
('CA-10', 'CA-10', 'Carretera Centroamericana 10', true),
('CA-11', 'CA-11', 'Carretera Centroamericana 11', true),
('CA-13', 'CA-13', 'Carretera Centroamericana 13', true),
('CA-14', 'CA-14', 'Carretera Centroamericana 14', true),
('CA-2 Occidente', 'CA-2 Occidente', 'Carretera Centroamericana 2 - Tramo Occidente', true),
('CA-2 Oriente', 'CA-2 Oriente', 'Carretera Centroamericana 2 - Tramo Oriente', true),
('CA-8 Oriente', 'CA-8 Oriente', 'Carretera Centroamericana 8 - Tramo Oriente', true),
('CA-9 Norte', 'CA-9 Norte', 'Carretera Centroamericana 9 - Tramo Norte', true),
('CA-9 Sur', 'CA-9 Sur', 'Carretera Centroamericana 9 - Tramo Sur', true),
('CA-9 Sur A', 'CA-9 Sur A', 'Carretera Centroamericana 9 Sur A', true),
('CHM-11', 'CHM-11', 'Ruta Departamental Chimaltenango 11', true),
('CITO-180', 'CITO-180', 'Ruta CITO 180', true),
('CIUDAD', 'CIUDAD', 'Rutas dentro de Ciudad de Guatemala', true),
('FTN', 'FTN', 'Franja Transversal del Norte', true),
('PRO-1', 'PRO-1', 'Ruta PRO-1', true),
('QUE-03', 'QUE-03', 'Ruta Departamental Quetzaltenango 03', true),
('RD-1', 'RD-1', 'Ruta Departamental 1', true),
('RD-3', 'RD-3', 'Ruta Departamental 3', true),
('RD-9 Norte', 'RD-9 Norte', 'Ruta Departamental 9 Norte', true),
('RD-10', 'RD-10', 'Ruta Departamental 10', true),
('RD-16', 'RD-16', 'Ruta Departamental 16', true),
('RD-AV-09', 'RD-AV-09', 'Ruta Departamental Alta Verapaz 09', true),
('RD-CHI-01', 'RD-CHI-01', 'Ruta Departamental Chimaltenango 01', true),
('RD-ESC-01', 'RD-ESC-01', 'Ruta Departamental Escuintla 01', true),
('RD-GUA-01', 'RD-GUA-01', 'Ruta Departamental Guatemala 01', true),
('RD-GUA-04-06', 'RD-GUA-04-06', 'Ruta Departamental Guatemala 04-06', true),
('RD-GUA-10', 'RD-GUA-10', 'Ruta Departamental Guatemala 10', true),
('RD-GUA-16', 'RD-GUA-16', 'Ruta Departamental Guatemala 16', true),
('RD-JUT-03', 'RD-JUT-03', 'Ruta Departamental Jutiapa 03', true),
('RD-PET-01', 'RD-PET-01', 'Ruta Departamental Petén 01', true),
('RD-PET-03', 'RD-PET-03', 'Ruta Departamental Petén 03', true),
('RD-PET-11', 'RD-PET-11', 'Ruta Departamental Petén 11', true),
('RD-PET-13', 'RD-PET-13', 'Ruta Departamental Petén 13', true),
('RD-SAC-08', 'RD-SAC-08', 'Ruta Departamental Sacatepéquez 08', true),
('RD-SAC-11', 'RD-SAC-11', 'Ruta Departamental Sacatepéquez 11', true),
('RD-SCH-14', 'RD-SCH-14', 'Ruta Departamental Suchitepéquez 14', true),
('RD-SM-01', 'RD-SM-01', 'Ruta Departamental San Marcos 01', true),
('RD-SOL03', 'RD-SOL03', 'Ruta Departamental Sololá 03', true),
('RD-SRO-03', 'RD-SRO-03', 'Ruta Departamental Santa Rosa 03', true),
('RD-STR-003', 'RD-STR-003', 'Ruta Departamental Santa Rosa 003', true),
('RD-ZA-05', 'RD-ZA-05', 'Ruta Departamental Zacapa 05', true),
('RN-01', 'RN-01', 'Ruta Nacional 01', true),
('RN-02', 'RN-02', 'Ruta Nacional 02', true),
('RN-05', 'RN-05', 'Ruta Nacional 05', true),
('RN-07 E', 'RN-07 E', 'Ruta Nacional 07 Este', true),
('RN-9S', 'RN-9S', 'Ruta Nacional 9 Sur', true),
('RN-10', 'RN-10', 'Ruta Nacional 10', true),
('RN-11', 'RN-11', 'Ruta Nacional 11', true),
('RN-14', 'RN-14', 'Ruta Nacional 14', true),
('RN-15', 'RN-15', 'Ruta Nacional 15', true),
('RN-15-03', 'RN-15-03', 'Ruta Nacional 15-03', true),
('RN-16', 'RN-16', 'Ruta Nacional 16', true),
('RN-17', 'RN-17', 'Ruta Nacional 17', true),
('RN-18', 'RN-18', 'Ruta Nacional 18', true),
('RN-19', 'RN-19', 'Ruta Nacional 19', true),
('RUTA VAS SUR', 'RUTA VAS SUR', 'Ruta VAS Sur', true),
('RUTA VAS OCC', 'RUTA VAS OCC', 'Ruta VAS Occidente', true),
('RUTA VAS OR', 'RUTA VAS OR', 'Ruta VAS Oriente', true)
ON CONFLICT (codigo) DO NOTHING;

-- ========================================
-- 5. UNIDADES (asignar a sede Central por defecto)
-- ========================================
DO $$
DECLARE
    sede_central_id INTEGER;
BEGIN
    -- Obtener ID de sede Central
    SELECT id INTO sede_central_id FROM sede WHERE nombre = 'Central' LIMIT 1;
    
    IF sede_central_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró la sede Central';
    END IF;

    -- Insertar unidades
    INSERT INTO unidad (codigo, tipo_unidad, marca, modelo, placa, capacidad_combustible, odometro_actual, combustible_actual, activa, sede_id) VALUES
    -- Motos
    ('M001', 'MOTOCICLETA', 'Honda', 2020, 'M001XXX', 15, 10000, 10, true, sede_central_id),
    ('M002', 'MOTOCICLETA', 'Suzuki', 2021, 'M002XXX', 15, 8000, 12, true, sede_central_id),
    ('M003', 'MOTOCICLETA', 'Honda', 2019, 'M003XXX', 15, 15000, 8, true, sede_central_id),
    ('M004', 'MOTOCICLETA', 'Italika', 2022, 'M004XXX', 15, 5000, 14, true, sede_central_id),
    ('M005', 'MOTOCICLETA', 'Suzuki', 2020, 'M005XXX', 15, 12000, 11, true, sede_central_id),
    ('M006', 'MOTOCICLETA', 'Honda', 2021, 'M006XXX', 15, 9000, 13, true, sede_central_id),
    ('M007', 'MOTOCICLETA', 'Suzuki', 2022, 'M007XXX', 15, 3000, 15, true, sede_central_id),
    
    -- Pickups 1100s
    ('1104', 'PICK-UP', 'Toyota', 2018, 'P1104XX', 80, 150000, 60, true, sede_central_id),
    ('1105', 'PICK-UP', 'Toyota', 2019, 'P1105XX', 80, 120000, 55, true, sede_central_id),
    ('1106', 'PICK-UP', 'Nissan', 2020, 'P1106XX', 80, 100000, 70, true, sede_central_id),
    ('1107', 'PICK-UP', 'Ford', 2018, 'P1107XX', 80, 160000, 45, true, sede_central_id),
    ('1108', 'PICK-UP', 'Toyota', 2021, 'P1108XX', 80, 80000, 75, true, sede_central_id),
    ('1109', 'PICK-UP', 'Chevrolet', 2019, 'P1109XX', 80, 130000, 50, true, sede_central_id),
    ('1110', 'PICK-UP', 'Nissan', 2020, 'P1110XX', 80, 110000, 65, true, sede_central_id),
    ('1111', 'PICK-UP', 'Toyota', 2018, 'P1111XX', 80, 155000, 40, true, sede_central_id),
    ('1112', 'PICK-UP', 'Ford', 2021, 'P1112XX', 80, 75000, 70, true, sede_central_id),
    ('1113', 'PICK-UP', 'Toyota', 2019, 'P1113XX', 80, 125000, 58, true, sede_central_id),
    ('1114', 'PICK-UP', 'Nissan', 2020, 'P1114XX', 80, 105000, 62, true, sede_central_id),
    ('1115', 'PICK-UP', 'Chevrolet', 2018, 'P1115XX', 80, 165000, 35, true, sede_central_id),
    ('1116', 'PICK-UP', 'Toyota', 2021, 'P1116XX', 80, 70000, 72, true, sede_central_id),
    ('1117', 'PICK-UP', 'Ford', 2019, 'P1117XX', 80, 135000, 48, true, sede_central_id),
    ('1118', 'PICK-UP', 'Nissan', 2020, 'P1118XX', 80, 115000, 60, true, sede_central_id),
    ('1119', 'PICK-UP', 'Toyota', 2018, 'P1119XX', 80, 170000, 30, true, sede_central_id),
    ('1120', 'PICK-UP', 'Chevrolet', 2021, 'P1120XX', 80, 65000, 75, true, sede_central_id),
    ('1121', 'PICK-UP', 'Toyota', 2019, 'P1121XX', 80, 140000, 52, true, sede_central_id),
    ('1122', 'PICK-UP', 'Nissan', 2020, 'P1122XX', 80, 108000, 68, true, sede_central_id),
    ('1123', 'PICK-UP', 'Ford', 2018, 'P1123XX', 80, 175000, 25, true, sede_central_id),
    ('1124', 'PICK-UP', 'Toyota', 2021, 'P1124XX', 80, 72000, 78, true, sede_central_id),
    ('1125', 'PICK-UP', 'Chevrolet', 2019, 'P1125XX', 80, 145000, 42, true, sede_central_id),
    ('1126', 'PICK-UP', 'Nissan', 2020, 'P1126XX', 80, 112000, 64, true, sede_central_id),
    ('1127', 'PICK-UP', 'Toyota', 2018, 'P1127XX', 80, 180000, 20, true, sede_central_id),
    ('1128', 'PICK-UP', 'Ford', 2021, 'P1128XX', 80, 68000, 76, true, sede_central_id),
    ('1129', 'PICK-UP', 'Toyota', 2019, 'P1129XX', 80, 150000, 38, true, sede_central_id),
    ('1130', 'PICK-UP', 'Nissan', 2020, 'P1130XX', 80, 118000, 66, true, sede_central_id),
    ('1131', 'PICK-UP', 'Chevrolet', 2018, 'P1131XX', 80, 185000, 15, true, sede_central_id),
    ('1132', 'PICK-UP', 'Toyota', 2021, 'P1132XX', 80, 60000, 80, true, sede_central_id),
    ('1133', 'PICK-UP', 'Ford', 2019, 'P1133XX', 80, 155000, 36, true, sede_central_id),
    ('1134', 'PICK-UP', 'Nissan', 2020, 'P1134XX', 80, 122000, 62, true, sede_central_id),
    ('1135', 'PICK-UP', 'Toyota', 2018, 'P1135XX', 80, 190000, 10, true, sede_central_id),
    ('1137', 'PICK-UP', 'Chevrolet', 2021, 'P1137XX', 80, 55000, 78, true, sede_central_id),
    ('1138', 'PICK-UP', 'Toyota', 2019, 'P1138XX', 80, 160000, 34, true, sede_central_id),
    ('1139', 'PICK-UP', 'Nissan', 2020, 'P1139XX', 80, 125000, 58, true, sede_central_id),
    
    -- Unidades especiales
    ('1170', 'CAMIONETA', 'Toyota', 2020, 'P1170XX', 100, 95000, 70, true, sede_central_id),
    ('1171', 'CAMIONETA', 'Nissan', 2021, 'P1171XX', 100, 85000, 75, true, sede_central_id),
    ('1172', 'CAMIONETA', 'Ford', 2019, 'P1172XX', 100, 105000, 65, true, sede_central_id),
    ('1173', 'CAMIONETA', 'Toyota', 2020, 'P1173XX', 100, 90000, 72, true, sede_central_id),
    ('1174', 'CAMIONETA', 'Chevrolet', 2021, 'P1174XX', 100, 80000, 78, true, sede_central_id),
    ('1175', 'CAMIONETA', 'Nissan', 2019, 'P1175XX', 100, 110000, 60, true, sede_central_id),
    ('1176', 'CAMIONETA', 'Toyota', 2020, 'P1176XX', 100, 88000, 74, true, sede_central_id),
    
    -- Unidades peatonales y especiales
    ('Peatonal', 'PEATONAL', NULL, NULL, NULL, 0, 0, 0, true, sede_central_id),
    ('002', 'PICK-UP', 'Toyota', 2020, 'P002XXX', 80, 100000, 60, true, sede_central_id),
    ('003', 'PICK-UP', 'Nissan', 2019, 'P003XXX', 80, 120000, 55, true, sede_central_id),
    ('004', 'PICK-UP', 'Ford', 2021, 'P004XXX', 80, 75000, 70, true, sede_central_id),
    ('005', 'PICK-UP', 'Toyota', 2018, 'P005XXX', 80, 150000, 45, true, sede_central_id),
    ('006', 'PICK-UP', 'Chevrolet', 2020, 'P006XXX', 80, 95000, 65, true, sede_central_id),
    ('007', 'PICK-UP', 'Nissan', 2019, 'P007XXX', 80, 115000, 58, true, sede_central_id),
    ('008', 'PICK-UP', 'Toyota', 2021, 'P008XXX', 80, 70000, 75, true, sede_central_id),
    ('009', 'PICK-UP', 'Ford', 2018, 'P009XXX', 80, 160000, 40, true, sede_central_id),
    ('010', 'PICK-UP', 'Chevrolet', 2020, 'P010XXX', 80, 98000, 62, true, sede_central_id),
    ('011', 'PICK-UP', 'Nissan', 2019, 'P011XXX', 80, 118000, 56, true, sede_central_id),
    ('012', 'PICK-UP', 'Toyota', 2021, 'P012XXX', 80, 68000, 78, true, sede_central_id),
    ('013', 'PICK-UP', 'Ford', 2018, 'P013XXX', 80, 165000, 38, true, sede_central_id),
    ('014', 'PICK-UP', 'Chevrolet', 2020, 'P014XXX', 80, 92000, 68, true, sede_central_id),
    ('015', 'PICK-UP', 'Nissan', 2019, 'P015XXX', 80, 122000, 54, true, sede_central_id),
    ('016', 'PICK-UP', 'Toyota', 2021, 'P016XXX', 80, 65000, 80, true, sede_central_id),
    ('017', 'PICK-UP', 'Ford', 2018, 'P017XXX', 80, 170000, 35, true, sede_central_id),
    ('018', 'PICK-UP', 'Chevrolet', 2020, 'P018XXX', 80, 88000, 72, true, sede_central_id),
    ('019', 'PICK-UP', 'Nissan', 2019, 'P019XXX', 80, 125000, 52, true, sede_central_id),
    ('020', 'PICK-UP', 'Toyota', 2021, 'P020XXX', 80, 62000, 78, true, sede_central_id),
    ('021', 'PICK-UP', 'Ford', 2018, 'P021XXX', 80, 175000, 32, true, sede_central_id),
    ('022', 'PICK-UP', 'Chevrolet', 2020, 'P022XXX', 80, 85000, 75, true, sede_central_id),
    ('023', 'PICK-UP', 'Nissan', 2019, 'P023XXX', 80, 128000, 50, true, sede_central_id),
    ('024', 'PICK-UP', 'Toyota', 2021, 'P024XXX', 80, 58000, 80, true, sede_central_id),
    ('025', 'PICK-UP', 'Ford', 2018, 'P025XXX', 80, 180000, 28, true, sede_central_id),
    ('026', 'PICK-UP', 'Chevrolet', 2020, 'P026XXX', 80, 82000, 76, true, sede_central_id),
    ('027', 'PICK-UP', 'Nissan', 2019, 'P027XXX', 80, 132000, 48, true, sede_central_id),
    ('028', 'PICK-UP', 'Toyota', 2021, 'P028XXX', 80, 55000, 78, true, sede_central_id),
    ('029', 'PICK-UP', 'Ford', 2018, 'P029XXX', 80, 185000, 25, true, sede_central_id),
    ('030', 'PICK-UP', 'Chevrolet', 2020, 'P030XXX', 80, 78000, 80, true, sede_central_id)
    ON CONFLICT (codigo) DO NOTHING;
END $$;

-- ========================================
-- RESUMEN
-- ========================================
SELECT 'Marcas insertadas: ' || COUNT(*) FROM marca;
SELECT 'Tipos de vehículo insertados: ' || COUNT(*) FROM tipo_vehiculo;
SELECT 'Sedes insertadas: ' || COUNT(*) FROM sede;
SELECT 'Rutas insertadas: ' || COUNT(*) FROM ruta;
SELECT 'Unidades insertadas: ' || COUNT(*) FROM unidad;
