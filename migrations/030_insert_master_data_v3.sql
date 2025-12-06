-- ========================================
-- INSERCIÓN DE DATOS MAESTROS V3 (FINAL)
-- ========================================

-- 1. TIPOS DE VEHÍCULOS (Solo nombre)
INSERT INTO tipo_vehiculo (nombre) VALUES
('Motocicleta'), ('Jaula Cañera'), ('Rastra'), ('Bicicleta'),
('Jeep'), ('Bus escolar'), ('Maquinaria'), ('Bus turismo'),
('Tractor'), ('Ambulancia'), ('Camionetilla'), ('Pulman'),
('Autopatrulla PNC'), ('Bus extraurbano'), ('Bus urbano'),
('Camioneta agricola'), ('Cisterna'), ('Furgon'), ('Mototaxi'),
('Microbus'), ('Motobicicleta'), ('Plataforma'), ('Panel'),
('Unidad de PROVIAL'), ('Grúa'), ('Bus institucional'),
('Cuatrimoto'), ('Doble remolque'), ('Tesla'), ('Peaton'),
('Fugado'), ('Sedan'), ('Pick-up'), ('Camión'),
('Bus'), ('Cabezal'), ('Otro')
ON CONFLICT (nombre) DO NOTHING;

-- 2. RUTAS (Sin descripción)
INSERT INTO ruta (codigo, nombre, activa) VALUES
('CA-1 Occidente', 'CA-1 Occidente', true),
('CA-1 Oriente', 'CA-1 Oriente', true),
('CA-2 Occidente', 'CA-2 Occidente', true),
('CA-9 Norte', 'CA-9 Norte', true),
('CA-9 Sur', 'CA-9 Sur', true),
('CA-10', 'CA-10', true),
('CA-11', 'CA-11', true),
('CA-13', 'CA-13', true),
('CA-14', 'CA-14', true),
('CA-2 Oriente', 'CA-2 Oriente', true),
('CA-8 Oriente', 'CA-8 Oriente', true),
('CA-9 Sur A', 'CA-9 Sur A', true),
('CHM-11', 'CHM-11', true),
('CITO-180', 'CITO-180', true),
('CIUDAD', 'CIUDAD', true),
('FTN', 'FTN', true),
('PRO-1', 'PRO-1', true),
('QUE-03', 'QUE-03', true),
('RD-1', 'RD-1', true),
('RD-3', 'RD-3', true),
('RD-9 Norte', 'RD-9 Norte', true),
('RD-10', 'RD-10', true),
('RD-16', 'RD-16', true),
('RD-AV-09', 'RD-AV-09', true),
('RD-CHI-01', 'RD-CHI-01', true),
('RD-ESC-01', 'RD-ESC-01', true),
('RD-GUA-01', 'RD-GUA-01', true),
('RD-GUA-04-06', 'RD-GUA-04-06', true),
('RD-GUA-10', 'RD-GUA-10', true),
('RD-GUA-16', 'RD-GUA-16', true),
('RD-JUT-03', 'RD-JUT-03', true),
('RD-PET-01', 'RD-PET-01', true),
('RD-PET-03', 'RD-PET-03', true),
('RD-PET-11', 'RD-PET-11', true),
('RD-PET-13', 'RD-PET-13', true),
('RD-SAC-08', 'RD-SAC-08', true),
('RD-SAC-11', 'RD-SAC-11', true),
('RD-SCH-14', 'RD-SCH-14', true),
('RD-SM-01', 'RD-SM-01', true),
('RD-SOL03', 'RD-SOL03', true),
('RD-SRO-03', 'RD-SRO-03', true),
('RD-STR-003', 'RD-STR-003', true),
('RD-ZA-05', 'RD-ZA-05', true),
('RN-01', 'RN-01', true),
('RN-02', 'RN-02', true),
('RN-05', 'RN-05', true),
('RN-07 E', 'RN-07 E', true),
('RN-9S', 'RN-9S', true),
('RN-10', 'RN-10', true),
('RN-11', 'RN-11', true),
('RN-14', 'RN-14', true),
('RN-15', 'RN-15', true),
('RN-15-03', 'RN-15-03', true),
('RN-16', 'RN-16', true),
('RN-17', 'RN-17', true),
('RN-18', 'RN-18', true),
('RN-19', 'RN-19', true),
('RUTA VAS SUR', 'RUTA VAS SUR', true),
('RUTA VAS OCC', 'RUTA VAS OCC', true),
('RUTA VAS OR', 'RUTA VAS OR', true)
ON CONFLICT (codigo) DO NOTHING;

-- 3. UNIDADES (Ya insertadas en v2, pero por si acaso faltan)
-- No re-insertamos para evitar duplicados o errores si ya existen
-- El script v2 ya insertó 79 unidades correctamente.

-- ========================================
-- RESUMEN FINAL
-- ========================================
SELECT 'Sedes: ' || COUNT(*) FROM sede;
SELECT 'Tipos: ' || COUNT(*) FROM tipo_vehiculo;
SELECT 'Rutas: ' || COUNT(*) FROM ruta;
SELECT 'Unidades: ' || COUNT(*) FROM unidad;
