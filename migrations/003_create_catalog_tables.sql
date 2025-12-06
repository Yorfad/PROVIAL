-- Migración 003: Tablas de catálogos

-- ========================================
-- CATÁLOGO: RUTAS
-- ========================================

CREATE TABLE ruta (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    tipo_ruta VARCHAR(30),
    km_inicial DECIMAL(6,2),
    km_final DECIMAL(6,2),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE ruta IS 'Catálogo de rutas/carreteras';
COMMENT ON COLUMN ruta.tipo_ruta IS 'CARRETERA, AUTOPISTA, BOULEVARD';

CREATE INDEX idx_ruta_codigo ON ruta(codigo);
CREATE INDEX idx_ruta_activa ON ruta(activa);

-- Datos de ejemplo (principales carreteras de Guatemala)
INSERT INTO ruta (codigo, nombre, tipo_ruta, km_inicial, km_final) VALUES
('CA-1', 'Carretera Interamericana', 'CARRETERA', 0, 400),
('CA-2', 'Carretera del Pacífico', 'CARRETERA', 0, 350),
('CA-9', 'Carretera al Atlántico', 'CARRETERA', 0, 300),
('RN-14', 'Ruta Nacional 14', 'CARRETERA', 0, 150),
('RN-15', 'Ruta Nacional 15', 'CARRETERA', 0, 120);

-- ========================================
-- CATÁLOGO: TIPO DE HECHO
-- ========================================

CREATE TABLE tipo_hecho (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    icono VARCHAR(50),
    color VARCHAR(7),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE tipo_hecho IS 'Tipos principales de hechos/incidentes';
COMMENT ON COLUMN tipo_hecho.icono IS 'Nombre del icono para UI (ej: accident, warning, etc.)';
COMMENT ON COLUMN tipo_hecho.color IS 'Color hexadecimal para mapas';

CREATE INDEX idx_tipo_hecho_activo ON tipo_hecho(activo);

INSERT INTO tipo_hecho (nombre, icono, color) VALUES
('Accidente Vial', 'accident', '#FF0000'),
('Vehículo Varado', 'car-breakdown', '#FFA500'),
('Derrumbe', 'landslide', '#8B4513'),
('Árbol Caído', 'tree', '#228B22'),
('Trabajos en la Vía', 'construction', '#FFD700'),
('Manifestación', 'protest', '#FF69B4'),
('Regulación de Tránsito', 'traffic-control', '#1E90FF'),
('Otro', 'question', '#808080');

-- ========================================
-- CATÁLOGO: SUBTIPO DE HECHO
-- ========================================

CREATE TABLE subtipo_hecho (
    id SERIAL PRIMARY KEY,
    tipo_hecho_id INT NOT NULL REFERENCES tipo_hecho(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tipo_hecho_id, nombre)
);

COMMENT ON TABLE subtipo_hecho IS 'Subtipos específicos de cada tipo de hecho';

CREATE INDEX idx_subtipo_tipo ON subtipo_hecho(tipo_hecho_id);
CREATE INDEX idx_subtipo_activo ON subtipo_hecho(activo);

-- Subtipos para Accidente Vial
INSERT INTO subtipo_hecho (tipo_hecho_id, nombre) VALUES
((SELECT id FROM tipo_hecho WHERE nombre = 'Accidente Vial'), 'Colisión'),
((SELECT id FROM tipo_hecho WHERE nombre = 'Accidente Vial'), 'Volcamiento'),
((SELECT id FROM tipo_hecho WHERE nombre = 'Accidente Vial'), 'Atropello'),
((SELECT id FROM tipo_hecho WHERE nombre = 'Accidente Vial'), 'Salida de Vía'),
((SELECT id FROM tipo_hecho WHERE nombre = 'Accidente Vial'), 'Choque contra Objeto Fijo');

-- Subtipos para Vehículo Varado
INSERT INTO subtipo_hecho (tipo_hecho_id, nombre) VALUES
((SELECT id FROM tipo_hecho WHERE nombre = 'Vehículo Varado'), 'Falla Mecánica'),
((SELECT id FROM tipo_hecho WHERE nombre = 'Vehículo Varado'), 'Sin Combustible'),
((SELECT id FROM tipo_hecho WHERE nombre = 'Vehículo Varado'), 'Llanta Ponchada'),
((SELECT id FROM tipo_hecho WHERE nombre = 'Vehículo Varado'), 'Sobrecalentamiento');

-- ========================================
-- CATÁLOGO: TIPO DE VEHÍCULO
-- ========================================

CREATE TABLE tipo_vehiculo (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    categoria VARCHAR(30),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE tipo_vehiculo IS 'Tipos de vehículos';
COMMENT ON COLUMN tipo_vehiculo.categoria IS 'LIVIANO, PESADO, MOTO';

CREATE INDEX idx_tipo_vehiculo_categoria ON tipo_vehiculo(categoria);

INSERT INTO tipo_vehiculo (nombre, categoria) VALUES
('Automóvil', 'LIVIANO'),
('Pickup', 'LIVIANO'),
('Panel', 'LIVIANO'),
('Motocicleta', 'MOTO'),
('Bus', 'PESADO'),
('Microbús', 'PESADO'),
('Camión', 'PESADO'),
('Cabezal', 'PESADO'),
('Rastra', 'PESADO'),
('Maquinaria', 'PESADO'),
('Otro', NULL);

-- ========================================
-- CATÁLOGO: MARCA DE VEHÍCULO
-- ========================================

CREATE TABLE marca_vehiculo (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE marca_vehiculo IS 'Marcas de vehículos';

INSERT INTO marca_vehiculo (nombre) VALUES
('Toyota'), ('Nissan'), ('Honda'), ('Mazda'), ('Mitsubishi'),
('Ford'), ('Chevrolet'), ('Hyundai'), ('Kia'), ('Suzuki'),
('Volkswagen'), ('Mercedes-Benz'), ('Volvo'), ('Scania'),
('Freightliner'), ('International'), ('Isuzu'),
('Otra'), ('Desconocida');

-- ========================================
-- CATÁLOGO: TIPO DE ACTIVIDAD
-- ========================================

CREATE TABLE tipo_actividad (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    requiere_incidente BOOLEAN NOT NULL DEFAULT FALSE,
    color VARCHAR(7),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE tipo_actividad IS 'Tipos de actividades que realizan las unidades';
COMMENT ON COLUMN tipo_actividad.requiere_incidente IS 'Si la actividad debe estar asociada a un incidente';

INSERT INTO tipo_actividad (nombre, requiere_incidente, color) VALUES
('Patrullaje', FALSE, '#4CAF50'),
('Accidente Vial', TRUE, '#F44336'),
('Regulación de Tránsito', TRUE, '#2196F3'),
('Almuerzo', FALSE, '#FFC107'),
('Parada Estratégica', FALSE, '#9C27B0'),
('Carga de Combustible', FALSE, '#FF9800'),
('Fuera de Servicio', FALSE, '#9E9E9E'),
('Mantenimiento', FALSE, '#795548'),
('Vehículo Varado', TRUE, '#FF5722');

-- ========================================
-- CATÁLOGO: MOTIVO NO ATENDIDO
-- ========================================

CREATE TABLE motivo_no_atendido (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    requiere_observaciones BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE motivo_no_atendido IS 'Motivos por los que un incidente no fue atendido';

CREATE INDEX idx_motivo_no_atendido_activo ON motivo_no_atendido(activo);

INSERT INTO motivo_no_atendido (nombre, descripcion, requiere_observaciones) VALUES
('Sin Combustible', 'Unidad no tenía combustible suficiente', FALSE),
('Fuera de Jurisdicción', 'Incidente fuera del área de cobertura', FALSE),
('Unidad No Disponible', 'No había unidad disponible en el momento', FALSE),
('Falsa Alarma', 'Reporte falso o no confirmado', FALSE),
('Ya Atendido por Otra Institución', 'Otro organismo ya estaba atendiendo', FALSE),
('Riesgo para la Unidad', 'Condiciones peligrosas para el personal', TRUE),
('Fuera de Competencia', 'No corresponde a las funciones de la institución', TRUE),
('Otro', 'Otro motivo no listado', TRUE);
