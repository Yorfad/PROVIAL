-- Migración 016: Departamentos y Municipios de Guatemala

-- ========================================
-- TABLA: DEPARTAMENTO
-- ========================================

CREATE TABLE departamento (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(2) UNIQUE NOT NULL,  -- Código oficial (01-22)
    nombre VARCHAR(100) NOT NULL,
    nombre_completo VARCHAR(150),
    region VARCHAR(50),  -- 'METROPOLITANA', 'NORTE', 'NORORIENTE', 'SURORIENTE', 'CENTRAL', 'SUROCCIDENTE', 'NOROCCIDENTE', 'PETEN'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE departamento IS 'Departamentos de Guatemala (22 total)';
COMMENT ON COLUMN departamento.codigo IS 'Código oficial del departamento (01-22)';
COMMENT ON COLUMN departamento.region IS 'Región geográfica a la que pertenece';

CREATE INDEX idx_departamento_codigo ON departamento(codigo);
CREATE INDEX idx_departamento_region ON departamento(region);

-- ========================================
-- TABLA: MUNICIPIO
-- ========================================

CREATE TABLE municipio (
    id SERIAL PRIMARY KEY,
    departamento_id INT NOT NULL REFERENCES departamento(id) ON DELETE RESTRICT,
    codigo VARCHAR(4) UNIQUE NOT NULL,  -- Código oficial (DDMM: DD=depto, MM=municipio)
    nombre VARCHAR(100) NOT NULL,
    nombre_completo VARCHAR(150),
    cabecera_municipal VARCHAR(100),
    poblacion INT,  -- Población estimada
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE municipio IS 'Municipios de Guatemala (340 total)';
COMMENT ON COLUMN municipio.codigo IS 'Código oficial del municipio (formato DDMM)';
COMMENT ON COLUMN municipio.cabecera_municipal IS 'Nombre de la cabecera municipal';

CREATE INDEX idx_municipio_departamento ON municipio(departamento_id);
CREATE INDEX idx_municipio_codigo ON municipio(codigo);
CREATE INDEX idx_municipio_nombre ON municipio(nombre);

-- ========================================
-- DATOS: DEPARTAMENTOS
-- ========================================

INSERT INTO departamento (codigo, nombre, nombre_completo, region) VALUES
('01', 'Guatemala', 'Departamento de Guatemala', 'METROPOLITANA'),
('02', 'El Progreso', 'Departamento de El Progreso', 'NORORIENTE'),
('03', 'Sacatepéquez', 'Departamento de Sacatepéquez', 'CENTRAL'),
('04', 'Chimaltenango', 'Departamento de Chimaltenango', 'CENTRAL'),
('05', 'Escuintla', 'Departamento de Escuintla', 'CENTRAL'),
('06', 'Santa Rosa', 'Departamento de Santa Rosa', 'SURORIENTE'),
('07', 'Sololá', 'Departamento de Sololá', 'SUROCCIDENTE'),
('08', 'Totonicapán', 'Departamento de Totonicapán', 'SUROCCIDENTE'),
('09', 'Quetzaltenango', 'Departamento de Quetzaltenango', 'SUROCCIDENTE'),
('10', 'Suchitepéquez', 'Departamento de Suchitepéquez', 'SUROCCIDENTE'),
('11', 'Retalhuleu', 'Departamento de Retalhuleu', 'SUROCCIDENTE'),
('12', 'San Marcos', 'Departamento de San Marcos', 'SUROCCIDENTE'),
('13', 'Huehuetenango', 'Departamento de Huehuetenango', 'NOROCCIDENTE'),
('14', 'Quiché', 'Departamento de Quiché', 'NOROCCIDENTE'),
('15', 'Baja Verapaz', 'Departamento de Baja Verapaz', 'NORTE'),
('16', 'Alta Verapaz', 'Departamento de Alta Verapaz', 'NORTE'),
('17', 'Petén', 'Departamento de Petén', 'PETEN'),
('18', 'Izabal', 'Departamento de Izabal', 'NORORIENTE'),
('19', 'Zacapa', 'Departamento de Zacapa', 'NORORIENTE'),
('20', 'Chiquimula', 'Departamento de Chiquimula', 'NORORIENTE'),
('21', 'Jalapa', 'Departamento de Jalapa', 'SURORIENTE'),
('22', 'Jutiapa', 'Departamento de Jutiapa', 'SURORIENTE');

-- ========================================
-- DATOS: MUNICIPIOS (Principales)
-- ========================================

-- GUATEMALA (01)
INSERT INTO municipio (departamento_id, codigo, nombre, cabecera_municipal) VALUES
((SELECT id FROM departamento WHERE codigo = '01'), '0101', 'Guatemala', 'Ciudad de Guatemala'),
((SELECT id FROM departamento WHERE codigo = '01'), '0102', 'Santa Catarina Pinula', 'Santa Catarina Pinula'),
((SELECT id FROM departamento WHERE codigo = '01'), '0103', 'San José Pinula', 'San José Pinula'),
((SELECT id FROM departamento WHERE codigo = '01'), '0104', 'San José del Golfo', 'San José del Golfo'),
((SELECT id FROM departamento WHERE codigo = '01'), '0105', 'Palencia', 'Palencia'),
((SELECT id FROM departamento WHERE codigo = '01'), '0106', 'Chinautla', 'Chinautla'),
((SELECT id FROM departamento WHERE codigo = '01'), '0107', 'San Pedro Ayampuc', 'San Pedro Ayampuc'),
((SELECT id FROM departamento WHERE codigo = '01'), '0108', 'Mixco', 'Mixco'),
((SELECT id FROM departamento WHERE codigo = '01'), '0109', 'San Pedro Sacatepéquez', 'San Pedro Sacatepéquez'),
((SELECT id FROM departamento WHERE codigo = '01'), '0110', 'San Juan Sacatepéquez', 'San Juan Sacatepéquez'),
((SELECT id FROM departamento WHERE codigo = '01'), '0111', 'San Raymundo', 'San Raymundo'),
((SELECT id FROM departamento WHERE codigo = '01'), '0112', 'Chuarrancho', 'Chuarrancho'),
((SELECT id FROM departamento WHERE codigo = '01'), '0113', 'Fraijanes', 'Fraijanes'),
((SELECT id FROM departamento WHERE codigo = '01'), '0114', 'Amatitlán', 'Amatitlán'),
((SELECT id FROM departamento WHERE codigo = '01'), '0115', 'Villa Nueva', 'Villa Nueva'),
((SELECT id FROM departamento WHERE codigo = '01'), '0116', 'Villa Canales', 'Villa Canales'),
((SELECT id FROM departamento WHERE codigo = '01'), '0117', 'San Miguel Petapa', 'San Miguel Petapa');

-- EL PROGRESO (02)
INSERT INTO municipio (departamento_id, codigo, nombre, cabecera_municipal) VALUES
((SELECT id FROM departamento WHERE codigo = '02'), '0201', 'Guastatoya', 'Guastatoya'),
((SELECT id FROM departamento WHERE codigo = '02'), '0202', 'Morazán', 'Morazán'),
((SELECT id FROM departamento WHERE codigo = '02'), '0203', 'San Agustín Acasaguastlán', 'San Agustín Acasaguastlán'),
((SELECT id FROM departamento WHERE codigo = '02'), '0204', 'San Cristóbal Acasaguastlán', 'San Cristóbal Acasaguastlán'),
((SELECT id FROM departamento WHERE codigo = '02'), '0205', 'El Jícaro', 'El Jícaro'),
((SELECT id FROM departamento WHERE codigo = '02'), '0206', 'Sansare', 'Sansare'),
((SELECT id FROM departamento WHERE codigo = '02'), '0207', 'Sanarate', 'Sanarate'),
((SELECT id FROM departamento WHERE codigo = '02'), '0208', 'San Antonio La Paz', 'San Antonio La Paz');

-- SACATEPEQUEZ (03)
INSERT INTO municipio (departamento_id, codigo, nombre, cabecera_municipal) VALUES
((SELECT id FROM departamento WHERE codigo = '03'), '0301', 'Antigua Guatemala', 'Antigua Guatemala'),
((SELECT id FROM departamento WHERE codigo = '03'), '0302', 'Jocotenango', 'Jocotenango'),
((SELECT id FROM departamento WHERE codigo = '03'), '0303', 'Pastores', 'Pastores'),
((SELECT id FROM departamento WHERE codigo = '03'), '0304', 'Sumpango', 'Sumpango'),
((SELECT id FROM departamento WHERE codigo = '03'), '0305', 'Santo Domingo Xenacoj', 'Santo Domingo Xenacoj'),
((SELECT id FROM departamento WHERE codigo = '03'), '0306', 'Santiago Sacatepéquez', 'Santiago Sacatepéquez'),
((SELECT id FROM departamento WHERE codigo = '03'), '0307', 'San Bartolomé Milpas Altas', 'San Bartolomé Milpas Altas'),
((SELECT id FROM departamento WHERE codigo = '03'), '0308', 'San Lucas Sacatepéquez', 'San Lucas Sacatepéquez'),
((SELECT id FROM departamento WHERE codigo = '03'), '0309', 'Santa Lucía Milpas Altas', 'Santa Lucía Milpas Altas'),
((SELECT id FROM departamento WHERE codigo = '03'), '0310', 'Magdalena Milpas Altas', 'Magdalena Milpas Altas'),
((SELECT id FROM departamento WHERE codigo = '03'), '0311', 'Santa María de Jesús', 'Santa María de Jesús'),
((SELECT id FROM departamento WHERE codigo = '03'), '0312', 'Ciudad Vieja', 'Ciudad Vieja'),
((SELECT id FROM departamento WHERE codigo = '03'), '0313', 'San Miguel Dueñas', 'San Miguel Dueñas'),
((SELECT id FROM departamento WHERE codigo = '03'), '0314', 'Alotenango', 'Alotenango'),
((SELECT id FROM departamento WHERE codigo = '03'), '0315', 'San Antonio Aguas Calientes', 'San Antonio Aguas Calientes'),
((SELECT id FROM departamento WHERE codigo = '03'), '0316', 'Santa Catarina Barahona', 'Santa Catarina Barahona');

-- ESCUINTLA (05) - Municipios principales por relevancia para PROVIAL
INSERT INTO municipio (departamento_id, codigo, nombre, cabecera_municipal) VALUES
((SELECT id FROM departamento WHERE codigo = '05'), '0501', 'Escuintla', 'Escuintla'),
((SELECT id FROM departamento WHERE codigo = '05'), '0502', 'Santa Lucía Cotzumalguapa', 'Santa Lucía Cotzumalguapa'),
((SELECT id FROM departamento WHERE codigo = '05'), '0503', 'La Democracia', 'La Democracia'),
((SELECT id FROM departamento WHERE codigo = '05'), '0504', 'Siquinalá', 'Siquinalá'),
((SELECT id FROM departamento WHERE codigo = '05'), '0505', 'Masagua', 'Masagua'),
((SELECT id FROM departamento WHERE codigo = '05'), '0506', 'Tiquisate', 'Tiquisate'),
((SELECT id FROM departamento WHERE codigo = '05'), '0507', 'La Gomera', 'La Gomera'),
((SELECT id FROM departamento WHERE codigo = '05'), '0508', 'Guanagazapa', 'Guanagazapa'),
((SELECT id FROM departamento WHERE codigo = '05'), '0509', 'San José', 'San José'),
((SELECT id FROM departamento WHERE codigo = '05'), '0510', 'Iztapa', 'Iztapa'),
((SELECT id FROM departamento WHERE codigo = '05'), '0511', 'Palín', 'Palín'),
((SELECT id FROM departamento WHERE codigo = '05'), '0512', 'San Vicente Pacaya', 'San Vicente Pacaya'),
((SELECT id FROM departamento WHERE codigo = '05'), '0513', 'Nueva Concepción', 'Nueva Concepción');

-- QUETZALTENANGO (09) - Principales
INSERT INTO municipio (departamento_id, codigo, nombre, cabecera_municipal) VALUES
((SELECT id FROM departamento WHERE codigo = '09'), '0901', 'Quetzaltenango', 'Quetzaltenango'),
((SELECT id FROM departamento WHERE codigo = '09'), '0902', 'Salcajá', 'Salcajá'),
((SELECT id FROM departamento WHERE codigo = '09'), '0903', 'Olintepeque', 'Olintepeque'),
((SELECT id FROM departamento WHERE codigo = '09'), '0904', 'San Carlos Sija', 'San Carlos Sija'),
((SELECT id FROM departamento WHERE codigo = '09'), '0905', 'Sibilia', 'Sibilia'),
((SELECT id FROM departamento WHERE codigo = '09'), '0906', 'Cabricán', 'Cabricán'),
((SELECT id FROM departamento WHERE codigo = '09'), '0907', 'Cajolá', 'Cajolá'),
((SELECT id FROM departamento WHERE codigo = '09'), '0908', 'San Miguel Sigüilá', 'San Miguel Sigüilá'),
((SELECT id FROM departamento WHERE codigo = '09'), '0909', 'San Juan Ostuncalco', 'San Juan Ostuncalco'),
((SELECT id FROM departamento WHERE codigo = '09'), '0910', 'San Mateo', 'San Mateo'),
((SELECT id FROM departamento WHERE codigo = '09'), '0911', 'Concepción Chiquirichapa', 'Concepción Chiquirichapa'),
((SELECT id FROM departamento WHERE codigo = '09'), '0912', 'San Martín Sacatepéquez', 'San Martín Sacatepéquez'),
((SELECT id FROM departamento WHERE codigo = '09'), '0913', 'Almolonga', 'Almolonga'),
((SELECT id FROM departamento WHERE codigo = '09'), '0914', 'Cantel', 'Cantel'),
((SELECT id FROM departamento WHERE codigo = '09'), '0915', 'Huitán', 'Huitán'),
((SELECT id FROM departamento WHERE codigo = '09'), '0916', 'Zunil', 'Zunil'),
((SELECT id FROM departamento WHERE codigo = '09'), '0917', 'Colomba Costa Cuca', 'Colomba Costa Cuca'),
((SELECT id FROM departamento WHERE codigo = '09'), '0918', 'San Francisco La Unión', 'San Francisco La Unión'),
((SELECT id FROM departamento WHERE codigo = '09'), '0919', 'El Palmar', 'El Palmar'),
((SELECT id FROM departamento WHERE codigo = '09'), '0920', 'Coatepeque', 'Coatepeque'),
((SELECT id FROM departamento WHERE codigo = '09'), '0921', 'Génova', 'Génova'),
((SELECT id FROM departamento WHERE codigo = '09'), '0922', 'Flores Costa Cuca', 'Flores Costa Cuca'),
((SELECT id FROM departamento WHERE codigo = '09'), '0923', 'La Esperanza', 'La Esperanza'),
((SELECT id FROM departamento WHERE codigo = '09'), '0924', 'Palestina de Los Altos', 'Palestina de Los Altos');

-- PETEN (17) - Principales
INSERT INTO municipio (departamento_id, codigo, nombre, cabecera_municipal) VALUES
((SELECT id FROM departamento WHERE codigo = '17'), '1701', 'Flores', 'Flores'),
((SELECT id FROM departamento WHERE codigo = '17'), '1702', 'San José', 'San José'),
((SELECT id FROM departamento WHERE codigo = '17'), '1703', 'San Benito', 'San Benito'),
((SELECT id FROM departamento WHERE codigo = '17'), '1704', 'San Andrés', 'San Andrés'),
((SELECT id FROM departamento WHERE codigo = '17'), '1705', 'La Libertad', 'La Libertad'),
((SELECT id FROM departamento WHERE codigo = '17'), '1706', 'San Francisco', 'San Francisco'),
((SELECT id FROM departamento WHERE codigo = '17'), '1707', 'Santa Ana', 'Santa Ana'),
((SELECT id FROM departamento WHERE codigo = '17'), '1708', 'Dolores', 'Dolores'),
((SELECT id FROM departamento WHERE codigo = '17'), '1709', 'San Luis', 'San Luis'),
((SELECT id FROM departamento WHERE codigo = '17'), '1710', 'Sayaxché', 'Sayaxché'),
((SELECT id FROM departamento WHERE codigo = '17'), '1711', 'Melchor de Mencos', 'Melchor de Mencos'),
((SELECT id FROM departamento WHERE codigo = '17'), '1712', 'Poptún', 'Poptún'),
((SELECT id FROM departamento WHERE codigo = '17'), '1713', 'Las Cruces', 'Las Cruces'),
((SELECT id FROM departamento WHERE codigo = '17'), '1714', 'El Chal', 'El Chal');

-- IZABAL (18) - Todos (relevantes para PROVIAL)
INSERT INTO municipio (departamento_id, codigo, nombre, cabecera_municipal) VALUES
((SELECT id FROM departamento WHERE codigo = '18'), '1801', 'Puerto Barrios', 'Puerto Barrios'),
((SELECT id FROM departamento WHERE codigo = '18'), '1802', 'Livingston', 'Livingston'),
((SELECT id FROM departamento WHERE codigo = '18'), '1803', 'El Estor', 'El Estor'),
((SELECT id FROM departamento WHERE codigo = '18'), '1804', 'Morales', 'Morales'),
((SELECT id FROM departamento WHERE codigo = '18'), '1805', 'Los Amates', 'Los Amates');

-- ========================================
-- MODIFICAR TABLAS EXISTENTES
-- ========================================

-- Agregar relaciones de departamento/municipio a tablas existentes
ALTER TABLE sede
ADD COLUMN departamento_id INT REFERENCES departamento(id) ON DELETE SET NULL,
ADD COLUMN municipio_id INT REFERENCES municipio(id) ON DELETE SET NULL;

ALTER TABLE incidente
ADD COLUMN departamento_id INT REFERENCES departamento(id) ON DELETE SET NULL,
ADD COLUMN municipio_id INT REFERENCES municipio(id) ON DELETE SET NULL;

ALTER TABLE situacion
ADD COLUMN departamento_id INT REFERENCES departamento(id) ON DELETE SET NULL,
ADD COLUMN municipio_id INT REFERENCES municipio(id) ON DELETE SET NULL;

CREATE INDEX idx_incidente_departamento ON incidente(departamento_id);
CREATE INDEX idx_incidente_municipio ON incidente(municipio_id);
CREATE INDEX idx_situacion_departamento ON situacion(departamento_id);
CREATE INDEX idx_situacion_municipio ON situacion(municipio_id);

COMMENT ON COLUMN sede.departamento_id IS 'Departamento donde se ubica la sede';
COMMENT ON COLUMN sede.municipio_id IS 'Municipio donde se ubica la sede';
COMMENT ON COLUMN incidente.departamento_id IS 'Departamento donde ocurrió el incidente';
COMMENT ON COLUMN incidente.municipio_id IS 'Municipio donde ocurrió el incidente';
COMMENT ON COLUMN situacion.departamento_id IS 'Departamento de la situación';
COMMENT ON COLUMN situacion.municipio_id IS 'Municipio de la situación';
