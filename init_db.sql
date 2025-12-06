-- Migración 001: Habilitar extensiones de PostgreSQL
-- Ejecutar como superuser

-- UUID para identificadores únicos
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Búsquedas fuzzy/texto (para buscadores)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- PostGIS para geolocalización (opcional pero recomendado)
-- Comentar si no se va a usar funcionalidades geo avanzadas
CREATE EXTENSION IF NOT EXISTS "postgis";

COMMENT ON EXTENSION "uuid-ossp" IS 'Generación de UUIDs';
COMMENT ON EXTENSION "pg_trgm" IS 'Búsquedas de texto similares (fuzzy)';
COMMENT ON EXTENSION "postgis" IS 'Funcionalidades geoespaciales';
-- Migración 002: Tablas base (autenticación y estructura organizacional)

-- ========================================
-- MÓDULO: AUTENTICACIÓN Y USUARIOS
-- ========================================

CREATE TABLE rol (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    permisos JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE rol IS 'Roles del sistema con permisos';
COMMENT ON COLUMN rol.permisos IS 'JSON con permisos específicos del rol';

-- Insertar roles iniciales
INSERT INTO rol (nombre, descripcion, permisos) VALUES
('ADMIN', 'Administrador del sistema', '{"all": true}'),
('COP', 'Operador del Centro de Operaciones', '{"incidentes": ["read", "update"], "unidades": ["read", "update"], "reportes": ["read"]}'),
('BRIGADA', 'Personal de campo', '{"incidentes": ["create", "read", "update"], "actividades": ["create", "read"]}'),
('OPERACIONES', 'Departamento de Operaciones', '{"reportes": ["read"], "actividades": ["read"], "estadisticas": ["read"]}'),
('ACCIDENTOLOGIA', 'Departamento de Accidentología', '{"incidentes": ["read"], "reportes": ["read"], "estadisticas": ["read"]}'),
('MANDOS', 'Jefes y supervisores', '{"all": ["read"], "reportes": ["read"], "estadisticas": ["read"]}'),
('PUBLICO', 'Usuario ciudadano', '{"incidentes_publicos": ["read"], "reportes_publicos": ["create"]}');

-- ========================================
-- TABLA: SEDE
-- ========================================

CREATE TABLE sede (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(50),
    municipio VARCHAR(50),
    direccion TEXT,
    telefono VARCHAR(20),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE sede IS 'Sedes/bases de operaciones de la institución';

CREATE INDEX idx_sede_codigo ON sede(codigo);
CREATE INDEX idx_sede_activa ON sede(activa);

-- Datos de ejemplo (ajustar según realidad)
INSERT INTO sede (codigo, nombre, departamento, municipio) VALUES
('SEDE-CENTRAL', 'Sede Central', 'Guatemala', 'Guatemala'),
('SEDE-NORTE', 'Sede Norte', 'Alta Verapaz', 'Cobán'),
('SEDE-SUR', 'Sede Sur', 'Escuintla', 'Escuintla'),
('SEDE-OCC', 'Sede Occidente', 'Quetzaltenango', 'Quetzaltenango');

-- ========================================
-- TABLA: USUARIO
-- ========================================

CREATE TABLE usuario (
    id SERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    rol_id INT NOT NULL REFERENCES rol(id) ON DELETE RESTRICT,
    sede_id INT REFERENCES sede(id) ON DELETE SET NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_acceso TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE usuario IS 'Usuarios del sistema';
COMMENT ON COLUMN usuario.password_hash IS 'Hash bcrypt de la contraseña';

CREATE INDEX idx_usuario_username ON usuario(username);
CREATE INDEX idx_usuario_rol ON usuario(rol_id);
CREATE INDEX idx_usuario_sede ON usuario(sede_id);
CREATE INDEX idx_usuario_activo ON usuario(activo);

-- ========================================
-- MÓDULO: UNIDADES Y BRIGADAS
-- ========================================

CREATE TABLE unidad (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    tipo_unidad VARCHAR(50) NOT NULL,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    anio INT,
    placa VARCHAR(20),
    sede_id INT NOT NULL REFERENCES sede(id) ON DELETE RESTRICT,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE unidad IS 'Vehículos/unidades operativas';
COMMENT ON COLUMN unidad.tipo_unidad IS 'MOTORIZADA, PICKUP, PATRULLA, etc.';

CREATE INDEX idx_unidad_codigo ON unidad(codigo);
CREATE INDEX idx_unidad_sede ON unidad(sede_id);
CREATE INDEX idx_unidad_activa ON unidad(activa);

CREATE TABLE brigada (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    sede_id INT NOT NULL REFERENCES sede(id) ON DELETE RESTRICT,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE brigada IS 'Brigadas de trabajo';

CREATE INDEX idx_brigada_codigo ON brigada(codigo);
CREATE INDEX idx_brigada_sede ON brigada(sede_id);
CREATE INDEX idx_brigada_activa ON brigada(activa);
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
-- Migración 004: Tablas de incidentes (CORE)

-- ========================================
-- TABLA PRINCIPAL: INCIDENTE
-- ========================================

CREATE TABLE incidente (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
    numero_reporte VARCHAR(50) UNIQUE,

    -- Clasificación y origen
    origen VARCHAR(30) NOT NULL CHECK (origen IN ('BRIGADA', 'USUARIO_PUBLICO', 'CENTRO_CONTROL')),
    estado VARCHAR(30) NOT NULL DEFAULT 'REPORTADO'
        CHECK (estado IN ('REPORTADO', 'EN_ATENCION', 'REGULACION', 'CERRADO', 'NO_ATENDIDO')),

    -- Tipo de hecho
    tipo_hecho_id INT NOT NULL REFERENCES tipo_hecho(id) ON DELETE RESTRICT,
    subtipo_hecho_id INT REFERENCES subtipo_hecho(id) ON DELETE SET NULL,

    -- Ubicación
    ruta_id INT NOT NULL REFERENCES ruta(id) ON DELETE RESTRICT,
    km DECIMAL(6,2) NOT NULL,
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE')),
    referencia_ubicacion TEXT,
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),

    -- Asignación
    unidad_id INT REFERENCES unidad(id) ON DELETE SET NULL,
    brigada_id INT REFERENCES brigada(id) ON DELETE SET NULL,

    -- Tiempos (cronología del incidente)
    fecha_hora_aviso TIMESTAMPTZ NOT NULL,
    fecha_hora_asignacion TIMESTAMPTZ,
    fecha_hora_llegada TIMESTAMPTZ,
    fecha_hora_estabilizacion TIMESTAMPTZ,
    fecha_hora_finalizacion TIMESTAMPTZ,

    -- Víctimas
    hay_heridos BOOLEAN NOT NULL DEFAULT FALSE,
    cantidad_heridos INT NOT NULL DEFAULT 0,
    hay_fallecidos BOOLEAN NOT NULL DEFAULT FALSE,
    cantidad_fallecidos INT NOT NULL DEFAULT 0,

    -- Recursos solicitados
    requiere_bomberos BOOLEAN NOT NULL DEFAULT FALSE,
    requiere_pnc BOOLEAN NOT NULL DEFAULT FALSE,
    requiere_ambulancia BOOLEAN NOT NULL DEFAULT FALSE,

    -- Observaciones
    observaciones_iniciales TEXT,
    observaciones_finales TEXT,

    -- Campos para accidentología
    condiciones_climaticas VARCHAR(50),
    tipo_pavimento VARCHAR(50),
    iluminacion VARCHAR(50),
    senalizacion VARCHAR(50),
    visibilidad VARCHAR(50),
    causa_probable TEXT,

    -- Información del reportante (si es público)
    reportado_por_nombre VARCHAR(150),
    reportado_por_telefono VARCHAR(20),
    reportado_por_email VARCHAR(100),
    foto_url TEXT,

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    actualizado_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT chk_heridos CHECK (
        (hay_heridos = FALSE AND cantidad_heridos = 0) OR
        (hay_heridos = TRUE AND cantidad_heridos > 0)
    ),
    CONSTRAINT chk_fallecidos CHECK (
        (hay_fallecidos = FALSE AND cantidad_fallecidos = 0) OR
        (hay_fallecidos = TRUE AND cantidad_fallecidos > 0)
    ),
    CONSTRAINT chk_fechas_cronologicas CHECK (
        (fecha_hora_llegada IS NULL OR fecha_hora_llegada >= fecha_hora_aviso) AND
        (fecha_hora_finalizacion IS NULL OR fecha_hora_finalizacion >= fecha_hora_aviso)
    )
);

COMMENT ON TABLE incidente IS 'Tabla principal de incidentes/hechos viales';
COMMENT ON COLUMN incidente.numero_reporte IS 'Número único legible (ej: INC-2025-0001)';
COMMENT ON COLUMN incidente.origen IS 'Quién reportó el incidente';
COMMENT ON COLUMN incidente.estado IS 'Estado actual del incidente';

-- Índices críticos para performance
CREATE INDEX idx_incidente_uuid ON incidente(uuid);
CREATE INDEX idx_incidente_numero ON incidente(numero_reporte);
CREATE INDEX idx_incidente_estado ON incidente(estado);
CREATE INDEX idx_incidente_origen ON incidente(origen);
CREATE INDEX idx_incidente_fecha_aviso ON incidente(fecha_hora_aviso);
CREATE INDEX idx_incidente_ruta_km ON incidente(ruta_id, km);
CREATE INDEX idx_incidente_unidad ON incidente(unidad_id);
CREATE INDEX idx_incidente_created_at ON incidente(created_at DESC);
CREATE INDEX idx_incidente_tipo_hecho ON incidente(tipo_hecho_id);

-- Índice para búsquedas de incidentes activos/recientes
CREATE INDEX idx_incidente_activos ON incidente(fecha_hora_aviso, estado)
WHERE estado IN ('REPORTADO', 'EN_ATENCION', 'REGULACION');

-- ========================================
-- TABLA: VEHICULO INCIDENTE
-- ========================================

CREATE TABLE vehiculo_incidente (
    id BIGSERIAL PRIMARY KEY,
    incidente_id BIGINT NOT NULL REFERENCES incidente(id) ON DELETE CASCADE,

    -- Datos del vehículo
    tipo_vehiculo_id INT REFERENCES tipo_vehiculo(id) ON DELETE SET NULL,
    marca_id INT REFERENCES marca_vehiculo(id) ON DELETE SET NULL,
    modelo VARCHAR(50),
    anio INT,
    color VARCHAR(30),
    placa VARCHAR(20),

    -- Piloto
    estado_piloto VARCHAR(30) CHECK (estado_piloto IN ('ILESO', 'HERIDO', 'FALLECIDO', 'TRASLADADO', 'HUYO')),
    nombre_piloto VARCHAR(150),
    licencia_piloto VARCHAR(50),

    -- Víctimas en este vehículo
    heridos_en_vehiculo INT NOT NULL DEFAULT 0,
    fallecidos_en_vehiculo INT NOT NULL DEFAULT 0,

    -- Daños
    danos_estimados VARCHAR(50) CHECK (danos_estimados IN ('LEVE', 'MODERADO', 'GRAVE', 'PERDIDA_TOTAL')),
    observaciones TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE vehiculo_incidente IS 'Vehículos involucrados en un incidente';

CREATE INDEX idx_vehiculo_incidente ON vehiculo_incidente(incidente_id);
CREATE INDEX idx_vehiculo_tipo ON vehiculo_incidente(tipo_vehiculo_id);

-- ========================================
-- TABLA: OBSTRUCCION INCIDENTE
-- ========================================

CREATE TABLE obstruccion_incidente (
    id BIGSERIAL PRIMARY KEY,
    incidente_id BIGINT NOT NULL UNIQUE REFERENCES incidente(id) ON DELETE CASCADE,
    descripcion_generada TEXT,
    datos_carriles_json JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE obstruccion_incidente IS 'Información de obstrucción de carriles (relación 1:1 con incidente)';
COMMENT ON COLUMN obstruccion_incidente.descripcion_generada IS 'Texto auto-generado legible de la obstrucción';
COMMENT ON COLUMN obstruccion_incidente.datos_carriles_json IS 'Estado detallado de carriles por dirección';

CREATE INDEX idx_obstruccion_incidente ON obstruccion_incidente(incidente_id);

-- ========================================
-- TABLA: RECURSO INCIDENTE
-- ========================================

CREATE TABLE recurso_incidente (
    id BIGSERIAL PRIMARY KEY,
    incidente_id BIGINT NOT NULL REFERENCES incidente(id) ON DELETE CASCADE,
    tipo_recurso VARCHAR(50) NOT NULL CHECK (tipo_recurso IN ('GRUA', 'BOMBEROS', 'PNC', 'AMBULANCIA', 'AJUSTADOR', 'OTRO')),
    descripcion TEXT,
    hora_solicitud TIMESTAMPTZ,
    hora_llegada TIMESTAMPTZ,
    observaciones TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE recurso_incidente IS 'Recursos externos solicitados para un incidente';

CREATE INDEX idx_recurso_incidente ON recurso_incidente(incidente_id);

-- ========================================
-- TABLA: INCIDENTE NO ATENDIDO
-- ========================================

CREATE TABLE incidente_no_atendido (
    id BIGSERIAL PRIMARY KEY,
    incidente_id BIGINT NOT NULL UNIQUE REFERENCES incidente(id) ON DELETE CASCADE,
    motivo_id INT NOT NULL REFERENCES motivo_no_atendido(id) ON DELETE RESTRICT,
    observaciones TEXT,
    registrado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE incidente_no_atendido IS 'Información de incidentes que no fueron atendidos (relación 1:1)';

CREATE INDEX idx_incidente_no_atendido ON incidente_no_atendido(incidente_id);
CREATE INDEX idx_incidente_no_atendido_motivo ON incidente_no_atendido(motivo_id);
-- Migración 005: Tablas de actividades de unidades

-- ========================================
-- TABLA: ACTIVIDAD UNIDAD
-- ========================================

CREATE TABLE actividad_unidad (
    id BIGSERIAL PRIMARY KEY,

    -- Unidad y tipo
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE CASCADE,
    tipo_actividad_id INT NOT NULL REFERENCES tipo_actividad(id) ON DELETE RESTRICT,

    -- Asociación opcional a incidente
    incidente_id BIGINT REFERENCES incidente(id) ON DELETE SET NULL,

    -- Ubicación
    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km DECIMAL(6,2),
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE')),

    -- Tiempos
    hora_inicio TIMESTAMPTZ NOT NULL,
    hora_fin TIMESTAMPTZ,

    -- Detalles
    observaciones TEXT,

    -- Auditoría
    registrado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraint
    CONSTRAINT chk_actividad_tiempos CHECK (
        hora_fin IS NULL OR hora_fin >= hora_inicio
    )
);

COMMENT ON TABLE actividad_unidad IS 'Actividades que realizan las unidades durante el día';
COMMENT ON COLUMN actividad_unidad.hora_fin IS 'NULL si la actividad está en curso';

-- Índices
CREATE INDEX idx_actividad_unidad ON actividad_unidad(unidad_id);
CREATE INDEX idx_actividad_fecha ON actividad_unidad(hora_inicio DESC);
CREATE INDEX idx_actividad_tipo ON actividad_unidad(tipo_actividad_id);
CREATE INDEX idx_actividad_incidente ON actividad_unidad(incidente_id);

-- Índice para actividades activas (hora_fin NULL)
CREATE INDEX idx_actividad_activa ON actividad_unidad(unidad_id, hora_fin)
WHERE hora_fin IS NULL;

-- Constraint: Una unidad solo puede tener UNA actividad activa (hora_fin NULL) a la vez
CREATE UNIQUE INDEX idx_unidad_actividad_activa
ON actividad_unidad (unidad_id)
WHERE hora_fin IS NULL;

COMMENT ON INDEX idx_unidad_actividad_activa IS 'Garantiza que una unidad solo tenga una actividad activa simultáneamente';
-- Migración 006: Tabla de auditoría

-- ========================================
-- TABLA: AUDITORIA LOG
-- ========================================

CREATE TABLE auditoria_log (
    id BIGSERIAL PRIMARY KEY,

    -- Usuario que realizó la acción
    usuario_id INT REFERENCES usuario(id) ON DELETE SET NULL,

    -- Acción realizada
    accion VARCHAR(50) NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'EXPORT', 'OTHER')),

    -- Tabla/recurso afectado
    tabla_afectada VARCHAR(100),
    registro_id BIGINT,

    -- Datos del cambio
    datos_anteriores JSONB,
    datos_nuevos JSONB,

    -- Información de contexto
    ip_address VARCHAR(45),
    user_agent TEXT,

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE auditoria_log IS 'Log de auditoría de todas las acciones importantes del sistema';
COMMENT ON COLUMN auditoria_log.datos_anteriores IS 'Estado del registro antes del cambio';
COMMENT ON COLUMN auditoria_log.datos_nuevos IS 'Estado del registro después del cambio';

-- Índices
CREATE INDEX idx_auditoria_usuario ON auditoria_log(usuario_id);
CREATE INDEX idx_auditoria_tabla ON auditoria_log(tabla_afectada);
CREATE INDEX idx_auditoria_created ON auditoria_log(created_at DESC);
CREATE INDEX idx_auditoria_accion ON auditoria_log(accion);

-- Índice compuesto para búsquedas por tabla y registro
CREATE INDEX idx_auditoria_tabla_registro ON auditoria_log(tabla_afectada, registro_id);
-- Migración 007: Triggers y funciones

-- ========================================
-- FUNCIÓN: Actualizar updated_at automáticamente
-- ========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column IS 'Actualiza automáticamente la columna updated_at al modificar un registro';

-- Aplicar trigger a tablas con updated_at
CREATE TRIGGER update_usuario_updated_at
    BEFORE UPDATE ON usuario
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_unidad_updated_at
    BEFORE UPDATE ON unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_incidente_updated_at
    BEFORE UPDATE ON incidente
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_actividad_updated_at
    BEFORE UPDATE ON actividad_unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_obstruccion_updated_at
    BEFORE UPDATE ON obstruccion_incidente
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- FUNCIÓN: Generar número de reporte automático
-- ========================================

CREATE OR REPLACE FUNCTION generar_numero_reporte()
RETURNS TRIGGER AS $$
DECLARE
    anio INT;
    secuencia INT;
BEGIN
    -- Obtener año del aviso
    anio := EXTRACT(YEAR FROM NEW.fecha_hora_aviso);

    -- Obtener siguiente número secuencial del año
    SELECT COALESCE(
        MAX(
            CAST(
                SUBSTRING(numero_reporte FROM 'INC-\d{4}-(\d+)') AS INT
            )
        ), 0
    ) + 1
    INTO secuencia
    FROM incidente
    WHERE EXTRACT(YEAR FROM fecha_hora_aviso) = anio;

    -- Generar número: INC-2025-0001
    NEW.numero_reporte := 'INC-' || anio || '-' || LPAD(secuencia::TEXT, 4, '0');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_numero_reporte IS 'Genera automáticamente el número de reporte en formato INC-YYYY-####';

CREATE TRIGGER trigger_generar_numero_reporte
    BEFORE INSERT ON incidente
    FOR EACH ROW
    WHEN (NEW.numero_reporte IS NULL)
    EXECUTE FUNCTION generar_numero_reporte();

-- ========================================
-- FUNCIÓN: Cerrar actividad anterior al abrir nueva
-- ========================================

CREATE OR REPLACE FUNCTION cerrar_actividad_anterior()
RETURNS TRIGGER AS $$
BEGIN
    -- Cerrar cualquier actividad previa abierta de la misma unidad
    UPDATE actividad_unidad
    SET hora_fin = NEW.hora_inicio
    WHERE unidad_id = NEW.unidad_id
      AND hora_fin IS NULL
      AND id != COALESCE(NEW.id, 0);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cerrar_actividad_anterior IS 'Cierra automáticamente la actividad anterior al iniciar una nueva para la misma unidad';

CREATE TRIGGER trigger_cerrar_actividad_anterior
    BEFORE INSERT ON actividad_unidad
    FOR EACH ROW
    EXECUTE FUNCTION cerrar_actividad_anterior();

-- ========================================
-- FUNCIÓN: Validar que actividad con incidente tenga tipo correcto
-- ========================================

CREATE OR REPLACE FUNCTION validar_actividad_incidente()
RETURNS TRIGGER AS $$
DECLARE
    requiere_incidente_val BOOLEAN;
BEGIN
    -- Si la actividad tiene incidente asociado
    IF NEW.incidente_id IS NOT NULL THEN
        -- Verificar que el tipo de actividad requiera incidente
        SELECT requiere_incidente INTO requiere_incidente_val
        FROM tipo_actividad
        WHERE id = NEW.tipo_actividad_id;

        IF requiere_incidente_val = FALSE THEN
            RAISE EXCEPTION 'El tipo de actividad "%" no puede estar asociado a un incidente',
                (SELECT nombre FROM tipo_actividad WHERE id = NEW.tipo_actividad_id);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_actividad_incidente IS 'Valida que las actividades asociadas a incidentes tengan tipo correcto';

CREATE TRIGGER trigger_validar_actividad_incidente
    BEFORE INSERT OR UPDATE ON actividad_unidad
    FOR EACH ROW
    EXECUTE FUNCTION validar_actividad_incidente();

-- ========================================
-- FUNCIÓN: Registrar cambios en auditoría (ejemplo para incidentes)
-- ========================================

CREATE OR REPLACE FUNCTION log_incidente_cambios()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria_log (
            usuario_id, accion, tabla_afectada, registro_id,
            datos_nuevos, ip_address
        ) VALUES (
            NEW.creado_por, 'INSERT', 'incidente', NEW.id,
            to_jsonb(NEW), inet_client_addr()::TEXT
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_log (
            usuario_id, accion, tabla_afectada, registro_id,
            datos_anteriores, datos_nuevos, ip_address
        ) VALUES (
            NEW.actualizado_por, 'UPDATE', 'incidente', NEW.id,
            to_jsonb(OLD), to_jsonb(NEW), inet_client_addr()::TEXT
        );
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_log (
            usuario_id, accion, tabla_afectada, registro_id,
            datos_anteriores, ip_address
        ) VALUES (
            OLD.actualizado_por, 'DELETE', 'incidente', OLD.id,
            to_jsonb(OLD), inet_client_addr()::TEXT
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION log_incidente_cambios IS 'Registra automáticamente cambios en incidentes en el log de auditoría';

CREATE TRIGGER trigger_log_incidente_cambios
    AFTER INSERT OR UPDATE OR DELETE ON incidente
    FOR EACH ROW
    EXECUTE FUNCTION log_incidente_cambios();
-- Migración 008: Vistas y vistas materializadas

-- ========================================
-- VISTA: Incidentes con información completa
-- ========================================

CREATE OR REPLACE VIEW v_incidentes_completos AS
SELECT
    i.id,
    i.uuid,
    i.numero_reporte,
    i.origen,
    i.estado,

    -- Tipo de hecho
    th.nombre AS tipo_hecho,
    sth.nombre AS subtipo_hecho,
    th.color AS tipo_hecho_color,
    th.icono AS tipo_hecho_icono,

    -- Ubicación
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    i.km,
    i.sentido,
    i.referencia_ubicacion,
    i.latitud,
    i.longitud,

    -- Unidad y brigada
    u.codigo AS unidad_codigo,
    b.codigo AS brigada_codigo,
    b.nombre AS brigada_nombre,
    s.nombre AS sede_nombre,

    -- Tiempos
    i.fecha_hora_aviso,
    i.fecha_hora_asignacion,
    i.fecha_hora_llegada,
    i.fecha_hora_estabilizacion,
    i.fecha_hora_finalizacion,

    -- Tiempo de respuesta (en minutos)
    EXTRACT(EPOCH FROM (i.fecha_hora_llegada - i.fecha_hora_aviso))/60 AS tiempo_respuesta_min,
    EXTRACT(EPOCH FROM (i.fecha_hora_finalizacion - i.fecha_hora_llegada))/60 AS tiempo_atencion_min,

    -- Víctimas
    i.hay_heridos,
    i.cantidad_heridos,
    i.hay_fallecidos,
    i.cantidad_fallecidos,

    -- Recursos
    i.requiere_bomberos,
    i.requiere_pnc,
    i.requiere_ambulancia,

    -- Conteo de vehículos
    (SELECT COUNT(*) FROM vehiculo_incidente vi WHERE vi.incidente_id = i.id) AS total_vehiculos,

    -- Obstrucción
    o.descripcion_generada AS obstruccion_descripcion,

    -- Usuario creador
    usr.nombre_completo AS creado_por_nombre,

    -- Timestamps
    i.created_at,
    i.updated_at

FROM incidente i
JOIN tipo_hecho th ON i.tipo_hecho_id = th.id
LEFT JOIN subtipo_hecho sth ON i.subtipo_hecho_id = sth.id
JOIN ruta r ON i.ruta_id = r.id
LEFT JOIN unidad u ON i.unidad_id = u.id
LEFT JOIN brigada b ON i.brigada_id = b.id
LEFT JOIN sede s ON u.sede_id = s.id
LEFT JOIN obstruccion_incidente o ON i.id = o.incidente_id
JOIN usuario usr ON i.creado_por = usr.id;

COMMENT ON VIEW v_incidentes_completos IS 'Vista completa de incidentes con todos los datos relacionados';

-- ========================================
-- VISTA: Actividades de unidades con información completa
-- ========================================

CREATE OR REPLACE VIEW v_actividades_completas AS
SELECT
    a.id,
    a.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.nombre AS sede_nombre,

    ta.nombre AS tipo_actividad,
    ta.color AS tipo_actividad_color,

    a.hora_inicio,
    a.hora_fin,
    EXTRACT(EPOCH FROM (COALESCE(a.hora_fin, NOW()) - a.hora_inicio))/60 AS duracion_min,

    -- Ubicación
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km,
    a.sentido,

    -- Incidente asociado
    a.incidente_id,
    i.numero_reporte AS incidente_numero,

    -- Usuario
    usr.nombre_completo AS registrado_por_nombre,

    a.observaciones,
    a.created_at

FROM actividad_unidad a
JOIN unidad u ON a.unidad_id = u.id
JOIN sede s ON u.sede_id = s.id
JOIN tipo_actividad ta ON a.tipo_actividad_id = ta.id
LEFT JOIN ruta r ON a.ruta_id = r.id
LEFT JOIN incidente i ON a.incidente_id = i.id
JOIN usuario usr ON a.registrado_por = usr.id;

COMMENT ON VIEW v_actividades_completas IS 'Vista completa de actividades con información relacionada';

-- ========================================
-- VISTA MATERIALIZADA: Estadísticas diarias
-- ========================================

CREATE MATERIALIZED VIEW mv_estadisticas_diarias AS
SELECT
    DATE(i.fecha_hora_aviso) AS fecha,
    i.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    i.tipo_hecho_id,
    th.nombre AS tipo_hecho,
    i.origen,
    i.estado,

    COUNT(*) AS total_incidentes,
    SUM(i.cantidad_heridos) AS total_heridos,
    SUM(i.cantidad_fallecidos) AS total_fallecidos,

    -- Tiempos promedio
    AVG(EXTRACT(EPOCH FROM (i.fecha_hora_llegada - i.fecha_hora_aviso))/60) AS tiempo_respuesta_promedio_min,
    AVG(EXTRACT(EPOCH FROM (i.fecha_hora_finalizacion - i.fecha_hora_llegada))/60) AS tiempo_atencion_promedio_min,

    -- Contadores por estado
    COUNT(*) FILTER (WHERE i.estado = 'CERRADO') AS total_cerrados,
    COUNT(*) FILTER (WHERE i.estado = 'NO_ATENDIDO') AS total_no_atendidos,

    -- Contadores por víctimas
    COUNT(*) FILTER (WHERE i.hay_heridos = TRUE) AS incidentes_con_heridos,
    COUNT(*) FILTER (WHERE i.hay_fallecidos = TRUE) AS incidentes_con_fallecidos

FROM incidente i
JOIN ruta r ON i.ruta_id = r.id
JOIN tipo_hecho th ON i.tipo_hecho_id = th.id
WHERE i.fecha_hora_aviso >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY
    DATE(i.fecha_hora_aviso),
    i.ruta_id, r.codigo, r.nombre,
    i.tipo_hecho_id, th.nombre,
    i.origen,
    i.estado;

-- Índice único para refresh concurrente
CREATE UNIQUE INDEX idx_mv_estadisticas_diarias
ON mv_estadisticas_diarias (fecha, ruta_id, tipo_hecho_id, origen, estado);

-- Índices adicionales para consultas frecuentes
CREATE INDEX idx_mv_estadisticas_fecha ON mv_estadisticas_diarias(fecha DESC);
CREATE INDEX idx_mv_estadisticas_ruta ON mv_estadisticas_diarias(ruta_id);

COMMENT ON MATERIALIZED VIEW mv_estadisticas_diarias IS 'Estadísticas diarias de incidentes (últimos 90 días). Refrescar nightly.';

-- ========================================
-- VISTA MATERIALIZADA: Métricas de no atendidos
-- ========================================

CREATE MATERIALIZED VIEW mv_no_atendidos_por_motivo AS
SELECT
    DATE_TRUNC('month', i.fecha_hora_aviso) AS mes,
    m.id AS motivo_id,
    m.nombre AS motivo,
    r.id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.id AS sede_id,
    s.nombre AS sede_nombre,

    COUNT(*) AS total,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY DATE_TRUNC('month', i.fecha_hora_aviso)),
        2
    ) AS porcentaje_del_mes

FROM incidente i
JOIN incidente_no_atendido ina ON i.id = ina.incidente_id
JOIN motivo_no_atendido m ON ina.motivo_id = m.id
JOIN ruta r ON i.ruta_id = r.id
LEFT JOIN unidad u ON i.unidad_id = u.id
LEFT JOIN sede s ON u.sede_id = s.id
WHERE i.estado = 'NO_ATENDIDO'
  AND i.fecha_hora_aviso >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY
    DATE_TRUNC('month', i.fecha_hora_aviso),
    m.id, m.nombre,
    r.id, r.codigo, r.nombre,
    s.id, s.nombre;

CREATE UNIQUE INDEX idx_mv_no_atendidos
ON mv_no_atendidos_por_motivo (mes, motivo_id, COALESCE(ruta_id, 0), COALESCE(sede_id, 0));

COMMENT ON MATERIALIZED VIEW mv_no_atendidos_por_motivo IS 'Métricas de incidentes no atendidos por motivo (últimos 12 meses)';

-- ========================================
-- VISTA: Estado actual de unidades (última actividad)
-- ========================================

CREATE OR REPLACE VIEW v_estado_actual_unidades AS
SELECT DISTINCT ON (u.id)
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.nombre AS sede_nombre,
    u.activa,

    -- Última actividad
    ta.nombre AS actividad_actual,
    ta.color AS actividad_color,
    a.hora_inicio AS desde,
    r.codigo AS ruta_codigo,
    a.km,
    a.sentido,
    a.observaciones,

    -- Incidente asociado (si aplica)
    i.numero_reporte AS incidente_numero,
    i.estado AS incidente_estado

FROM unidad u
JOIN sede s ON u.sede_id = s.id
LEFT JOIN LATERAL (
    SELECT *
    FROM actividad_unidad au
    WHERE au.unidad_id = u.id
      AND au.hora_fin IS NULL
    ORDER BY au.hora_inicio DESC
    LIMIT 1
) a ON TRUE
LEFT JOIN tipo_actividad ta ON a.tipo_actividad_id = ta.id
LEFT JOIN ruta r ON a.ruta_id = r.id
LEFT JOIN incidente i ON a.incidente_id = i.id
ORDER BY u.id;

COMMENT ON VIEW v_estado_actual_unidades IS 'Estado actual de todas las unidades (actividad activa)';
-- Migración 009: Datos de prueba (seed)

-- NOTA: Este archivo es OPCIONAL y solo para desarrollo/testing
-- NO ejecutar en producción a menos que se necesiten datos de ejemplo

-- ========================================
-- USUARIOS DE PRUEBA
-- ========================================

-- Contraseña para todos los usuarios de prueba: "password123"
-- Hash bcrypt: $2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7
-- IMPORTANTE: En producción usar contraseñas seguras reales

INSERT INTO usuario (username, password_hash, nombre_completo, rol_id, sede_id) VALUES
-- Admin
('admin', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Administrador Sistema',
    (SELECT id FROM rol WHERE nombre = 'ADMIN'), NULL),

-- Operadores COP
('cop01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Juan Pérez - COP',
    (SELECT id FROM rol WHERE nombre = 'COP'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('cop02', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'María López - COP',
    (SELECT id FROM rol WHERE nombre = 'COP'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),

-- Brigadas
('brigada01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Carlos Ramírez - Brigada',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('brigada02', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Ana Morales - Brigada',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'), (SELECT id FROM sede WHERE codigo = 'SEDE-NORTE')),

-- Operaciones
('operaciones01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Luis García - Operaciones',
    (SELECT id FROM rol WHERE nombre = 'OPERACIONES'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),

-- Accidentología
('accidentologia01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Patricia Hernández - Accidentología',
    (SELECT id FROM rol WHERE nombre = 'ACCIDENTOLOGIA'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),

-- Mandos
('mando01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'General Roberto Vásquez',
    (SELECT id FROM rol WHERE nombre = 'MANDOS'), NULL);

-- ========================================
-- UNIDADES DE PRUEBA
-- ========================================

INSERT INTO unidad (codigo, tipo_unidad, marca, modelo, anio, placa, sede_id) VALUES
('PROV-001', 'MOTORIZADA', 'Honda', 'XR190', 2023, 'P-001GT', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('PROV-002', 'MOTORIZADA', 'Yamaha', 'FZ16', 2022, 'P-002GT', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('PROV-003', 'PICKUP', 'Toyota', 'Hilux', 2021, 'P-003GT', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('PROV-004', 'MOTORIZADA', 'Suzuki', 'GN125', 2023, 'P-004GT', (SELECT id FROM sede WHERE codigo = 'SEDE-NORTE')),
('PROV-005', 'PICKUP', 'Nissan', 'Frontier', 2020, 'P-005GT', (SELECT id FROM sede WHERE codigo = 'SEDE-SUR'));

-- ========================================
-- BRIGADAS DE PRUEBA
-- ========================================

INSERT INTO brigada (codigo, nombre, sede_id) VALUES
('BRIG-A1', 'Brigada Alpha 1', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('BRIG-A2', 'Brigada Alpha 2', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('BRIG-N1', 'Brigada Norte 1', (SELECT id FROM sede WHERE codigo = 'SEDE-NORTE')),
('BRIG-S1', 'Brigada Sur 1', (SELECT id FROM sede WHERE codigo = 'SEDE-SUR'));

-- ========================================
-- INCIDENTES DE PRUEBA
-- ========================================

-- Incidente 1: Accidente vial en CA-9
INSERT INTO incidente (
    origen, estado, tipo_hecho_id, subtipo_hecho_id, ruta_id, km, sentido,
    unidad_id, brigada_id,
    fecha_hora_aviso, fecha_hora_asignacion, fecha_hora_llegada, fecha_hora_finalizacion,
    hay_heridos, cantidad_heridos, hay_fallecidos, cantidad_fallecidos,
    requiere_ambulancia, observaciones_iniciales, observaciones_finales,
    creado_por, actualizado_por
) VALUES (
    'BRIGADA', 'CERRADO',
    (SELECT id FROM tipo_hecho WHERE nombre = 'Accidente Vial'),
    (SELECT id FROM subtipo_hecho WHERE nombre = 'Colisión'),
    (SELECT id FROM ruta WHERE codigo = 'CA-9'),
    52.5, 'NORTE',
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM brigada WHERE codigo = 'BRIG-A1'),
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '1 hour 55 minutes',
    NOW() - INTERVAL '1 hour 40 minutes',
    NOW() - INTERVAL '30 minutes',
    TRUE, 2, FALSE, 0,
    TRUE,
    'Colisión entre automóvil y pickup, 2 heridos leves',
    'Ambulancia trasladó heridos, vía despejada',
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    (SELECT id FROM usuario WHERE username = 'brigada01')
);

-- Vehículos del incidente 1
INSERT INTO vehiculo_incidente (
    incidente_id, tipo_vehiculo_id, marca_id, color, placa,
    estado_piloto, heridos_en_vehiculo, danos_estimados
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM tipo_vehiculo WHERE nombre = 'Automóvil'),
    (SELECT id FROM marca_vehiculo WHERE nombre = 'Toyota'),
    'Rojo', 'P-123ABC',
    'HERIDO', 1, 'MODERADO'
),
(
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM tipo_vehiculo WHERE nombre = 'Pickup'),
    (SELECT id FROM marca_vehiculo WHERE nombre = 'Nissan'),
    'Blanco', 'P-456DEF',
    'HERIDO', 1, 'LEVE'
);

-- Obstrucción del incidente 1
INSERT INTO obstruccion_incidente (
    incidente_id, descripcion_generada, datos_carriles_json
) VALUES (
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    'Obstruido carril derecho hacia el Norte, flujo lento',
    '{"norte": {"totalCarriles": 2, "carrilObstruido": 1, "carrilHabilitado": 2, "flujo": "LENTO"}}'
);

-- Incidente 2: Vehículo varado
INSERT INTO incidente (
    origen, estado, tipo_hecho_id, subtipo_hecho_id, ruta_id, km, sentido,
    unidad_id, brigada_id,
    fecha_hora_aviso, fecha_hora_llegada,
    observaciones_iniciales,
    creado_por
) VALUES (
    'BRIGADA', 'EN_ATENCION',
    (SELECT id FROM tipo_hecho WHERE nombre = 'Vehículo Varado'),
    (SELECT id FROM subtipo_hecho WHERE nombre = 'Falla Mecánica'),
    (SELECT id FROM ruta WHERE codigo = 'CA-1'),
    78.3, 'OESTE',
    (SELECT id FROM unidad WHERE codigo = 'PROV-003'),
    (SELECT id FROM brigada WHERE codigo = 'BRIG-A2'),
    NOW() - INTERVAL '30 minutes',
    NOW() - INTERVAL '15 minutes',
    'Cabezal varado en curva, solicitando grúa',
    (SELECT id FROM usuario WHERE username = 'brigada02')
);

-- Vehículo del incidente 2
INSERT INTO vehiculo_incidente (
    incidente_id, tipo_vehiculo_id, color,
    estado_piloto, danos_estimados
) VALUES (
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM tipo_vehiculo WHERE nombre = 'Cabezal'),
    'Azul',
    'ILESO', NULL
);

-- Recurso solicitado
INSERT INTO recurso_incidente (
    incidente_id, tipo_recurso, descripcion, hora_solicitud
) VALUES (
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    'GRUA', 'Grúa para cabezal', NOW() - INTERVAL '10 minutes'
);

-- ========================================
-- ACTIVIDADES DE PRUEBA
-- ========================================

-- Actividad cerrada: Patrullaje
INSERT INTO actividad_unidad (
    unidad_id, tipo_actividad_id, ruta_id, km, sentido,
    hora_inicio, hora_fin, observaciones, registrado_por
) VALUES (
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM tipo_actividad WHERE nombre = 'Patrullaje'),
    (SELECT id FROM ruta WHERE codigo = 'CA-9'),
    45.0, 'NORTE',
    NOW() - INTERVAL '3 hours',
    NOW() - INTERVAL '2 hours',
    'Patrullaje rutinario km 40-55',
    (SELECT id FROM usuario WHERE username = 'brigada01')
);

-- Actividad activa: En accidente
INSERT INTO actividad_unidad (
    unidad_id, tipo_actividad_id, ruta_id, km, incidente_id,
    hora_inicio, observaciones, registrado_por
) VALUES (
    (SELECT id FROM unidad WHERE codigo = 'PROV-003'),
    (SELECT id FROM tipo_actividad WHERE nombre = 'Vehículo Varado'),
    (SELECT id FROM ruta WHERE codigo = 'CA-1'),
    78.3,
    (SELECT id FROM incidente WHERE estado = 'EN_ATENCION' ORDER BY created_at DESC LIMIT 1),
    NOW() - INTERVAL '15 minutes',
    'Atendiendo vehículo varado',
    (SELECT id FROM usuario WHERE username = 'brigada02')
);

-- ========================================
-- NOTAS
-- ========================================

-- Para ver los datos insertados:
-- SELECT * FROM v_incidentes_completos ORDER BY created_at DESC;
-- SELECT * FROM v_actividades_completas ORDER BY hora_inicio DESC;
-- SELECT * FROM v_estado_actual_unidades;

COMMENT ON SCHEMA public IS 'Datos de prueba cargados correctamente. Usuarios: admin, cop01, cop02, brigada01, brigada02, operaciones01, accidentologia01, mando01. Password: password123';
-- Migración 010: Sistema de turnos y asignaciones de operaciones

-- ========================================
-- TABLA: TURNO
-- ========================================

CREATE TABLE turno (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'PLANIFICADO'
        CHECK (estado IN ('PLANIFICADO', 'ACTIVO', 'CERRADO')),

    -- Observaciones generales del día
    observaciones TEXT,

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    aprobado_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    fecha_aprobacion TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Un solo turno por fecha
    UNIQUE(fecha)
);

COMMENT ON TABLE turno IS 'Turnos de trabajo por día (planificación de Operaciones)';
COMMENT ON COLUMN turno.estado IS 'PLANIFICADO: creado pero no iniciado | ACTIVO: en curso | CERRADO: finalizado';

CREATE INDEX idx_turno_fecha ON turno(fecha DESC);
CREATE INDEX idx_turno_estado ON turno(estado);

-- Trigger para updated_at
CREATE TRIGGER update_turno_updated_at
    BEFORE UPDATE ON turno
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- TABLA: ASIGNACION_UNIDAD
-- ========================================

CREATE TABLE asignacion_unidad (
    id SERIAL PRIMARY KEY,
    turno_id INT NOT NULL REFERENCES turno(id) ON DELETE CASCADE,
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Zona de patrullaje asignada
    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km_inicio DECIMAL(6,2),
    km_final DECIMAL(6,2),
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE', 'AMBOS')),

    -- Acciones/instrucciones específicas
    acciones TEXT,
    -- Ejemplos:
    --  "Regular en km 30"
    --  "Apoyo a trabajos en km 10"
    --  "Patrullaje rutinario"

    -- Control de combustible
    combustible_inicial DECIMAL(5,2), -- Litros al inicio
    combustible_asignado DECIMAL(5,2), -- Litros asignados para el turno

    -- Horario
    hora_salida TIME,
    hora_entrada_estimada TIME,

    -- Estado real (se actualiza durante el día)
    hora_salida_real TIMESTAMPTZ,
    hora_entrada_real TIMESTAMPTZ,
    combustible_final DECIMAL(5,2), -- Litros al finalizar
    km_recorridos DECIMAL(8,2), -- Calculado automáticamente

    observaciones_finales TEXT, -- Al cerrar el turno

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Una unidad solo puede tener una asignación por turno
    UNIQUE(turno_id, unidad_id)
);

COMMENT ON TABLE asignacion_unidad IS 'Asignación de unidades a rutas/zonas por turno';
COMMENT ON COLUMN asignacion_unidad.acciones IS 'Instrucciones específicas para la unidad en este turno';
COMMENT ON COLUMN asignacion_unidad.km_recorridos IS 'Kilometraje recorrido durante el turno';

CREATE INDEX idx_asignacion_turno ON asignacion_unidad(turno_id);
CREATE INDEX idx_asignacion_unidad ON asignacion_unidad(unidad_id);
CREATE INDEX idx_asignacion_ruta ON asignacion_unidad(ruta_id);

-- Trigger para updated_at
CREATE TRIGGER update_asignacion_updated_at
    BEFORE UPDATE ON asignacion_unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- TABLA: TRIPULACION_TURNO
-- ========================================

CREATE TABLE tripulacion_turno (
    id SERIAL PRIMARY KEY,
    asignacion_id INT NOT NULL REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    usuario_id INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,

    -- Rol en la unidad
    rol_tripulacion VARCHAR(30) NOT NULL CHECK (rol_tripulacion IN ('PILOTO', 'COPILOTO', 'ACOMPAÑANTE')),

    -- Control de asistencia
    presente BOOLEAN DEFAULT TRUE,
    observaciones TEXT, -- Si no vino, motivo, etc.

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Un usuario solo puede tener un rol por asignación
    UNIQUE(asignacion_id, usuario_id)
);

COMMENT ON TABLE tripulacion_turno IS 'Tripulación asignada a cada unidad por turno';
COMMENT ON COLUMN tripulacion_turno.rol_tripulacion IS 'Rol del brigadista en la unidad para este turno';
COMMENT ON COLUMN tripulacion_turno.presente IS 'Si el brigadista se presentó al turno';

CREATE INDEX idx_tripulacion_asignacion ON tripulacion_turno(asignacion_id);
CREATE INDEX idx_tripulacion_usuario ON tripulacion_turno(usuario_id);

-- Constraint: Solo un piloto por unidad
CREATE UNIQUE INDEX idx_un_piloto_por_asignacion
ON tripulacion_turno (asignacion_id)
WHERE rol_tripulacion = 'PILOTO';

COMMENT ON INDEX idx_un_piloto_por_asignacion IS 'Garantiza que cada unidad tenga exactamente un piloto';

-- ========================================
-- TABLA: REPORTE_HORARIO
-- ========================================

CREATE TABLE reporte_horario (
    id BIGSERIAL PRIMARY KEY,
    asignacion_id INT NOT NULL REFERENCES asignacion_unidad(id) ON DELETE CASCADE,

    -- Ubicación actual
    km_actual DECIMAL(6,2) NOT NULL,
    sentido_actual VARCHAR(30) CHECK (sentido_actual IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE')),
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),

    -- Novedades
    novedad TEXT, -- "Sin novedad" | "Tráfico lento" | "Regulando en km X" | etc.

    -- Metadata
    reportado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE reporte_horario IS 'Reportes horarios de posición de unidades (para COP y secuencia de radio)';

CREATE INDEX idx_reporte_asignacion ON reporte_horario(asignacion_id);
CREATE INDEX idx_reporte_created ON reporte_horario(created_at DESC);

-- ========================================
-- MODIFICAR TABLA INCIDENTE
-- ========================================

-- Agregar relación con asignación (opcional, para trazabilidad)
ALTER TABLE incidente
ADD COLUMN asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE SET NULL;

CREATE INDEX idx_incidente_asignacion ON incidente(asignacion_id);

COMMENT ON COLUMN incidente.asignacion_id IS 'Asignación de la unidad que atendió (si aplica)';

-- ========================================
-- MODIFICAR TABLA ACTIVIDAD_UNIDAD
-- ========================================

-- Agregar relación con asignación
ALTER TABLE actividad_unidad
ADD COLUMN asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE SET NULL;

CREATE INDEX idx_actividad_asignacion ON actividad_unidad(asignacion_id);

COMMENT ON COLUMN actividad_unidad.asignacion_id IS 'Asignación durante la cual se realizó esta actividad';

-- ========================================
-- VISTAS
-- ========================================

-- Vista: Turnos con asignaciones completas
CREATE OR REPLACE VIEW v_turnos_completos AS
SELECT
    t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,

    -- Asignación
    a.id AS asignacion_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
    a.combustible_inicial,
    a.combustible_asignado,
    a.hora_salida,
    a.hora_entrada_estimada,

    -- Tripulación (JSON array)
    (
        SELECT json_agg(
            json_build_object(
                'usuario_id', usr.id,
                'nombre', usr.nombre_completo,
                'rol', tc.rol_tripulacion,
                'presente', tc.presente
            )
            ORDER BY
                CASE tc.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM tripulacion_turno tc
        JOIN usuario usr ON tc.usuario_id = usr.id
        WHERE tc.asignacion_id = a.id
    ) AS tripulacion,

    -- Último reporte horario
    (
        SELECT json_build_object(
            'km', rh.km_actual,
            'sentido', rh.sentido_actual,
            'novedad', rh.novedad,
            'hora', rh.created_at
        )
        FROM reporte_horario rh
        WHERE rh.asignacion_id = a.id
        ORDER BY rh.created_at DESC
        LIMIT 1
    ) AS ultimo_reporte,

    t.created_at

FROM turno t
JOIN asignacion_unidad a ON t.id = a.turno_id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
ORDER BY t.fecha DESC, u.codigo;

COMMENT ON VIEW v_turnos_completos IS 'Vista completa de turnos con asignaciones y tripulaciones';

-- Vista: Mi asignación del día (para app móvil)
CREATE OR REPLACE VIEW v_mi_asignacion_hoy AS
SELECT
    usr.id AS usuario_id,
    usr.nombre_completo,

    -- Turno
    t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,

    -- Asignación
    a.id AS asignacion_id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,

    -- Mi rol
    tc.rol_tripulacion AS mi_rol,

    -- Zona asignada
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,

    -- Horario
    a.hora_salida,
    a.hora_entrada_estimada,

    -- Compañeros de tripulación
    (
        SELECT json_agg(
            json_build_object(
                'nombre', u2.nombre_completo,
                'rol', tc2.rol_tripulacion
            )
            ORDER BY
                CASE tc2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM tripulacion_turno tc2
        JOIN usuario u2 ON tc2.usuario_id = u2.id
        WHERE tc2.asignacion_id = a.id
          AND tc2.usuario_id != usr.id
    ) AS companeros

FROM usuario usr
JOIN tripulacion_turno tc ON usr.id = tc.usuario_id
JOIN asignacion_unidad a ON tc.asignacion_id = a.id
JOIN turno t ON a.turno_id = t.id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
WHERE t.fecha = CURRENT_DATE
  AND t.estado IN ('PLANIFICADO', 'ACTIVO');

COMMENT ON VIEW v_mi_asignacion_hoy IS 'Asignación del día para un usuario (usado en app móvil)';

-- ========================================
-- FUNCIONES
-- ========================================

-- Función: Activar turno automáticamente al inicio del día
CREATE OR REPLACE FUNCTION activar_turno_del_dia()
RETURNS void AS $$
BEGIN
    UPDATE turno
    SET estado = 'ACTIVO'
    WHERE fecha = CURRENT_DATE
      AND estado = 'PLANIFICADO';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION activar_turno_del_dia IS 'Activa el turno del día actual. Ejecutar con cron a las 00:01';

-- Función: Cerrar turno automáticamente
CREATE OR REPLACE FUNCTION cerrar_turno()
RETURNS void AS $$
BEGIN
    UPDATE turno
    SET estado = 'CERRADO'
    WHERE fecha < CURRENT_DATE
      AND estado = 'ACTIVO';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cerrar_turno IS 'Cierra turnos de días anteriores. Ejecutar con cron a las 23:59';

-- Función: Calcular kilometraje recorrido
CREATE OR REPLACE FUNCTION calcular_km_recorridos()
RETURNS TRIGGER AS $$
DECLARE
    km_inicial DECIMAL(6,2);
    km_minimo DECIMAL(6,2);
    km_maximo DECIMAL(6,2);
BEGIN
    -- Obtener km inicial de la asignación
    SELECT a.km_inicio INTO km_inicial
    FROM asignacion_unidad a
    WHERE a.id = NEW.asignacion_id;

    -- Calcular km recorridos basado en reportes horarios
    SELECT
        MIN(rh.km_actual),
        MAX(rh.km_actual)
    INTO km_minimo, km_maximo
    FROM reporte_horario rh
    WHERE rh.asignacion_id = NEW.asignacion_id;

    -- Actualizar km recorridos en la asignación
    UPDATE asignacion_unidad
    SET km_recorridos = COALESCE(ABS(km_maximo - km_minimo), 0)
    WHERE id = NEW.asignacion_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calcular_km_recorridos
    AFTER INSERT ON reporte_horario
    FOR EACH ROW
    EXECUTE FUNCTION calcular_km_recorridos();

COMMENT ON FUNCTION calcular_km_recorridos IS 'Calcula automáticamente los km recorridos al agregar reporte horario';
-- Migración 011: Datos de ejemplo para sistema de turnos

-- NOTA: Este archivo es OPCIONAL, solo para desarrollo/testing

-- ========================================
-- TURNO DE HOY
-- ========================================

INSERT INTO turno (fecha, estado, observaciones, creado_por) VALUES
(CURRENT_DATE, 'ACTIVO', 'Turno normal, prestar atención a trabajos en CA-9 km 45',
    (SELECT id FROM usuario WHERE username = 'operaciones01'));

-- ========================================
-- ASIGNACIONES DE UNIDADES
-- ========================================

-- Asignación 1: PROV-001 (moto) - CA-9 Norte
INSERT INTO asignacion_unidad (
    turno_id, unidad_id, ruta_id, km_inicio, km_final, sentido,
    acciones, combustible_inicial, combustible_asignado,
    hora_salida, hora_entrada_estimada
) VALUES (
    (SELECT id FROM turno WHERE fecha = CURRENT_DATE),
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM ruta WHERE codigo = 'CA-9'),
    10, 50, 'NORTE',
    'Patrullaje rutinario. Regular tránsito en km 30 si es necesario.',
    8.5, 10.0,
    '07:00', '15:00'
);

-- Tripulación para PROV-001
INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-001') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    'PILOTO',
    TRUE
);

-- Asignación 2: PROV-003 (pickup) - CA-1 Occidente
INSERT INTO asignacion_unidad (
    turno_id, unidad_id, ruta_id, km_inicio, km_final, sentido,
    acciones, combustible_inicial, combustible_asignado,
    hora_salida, hora_entrada_estimada
) VALUES (
    (SELECT id FROM turno WHERE fecha = CURRENT_DATE),
    (SELECT id FROM unidad WHERE codigo = 'PROV-003'),
    (SELECT id FROM ruta WHERE codigo = 'CA-1'),
    60, 100, 'OESTE',
    'Patrullaje. Apoyo a trabajos de mantenimiento en km 78.',
    15.2, 20.0,
    '06:30', '14:30'
);

-- Tripulación para PROV-003 (pickup con 2 personas)
INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-003') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    (SELECT id FROM usuario WHERE username = 'brigada02'),
    'PILOTO',
    TRUE
),
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-003') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    (SELECT id FROM usuario WHERE username = 'cop01'), -- COP puede salir como acompañante en casos especiales
    'ACOMPAÑANTE',
    TRUE
);

-- Asignación 3: PROV-002 (moto) - CA-9 Sur
INSERT INTO asignacion_unidad (
    turno_id, unidad_id, ruta_id, km_inicio, km_final, sentido,
    acciones, combustible_inicial, combustible_asignado,
    hora_salida, hora_entrada_estimada
) VALUES (
    (SELECT id FROM turno WHERE fecha = CURRENT_DATE),
    (SELECT id FROM unidad WHERE codigo = 'PROV-002'),
    (SELECT id FROM ruta WHERE codigo = 'CA-9'),
    50, 90, 'SUR',
    'Patrullaje de retorno. Verificar puente en km 65.',
    7.8, 10.0,
    '07:00', '15:00'
);

-- Tripulación para PROV-002
INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-002') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    (SELECT id FROM usuario WHERE username = 'cop02'), -- COP también puede ser piloto
    'PILOTO',
    TRUE
);

-- ========================================
-- REPORTES HORARIOS DE EJEMPLO
-- ========================================

-- Reporte de PROV-001 a las 08:00
INSERT INTO reporte_horario (asignacion_id, km_actual, sentido_actual, novedad, reportado_por, created_at) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-001') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    25.3,
    'NORTE',
    'Sin novedad, tránsito fluido',
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    NOW() - INTERVAL '2 hours'
);

-- Reporte de PROV-001 a las 09:00
INSERT INTO reporte_horario (asignacion_id, km_actual, sentido_actual, novedad, reportado_por, created_at) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-001') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    35.7,
    'NORTE',
    'Tráfico lento por trabajos en km 36',
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    NOW() - INTERVAL '1 hour'
);

-- Reporte de PROV-003 a las 08:00
INSERT INTO reporte_horario (asignacion_id, km_actual, sentido_actual, novedad, reportado_por, created_at) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-003') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    72.1,
    'OESTE',
    'Sin novedad',
    (SELECT id FROM usuario WHERE username = 'brigada02'),
    NOW() - INTERVAL '2 hours'
);

-- ========================================
-- TURNO DE MAÑANA (PLANIFICADO)
-- ========================================

INSERT INTO turno (fecha, estado, observaciones, creado_por) VALUES
(CURRENT_DATE + INTERVAL '1 day', 'PLANIFICADO', 'Turno del día siguiente',
    (SELECT id FROM usuario WHERE username = 'operaciones01'));

-- Asignación para mañana: PROV-001
INSERT INTO asignacion_unidad (
    turno_id, unidad_id, ruta_id, km_inicio, km_final, sentido,
    acciones, combustible_inicial, combustible_asignado,
    hora_salida, hora_entrada_estimada
) VALUES (
    (SELECT id FROM turno WHERE fecha = CURRENT_DATE + INTERVAL '1 day'),
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM ruta WHERE codigo = 'CA-2'),
    0, 40, 'SUR',
    'Patrullaje Carretera del Pacífico',
    9.0, 12.0,
    '06:00', '14:00'
);

-- Tripulación para mañana
INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-001') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE + INTERVAL '1 day')),
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    'PILOTO'
);

-- ========================================
-- VERIFICACIÓN
-- ========================================

-- Ver turnos creados
-- SELECT * FROM v_turnos_completos ORDER BY fecha DESC;

-- Ver mi asignación de hoy (simulando que soy brigada01)
-- SELECT * FROM v_mi_asignacion_hoy WHERE usuario_id = (SELECT id FROM usuario WHERE username = 'brigada01');

COMMENT ON SCHEMA public IS 'Datos de ejemplo de turnos cargados. Ver v_turnos_completos para verificar.';
-- Migración 012: Insertar incidentes de demostración
-- Fecha: 2025-01-26

-- ========================================
-- INCIDENTES DE DEMOSTRACIÓN
-- ========================================

-- Incidente 1: Accidente de tránsito en CA-9 (Reportado)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    subtipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'BRIGADA',
    'REPORTADO',
    1, -- Accidente de tránsito
    1, -- Colisión
    1, -- CA-9
    28.5,
    'NORTE',
    'Frente a gasolinera Shell, km 28.5',
    14.6407,
    -90.5133,
    1, -- UMV-001
    1, -- Brigada 1
    NOW() - INTERVAL '15 minutes',
    TRUE,
    2,
    FALSE,
    0,
    FALSE,
    TRUE,
    TRUE,
    'Colisión entre pickup y automóvil. 2 personas heridas, trasladadas en ambulancia. Tráfico lento en carril izquierdo.',
    3, -- Usuario brigada01
    'INC-2025-0001'
);

-- Incidente 2: Vehículo averiado en CA-1 (En Atención)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    fecha_hora_llegada,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'BRIGADA',
    'EN_ATENCION',
    2, -- Vehículo averiado
    2, -- CA-1
    45.0,
    'OESTE',
    'A la altura del km 45, cerca de Chimaltenango',
    14.6621,
    -90.8192,
    2, -- UMV-002
    2, -- Brigada 2
    NOW() - INTERVAL '45 minutes',
    NOW() - INTERVAL '30 minutes',
    FALSE,
    0,
    FALSE,
    0,
    FALSE,
    FALSE,
    FALSE,
    'Bus extraurbano con falla mecánica. Grúa en camino. Pasajeros evacuados a orilla de carretera.',
    4, -- Usuario brigada02
    'INC-2025-0002'
);

-- Incidente 3: Accidente con heridos graves en CA-9 Sur (Regulación)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    subtipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    fecha_hora_llegada,
    fecha_hora_estabilizacion,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'BRIGADA',
    'REGULACION',
    1, -- Accidente de tránsito
    1, -- Colisión
    1, -- CA-9
    18.2,
    'SUR',
    'Altura de Villa Nueva, km 18',
    14.5269,
    -90.5877,
    1, -- UMV-001
    1, -- Brigada 1
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '1 hour 45 minutes',
    NOW() - INTERVAL '1 hour 30 minutes',
    TRUE,
    3,
    FALSE,
    0,
    TRUE,
    TRUE,
    TRUE,
    'Colisión múltiple de 4 vehículos. 3 personas heridas graves trasladadas al Roosevelt. Carriles obstruidos, regulando tráfico.',
    3, -- Usuario brigada01
    'INC-2025-0003'
);

-- Incidente 4: Obstrucción vial en CA-9 Norte (Reportado)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'USUARIO_PUBLICO',
    'REPORTADO',
    3, -- Obstrucción vial
    1, -- CA-9
    35.0,
    'NORTE',
    'Km 35, cerca de San José Pinula',
    14.5431,
    -90.4089,
    NULL,
    NULL,
    NOW() - INTERVAL '10 minutes',
    FALSE,
    0,
    FALSE,
    0,
    FALSE,
    FALSE,
    FALSE,
    'Usuario reporta árbol caído obstruyendo carril derecho dirección norte.',
    1, -- Usuario admin (como si fuera del público)
    'INC-2025-0004'
);

-- Incidente 5: Accidente leve en CA-2 (En Atención)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    subtipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    fecha_hora_llegada,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'BRIGADA',
    'EN_ATENCION',
    1, -- Accidente de tránsito
    2, -- Choque lateral
    3, -- CA-2
    15.0,
    'ESTE',
    'Altura de Palín, Escuintla',
    14.4053,
    -90.6993,
    3, -- UMV-003 (pickup)
    3, -- Brigada 3
    NOW() - INTERVAL '25 minutes',
    NOW() - INTERVAL '15 minutes',
    FALSE,
    0,
    FALSE,
    0,
    FALSE,
    TRUE,
    FALSE,
    'Choque lateral entre dos vehículos. Sin heridos. Pilotos intercambiando información. PNC en camino para levantar acta.',
    3, -- Usuario brigada01
    'INC-2025-0005'
);

-- ========================================
-- AGREGAR VEHÍCULOS A INCIDENTES
-- ========================================

-- Vehículos del incidente 1 (INC-2025-0001)
INSERT INTO vehiculo_incidente (
    incidente_id,
    tipo_vehiculo_id,
    placa,
    color,
    modelo,
    estado_piloto,
    nombre_piloto,
    heridos_en_vehiculo,
    danos_estimados
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    1, -- Automóvil
    'P123ABC',
    'Rojo',
    'Corolla 2018',
    'HERIDO',
    'Juan Carlos Pérez',
    1,
    'MODERADO'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    2, -- Pickup
    'C456DEF',
    'Blanco',
    'Ford Ranger 2020',
    'HERIDO',
    'María Elena García',
    1,
    'LEVE'
);

-- Vehículos del incidente 3 (INC-2025-0003)
INSERT INTO vehiculo_incidente (
    incidente_id,
    tipo_vehiculo_id,
    placa,
    color,
    modelo,
    estado_piloto,
    nombre_piloto,
    heridos_en_vehiculo,
    danos_estimados
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    1, -- Automóvil
    'P789GHI',
    'Negro',
    'Civic 2019',
    'HERIDO',
    'Pedro López Morales',
    2,
    'GRAVE'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    2, -- Pickup
    'C111JKL',
    'Azul',
    'Toyota Hilux 2021',
    'HERIDO',
    'Ana Sofía Ramírez',
    1,
    'MODERADO'
);

-- ========================================
-- AGREGAR OBSTRUCCIONES
-- ========================================

INSERT INTO obstruccion_incidente (
    incidente_id,
    descripcion_generada,
    datos_carriles_json
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    'Carril izquierdo parcialmente obstruido. Tráfico lento.',
    '{"norte": {"total_carriles": 2, "carriles_bloqueados": 1, "carriles_libres": 1}, "sur": {"total_carriles": 2, "carriles_bloqueados": 0, "carriles_libres": 2}}'::jsonb
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    'Ambos carriles dirección sur obstruidos. Tráfico desviado.',
    '{"norte": {"total_carriles": 2, "carriles_bloqueados": 0, "carriles_libres": 2}, "sur": {"total_carriles": 2, "carriles_bloqueados": 2, "carriles_libres": 0}}'::jsonb
);

-- ========================================
-- RECURSOS SOLICITADOS
-- ========================================

INSERT INTO recurso_incidente (
    incidente_id,
    tipo_recurso,
    descripcion,
    hora_solicitud,
    hora_llegada,
    observaciones
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    'AMBULANCIA',
    'Ambulancia Bomberos Municipales',
    NOW() - INTERVAL '12 minutes',
    NOW() - INTERVAL '8 minutes',
    'Trasladó 2 heridos al Hospital Roosevelt'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    'PNC',
    'Patrulla PNC Tránsito',
    NOW() - INTERVAL '10 minutes',
    NOW() - INTERVAL '5 minutes',
    'Levantando acta del accidente'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    'BOMBEROS',
    'Bomberos Voluntarios',
    NOW() - INTERVAL '1 hour 50 minutes',
    NOW() - INTERVAL '1 hour 40 minutes',
    'Extrajeron a heridos de vehículos'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    'AMBULANCIA',
    'Ambulancia Cruz Roja',
    NOW() - INTERVAL '1 hour 45 minutes',
    NOW() - INTERVAL '1 hour 35 minutes',
    'Trasladó 3 heridos graves al Roosevelt'
);
-- Migración 013: Actualizar passwords de usuarios de prueba
-- Fecha: 2025-01-26
-- Todos los usuarios tienen password: password123

-- cop01
UPDATE usuario SET password_hash = '$2a$10$wTrRFdjfkF2u6OtcRqwxvu52qYJBg9H4N1N89dE20KvlaSGUGMBr2' WHERE username = 'cop01';

-- cop02
UPDATE usuario SET password_hash = '$2a$10$gQA0ImjjMfDH0T7qQUgYfex8ei2hOUV2yZ9xR.dG7UtBHLq2YzxEC' WHERE username = 'cop02';

-- brigada01
UPDATE usuario SET password_hash = '$2a$10$/8iDhgKIkCMrthv0SmLgqOwPHigb67yUyuAYXZEBJ2mdBd0/ZgNG2' WHERE username = 'brigada01';

-- brigada02
UPDATE usuario SET password_hash = '$2a$10$77dZVt201SnQA4vJA3AJ0.t96Ip/RbIryH7SMX0lnuCcONaFK0.vu' WHERE username = 'brigada02';

-- operaciones01
UPDATE usuario SET password_hash = '$2a$10$xplx6Gu2zp2HbaXi0mZr4OyM/wzVEOWk7irBQQgKbka.NzioLaFom' WHERE username = 'operaciones01';

-- accidentologia01
UPDATE usuario SET password_hash = '$2a$10$SF5LaiASk1yowkMtUBYK5OM7zPgzSBS/UITLxtt6yKgBR4totBmwG' WHERE username = 'accidentologia01';

-- mando01
UPDATE usuario SET password_hash = '$2a$10$Qk3bsa99SfRnpuqR1aAhm.Mi0yb/KKOXbz7tDt5qLHGQeIzRDulrm' WHERE username = 'mando01';

-- admin
UPDATE usuario SET password_hash = '$2a$10$oCaSkpeiMcetbx0jbsD9mOsNmqfUmnkFqCi5rbKI79wUJtAwLm6xa' WHERE username = 'admin';

-- Verificar actualización
SELECT username, nombre, apellido, rol_nombre
FROM v_usuarios_completos
WHERE username IN ('cop01', 'brigada01', 'admin', 'operaciones01')
ORDER BY id;
-- Migración 014: Sistema de situaciones operativas y bitácora

-- ========================================
-- TABLA: SITUACION
-- ========================================

CREATE TABLE situacion (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    numero_situacion VARCHAR(50) UNIQUE,  -- "SIT-2025-0001"

    -- Clasificación
    tipo_situacion VARCHAR(50) NOT NULL CHECK (tipo_situacion IN (
        'SALIDA_SEDE',
        'PATRULLAJE',
        'CAMBIO_RUTA',
        'PARADA_ESTRATEGICA',
        'COMIDA',
        'DESCANSO',
        'INCIDENTE',
        'REGULACION_TRAFICO',
        'ASISTENCIA_VEHICULAR',
        'OTROS'
    )),
    estado VARCHAR(20) DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA', 'CERRADA', 'CANCELADA')),

    -- Asignación
    asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,
    turno_id INT REFERENCES turno(id) ON DELETE CASCADE,

    -- Ubicación
    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km DECIMAL(6,2),
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE', 'AMBOS')),
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    ubicacion_manual BOOLEAN DEFAULT FALSE,  -- True si fue ingresada manualmente (demo)

    -- Datos operativos
    combustible DECIMAL(5,2),  -- Litros
    kilometraje_unidad DECIMAL(8,1),  -- Kilometraje del odómetro

    -- Tripulación confirmada (JSON)
    tripulacion_confirmada JSONB,
    -- Ejemplo: [{ "usuario_id": 1, "nombre": "Juan Pérez", "rol": "PILOTO", "presente": true }]

    -- Observaciones
    descripcion TEXT,  -- Descripción breve de la situación
    observaciones TEXT,  -- Observaciones adicionales

    -- Relación con incidente (si la situación es un incidente)
    incidente_id INT REFERENCES incidente(id) ON DELETE SET NULL,

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    actualizado_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE situacion IS 'Situaciones operativas de unidades (salidas, patrullajes, incidentes, etc.)';
COMMENT ON COLUMN situacion.tipo_situacion IS 'Tipo de situación operativa reportada';
COMMENT ON COLUMN situacion.estado IS 'ACTIVA: en curso | CERRADA: finalizada | CANCELADA: cancelada';
COMMENT ON COLUMN situacion.ubicacion_manual IS 'True si la ubicación fue ingresada manualmente (modo demo)';
COMMENT ON COLUMN situacion.tripulacion_confirmada IS 'Tripulación confirmada al momento de crear la situación (JSON array)';

-- Índices
CREATE INDEX idx_situacion_unidad ON situacion(unidad_id);
CREATE INDEX idx_situacion_turno ON situacion(turno_id);
CREATE INDEX idx_situacion_asignacion ON situacion(asignacion_id);
CREATE INDEX idx_situacion_tipo ON situacion(tipo_situacion);
CREATE INDEX idx_situacion_estado ON situacion(estado);
CREATE INDEX idx_situacion_created ON situacion(created_at DESC);
CREATE INDEX idx_situacion_incidente ON situacion(incidente_id) WHERE incidente_id IS NOT NULL;
CREATE INDEX idx_situacion_ubicacion ON situacion USING GIST (ll_to_earth(latitud, longitud))
    WHERE latitud IS NOT NULL AND longitud IS NOT NULL;

-- Trigger para updated_at
CREATE TRIGGER update_situacion_updated_at
    BEFORE UPDATE ON situacion
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- TABLA: DETALLE_SITUACION
-- ========================================

CREATE TABLE detalle_situacion (
    id BIGSERIAL PRIMARY KEY,
    situacion_id BIGINT NOT NULL REFERENCES situacion(id) ON DELETE CASCADE,

    -- Tipo de detalle
    tipo_detalle VARCHAR(50) NOT NULL CHECK (tipo_detalle IN (
        'VEHICULO',
        'AUTORIDAD',
        'RECURSO',
        'VICTIMA',
        'GRUA',
        'ASEGURADORA',
        'TESTIGO',
        'EVIDENCIA',
        'OBSTRUCCION',
        'OTROS'
    )),

    -- Datos flexibles en JSON
    datos JSONB NOT NULL,

    -- Ejemplos de estructura de datos por tipo:
    /*
    VEHICULO: {
        "placa": "P123ABC",
        "marca": "Toyota",
        "modelo": "Corolla",
        "color": "Rojo",
        "anio": 2020,
        "tarjeta_circulacion": "TC123456",
        "piloto": {
            "nombre": "Juan Pérez",
            "licencia": "A123456",
            "telefono": "12345678",
            "estado": "ILESO"
        },
        "danos": "MODERADO",
        "observaciones": "Daños en la parte frontal"
    }

    AUTORIDAD: {
        "institucion": "PNC",
        "nombre_oficial": "Agente José López",
        "placa_oficial": "PNC-001",
        "hora_llegada": "10:30",
        "hora_salida": "12:00",
        "observaciones": "Levantó acta"
    }

    RECURSO: {
        "tipo": "AMBULANCIA",
        "proveedor": "Bomberos Voluntarios",
        "hora_solicitud": "10:15",
        "hora_llegada": "10:35",
        "observaciones": "Trasladó 2 heridos"
    }

    VICTIMA: {
        "nombre": "María González",
        "edad": 35,
        "genero": "F",
        "condicion": "HERIDO_LEVE",
        "hospital_destino": "Hospital Roosevelt",
        "observaciones": "Golpe en la cabeza"
    }

    GRUA: {
        "empresa": "Grúas Provial",
        "placa_grua": "G123ABC",
        "conductor": "Pedro Ramírez",
        "destino_vehiculo": "Taller Central",
        "hora_llegada": "11:00"
    }

    ASEGURADORA: {
        "nombre": "Seguros G&T",
        "ajustador": "Carlos Méndez",
        "telefono": "12345678",
        "hora_llegada": "11:30",
        "observaciones": "Evaluó daños"
    }
    */

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE detalle_situacion IS 'Detalles específicos de situaciones (vehículos, autoridades, recursos, etc.)';
COMMENT ON COLUMN detalle_situacion.tipo_detalle IS 'Tipo de detalle asociado a la situación';
COMMENT ON COLUMN detalle_situacion.datos IS 'Datos flexibles en JSON según el tipo de detalle';

-- Índices
CREATE INDEX idx_detalle_situacion ON detalle_situacion(situacion_id);
CREATE INDEX idx_detalle_tipo ON detalle_situacion(tipo_detalle);
CREATE INDEX idx_detalle_created ON detalle_situacion(created_at DESC);

-- Trigger para updated_at
CREATE TRIGGER update_detalle_situacion_updated_at
    BEFORE UPDATE ON detalle_situacion
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- VISTA: V_SITUACIONES_COMPLETAS
-- ========================================

CREATE OR REPLACE VIEW v_situaciones_completas AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,

    -- Ubicación
    s.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.ubicacion_manual,

    -- Datos operativos
    s.combustible,
    s.kilometraje_unidad,
    s.descripcion,
    s.observaciones,
    s.tripulacion_confirmada,

    -- Unidad
    s.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,

    -- Turno y asignación
    s.turno_id,
    t.fecha AS turno_fecha,
    s.asignacion_id,

    -- Incidente relacionado
    s.incidente_id,
    i.numero_reporte AS incidente_numero,

    -- Auditoría
    s.creado_por,
    uc.nombre_completo AS creado_por_nombre,
    s.actualizado_por,
    ua.nombre_completo AS actualizado_por_nombre,
    s.created_at,
    s.updated_at,

    -- Detalles agregados (JSON array)
    (
        SELECT json_agg(
            json_build_object(
                'id', d.id,
                'tipo_detalle', d.tipo_detalle,
                'datos', d.datos,
                'created_at', d.created_at
            )
            ORDER BY d.created_at ASC
        )
        FROM detalle_situacion d
        WHERE d.situacion_id = s.id
    ) AS detalles

FROM situacion s
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN turno t ON s.turno_id = t.id
LEFT JOIN incidente i ON s.incidente_id = i.id
LEFT JOIN usuario uc ON s.creado_por = uc.id
LEFT JOIN usuario ua ON s.actualizado_por = ua.id
ORDER BY s.created_at DESC;

COMMENT ON VIEW v_situaciones_completas IS 'Vista completa de situaciones con todos los datos relacionados y detalles';

-- ========================================
-- VISTA: V_ULTIMA_SITUACION_UNIDAD
-- ========================================

CREATE OR REPLACE VIEW v_ultima_situacion_unidad AS
SELECT DISTINCT ON (s.unidad_id)
    s.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.id AS situacion_id,
    s.uuid AS situacion_uuid,
    s.tipo_situacion,
    s.estado,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.descripcion,
    s.created_at AS situacion_fecha,
    s.turno_id,
    t.fecha AS turno_fecha

FROM situacion s
JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN turno t ON s.turno_id = t.id
WHERE s.estado = 'ACTIVA'
ORDER BY s.unidad_id, s.created_at DESC;

COMMENT ON VIEW v_ultima_situacion_unidad IS 'Última situación activa por unidad (para mapa en tiempo real)';

-- ========================================
-- VISTA: V_BITACORA_UNIDAD
-- ========================================

CREATE OR REPLACE VIEW v_bitacora_unidad AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    s.tipo_situacion,
    s.estado,
    s.ruta_codigo,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.descripcion,
    s.observaciones,
    s.created_at AS fecha_hora,
    s.creado_por_nombre AS reportado_por,
    s.turno_fecha,

    -- Duración (si está cerrada)
    CASE
        WHEN s.estado = 'CERRADA' THEN
            EXTRACT(EPOCH FROM (s.updated_at - s.created_at)) / 60  -- minutos
        ELSE NULL
    END AS duracion_minutos,

    -- Tiene detalles
    CASE WHEN s.detalles IS NOT NULL THEN TRUE ELSE FALSE END AS tiene_detalles,

    -- Cantidad de detalles por tipo
    (
        SELECT json_object_agg(tipo_detalle, cantidad)
        FROM (
            SELECT
                d.tipo_detalle,
                COUNT(*) AS cantidad
            FROM detalle_situacion d
            WHERE d.situacion_id = s.id
            GROUP BY d.tipo_detalle
        ) AS detalles_count
    ) AS resumen_detalles

FROM v_situaciones_completas s
JOIN unidad u ON s.unidad_id = u.id
ORDER BY s.unidad_id, s.created_at DESC;

COMMENT ON VIEW v_bitacora_unidad IS 'Bitácora completa de situaciones por unidad (para historial)';

-- ========================================
-- FUNCIONES
-- ========================================

-- Función: Generar número de situación automático
CREATE OR REPLACE FUNCTION generar_numero_situacion()
RETURNS TRIGGER AS $$
DECLARE
    anio INT;
    numero_secuencial INT;
    numero_final VARCHAR(50);
BEGIN
    -- Obtener año actual
    anio := EXTRACT(YEAR FROM NOW());

    -- Obtener el siguiente número secuencial del año
    SELECT COALESCE(MAX(
        CAST(
            SUBSTRING(numero_situacion FROM 'SIT-[0-9]{4}-([0-9]+)')
            AS INT
        )
    ), 0) + 1
    INTO numero_secuencial
    FROM situacion
    WHERE numero_situacion LIKE 'SIT-' || anio || '-%';

    -- Generar número final con padding
    numero_final := 'SIT-' || anio || '-' || LPAD(numero_secuencial::TEXT, 4, '0');

    NEW.numero_situacion := numero_final;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generar_numero_situacion
    BEFORE INSERT ON situacion
    FOR EACH ROW
    WHEN (NEW.numero_situacion IS NULL)
    EXECUTE FUNCTION generar_numero_situacion();

COMMENT ON FUNCTION generar_numero_situacion IS 'Genera automáticamente el número de situación (SIT-YYYY-NNNN)';

-- Función: Cerrar situaciones antiguas automáticamente
CREATE OR REPLACE FUNCTION cerrar_situaciones_antiguas(horas_limite INT DEFAULT 24)
RETURNS INT AS $$
DECLARE
    cantidad_cerradas INT;
BEGIN
    WITH cerradas AS (
        UPDATE situacion
        SET
            estado = 'CERRADA',
            actualizado_por = creado_por,
            updated_at = NOW()
        WHERE estado = 'ACTIVA'
          AND created_at < NOW() - (horas_limite || ' hours')::INTERVAL
        RETURNING id
    )
    SELECT COUNT(*) INTO cantidad_cerradas FROM cerradas;

    RETURN cantidad_cerradas;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cerrar_situaciones_antiguas IS 'Cierra automáticamente situaciones activas de más de X horas (default 24)';

-- ========================================
-- DATOS SEED
-- ========================================

-- (Los datos de ejemplo se agregarán después con las unidades y turnos existentes)
-- Migración 015: Sistema de grupos de brigadas, movimientos y permisos dinámicos

-- ========================================
-- MODIFICAR TABLA USUARIO: Agregar grupos
-- ========================================

ALTER TABLE usuario
ADD COLUMN grupo SMALLINT CHECK (grupo IN (1, 2)),
ADD COLUMN fecha_inicio_ciclo DATE,  -- Fecha en que inició su ciclo actual (para calcular si está de turno)
ADD COLUMN acceso_app_activo BOOLEAN DEFAULT TRUE;  -- Permiso individual de acceso

COMMENT ON COLUMN usuario.grupo IS 'Grupo de trabajo: 1 o 2 (8 días trabajo, 8 días descanso)';
COMMENT ON COLUMN usuario.fecha_inicio_ciclo IS 'Fecha de inicio del ciclo actual (para calcular turnos)';
COMMENT ON COLUMN usuario.acceso_app_activo IS 'Si el usuario tiene acceso activo a la app (controlado por COP)';

-- Índice para búsquedas por grupo
CREATE INDEX idx_usuario_grupo ON usuario(grupo) WHERE grupo IS NOT NULL;
CREATE INDEX idx_usuario_acceso ON usuario(acceso_app_activo);

-- ========================================
-- TABLA: CALENDARIO_GRUPOS
-- ========================================

CREATE TABLE calendario_grupo (
    id SERIAL PRIMARY KEY,
    grupo SMALLINT NOT NULL CHECK (grupo IN (1, 2)),
    fecha DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('TRABAJO', 'DESCANSO')),
    observaciones TEXT,

    -- Auditoría
    creado_por INT REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Un solo estado por grupo por fecha
    UNIQUE(grupo, fecha)
);

COMMENT ON TABLE calendario_grupo IS 'Calendario de trabajo/descanso por grupo de brigadas';
COMMENT ON COLUMN calendario_grupo.estado IS 'TRABAJO: Grupo de turno | DESCANSO: Grupo descansando';

CREATE INDEX idx_calendario_grupo_fecha ON calendario_grupo(grupo, fecha DESC);
CREATE INDEX idx_calendario_grupo_estado ON calendario_grupo(estado, fecha);

-- ========================================
-- TABLA: MOVIMIENTO_BRIGADA
-- ========================================

CREATE TABLE movimiento_brigada (
    id BIGSERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    turno_id INT REFERENCES turno(id) ON DELETE CASCADE,

    -- Origen del movimiento
    origen_asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    origen_unidad_id INT REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Destino del movimiento (puede ser NULL si es retiro o división de fuerza estática)
    destino_asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    destino_unidad_id INT REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Tipo de movimiento
    tipo_movimiento VARCHAR(30) NOT NULL CHECK (tipo_movimiento IN (
        'CAMBIO_UNIDAD',      -- Cambio completo de unidad
        'PRESTAMO',           -- Préstamo temporal a otra unidad
        'DIVISION_FUERZA',    -- División: algunos se quedan en punto fijo
        'RELEVO',             -- Relevo de turno (ej: nocturno reemplaza diurno)
        'RETIRO',             -- Fin de turno y retiro
        'APOYO_TEMPORAL'      -- Apoyo temporal sin cambiar asignación principal
    )),

    -- Ubicación del movimiento
    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km DECIMAL(6,2),
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),

    -- Tiempos
    hora_inicio TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    hora_fin TIMESTAMPTZ,  -- NULL si aún está en ese estado

    -- Información adicional
    motivo TEXT,  -- "Apoyo en accidente", "Compra de comida", "Punto fijo km 43", etc.
    rol_en_destino VARCHAR(30),  -- 'PILOTO', 'COPILOTO', 'ACOMPAÑANTE', 'APOYO'

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE movimiento_brigada IS 'Registro de todos los movimientos de brigadas: cambios, préstamos, divisiones de fuerza';
COMMENT ON COLUMN movimiento_brigada.tipo_movimiento IS 'Tipo de movimiento realizado';
COMMENT ON COLUMN movimiento_brigada.hora_fin IS 'NULL si el movimiento aún está activo';
COMMENT ON COLUMN movimiento_brigada.motivo IS 'Razón del movimiento';

-- Índices
CREATE INDEX idx_movimiento_usuario ON movimiento_brigada(usuario_id);
CREATE INDEX idx_movimiento_turno ON movimiento_brigada(turno_id);
CREATE INDEX idx_movimiento_origen ON movimiento_brigada(origen_asignacion_id);
CREATE INDEX idx_movimiento_destino ON movimiento_brigada(destino_asignacion_id);
CREATE INDEX idx_movimiento_tipo ON movimiento_brigada(tipo_movimiento);
CREATE INDEX idx_movimiento_activo ON movimiento_brigada(hora_fin) WHERE hora_fin IS NULL;
CREATE INDEX idx_movimiento_fecha ON movimiento_brigada(created_at DESC);

-- Trigger para updated_at
CREATE TRIGGER update_movimiento_brigada_updated_at
    BEFORE UPDATE ON movimiento_brigada
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- TABLA: CONTROL_ACCESO_APP
-- ========================================

CREATE TABLE control_acceso_app (
    id SERIAL PRIMARY KEY,

    -- Control puede ser por: usuario individual, grupo, unidad o sede
    usuario_id INT REFERENCES usuario(id) ON DELETE CASCADE,
    grupo SMALLINT CHECK (grupo IN (1, 2)),
    unidad_id INT REFERENCES unidad(id) ON DELETE CASCADE,
    sede_id INT REFERENCES sede(id) ON DELETE CASCADE,

    -- Estado del control
    acceso_permitido BOOLEAN NOT NULL DEFAULT TRUE,
    motivo TEXT,  -- "Grupo en descanso", "Suspensión temporal", etc.

    -- Vigencia
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,  -- NULL si es indefinido

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Validación: debe haber al menos un criterio
    CHECK (
        usuario_id IS NOT NULL OR
        grupo IS NOT NULL OR
        unidad_id IS NOT NULL OR
        sede_id IS NOT NULL
    )
);

COMMENT ON TABLE control_acceso_app IS 'Control de acceso a la app móvil por usuario, grupo, unidad o sede';
COMMENT ON COLUMN control_acceso_app.acceso_permitido IS 'True: tiene acceso | False: bloqueado';
COMMENT ON COLUMN control_acceso_app.fecha_fin IS 'NULL si el control es indefinido';

-- Índices
CREATE INDEX idx_control_acceso_usuario ON control_acceso_app(usuario_id) WHERE usuario_id IS NOT NULL;
CREATE INDEX idx_control_acceso_grupo ON control_acceso_app(grupo) WHERE grupo IS NOT NULL;
CREATE INDEX idx_control_acceso_unidad ON control_acceso_app(unidad_id) WHERE unidad_id IS NOT NULL;
CREATE INDEX idx_control_acceso_sede ON control_acceso_app(sede_id) WHERE sede_id IS NOT NULL;
CREATE INDEX idx_control_acceso_vigencia ON control_acceso_app(fecha_inicio, fecha_fin);

-- Trigger para updated_at
CREATE TRIGGER update_control_acceso_updated_at
    BEFORE UPDATE ON control_acceso_app
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- MODIFICAR TABLA ASIGNACION_UNIDAD: Agregar estado de día
-- ========================================

ALTER TABLE asignacion_unidad
ADD COLUMN dia_cerrado BOOLEAN DEFAULT FALSE,
ADD COLUMN fecha_cierre TIMESTAMPTZ,
ADD COLUMN cerrado_por INT REFERENCES usuario(id) ON DELETE SET NULL;

COMMENT ON COLUMN asignacion_unidad.dia_cerrado IS 'True si el día operativo de esta asignación ya fue cerrado';
COMMENT ON COLUMN asignacion_unidad.fecha_cierre IS 'Timestamp de cuándo se cerró el día';
COMMENT ON COLUMN asignacion_unidad.cerrado_por IS 'Usuario que cerró el día (automático o manual)';

CREATE INDEX idx_asignacion_dia_cerrado ON asignacion_unidad(dia_cerrado, turno_id);

-- ========================================
-- VISTAS
-- ========================================

-- Vista: Estado de grupos HOY
CREATE OR REPLACE VIEW v_estado_grupos_hoy AS
SELECT
    grupo,
    estado,
    CASE WHEN estado = 'TRABAJO' THEN TRUE ELSE FALSE END AS esta_de_turno
FROM calendario_grupo
WHERE fecha = CURRENT_DATE;

COMMENT ON VIEW v_estado_grupos_hoy IS 'Estado actual de cada grupo (TRABAJO o DESCANSO)';

-- Vista: Brigadas activas actualmente
CREATE OR REPLACE VIEW v_brigadas_activas_ahora AS
SELECT DISTINCT
    u.id AS usuario_id,
    u.nombre_completo,
    u.grupo,
    m.turno_id,
    m.destino_asignacion_id AS asignacion_actual,
    m.destino_unidad_id AS unidad_actual,
    un.codigo AS unidad_codigo,
    m.tipo_movimiento,
    m.rol_en_destino,
    m.motivo,
    m.hora_inicio,
    EXTRACT(EPOCH FROM (NOW() - m.hora_inicio)) / 3600 AS horas_en_posicion
FROM movimiento_brigada m
JOIN usuario u ON m.usuario_id = u.id
LEFT JOIN unidad un ON m.destino_unidad_id = un.id
WHERE m.hora_fin IS NULL  -- Movimientos activos
  AND DATE(m.hora_inicio) = CURRENT_DATE
ORDER BY u.nombre_completo;

COMMENT ON VIEW v_brigadas_activas_ahora IS 'Brigadas actualmente en servicio con su ubicación actual';

-- Vista: Historial de movimientos de un brigada
CREATE OR REPLACE VIEW v_historial_movimientos AS
SELECT
    m.id,
    m.usuario_id,
    u.nombre_completo,
    m.turno_id,
    t.fecha AS turno_fecha,
    m.tipo_movimiento,
    -- Origen
    m.origen_unidad_id,
    uo.codigo AS origen_unidad_codigo,
    -- Destino
    m.destino_unidad_id,
    ud.codigo AS destino_unidad_codigo,
    -- Tiempos
    m.hora_inicio,
    m.hora_fin,
    CASE
        WHEN m.hora_fin IS NOT NULL THEN
            EXTRACT(EPOCH FROM (m.hora_fin - m.hora_inicio)) / 3600
        ELSE
            EXTRACT(EPOCH FROM (NOW() - m.hora_inicio)) / 3600
    END AS duracion_horas,
    -- Info adicional
    m.motivo,
    m.rol_en_destino,
    m.created_at
FROM movimiento_brigada m
JOIN usuario u ON m.usuario_id = u.id
LEFT JOIN turno t ON m.turno_id = t.id
LEFT JOIN unidad uo ON m.origen_unidad_id = uo.id
LEFT JOIN unidad ud ON m.destino_unidad_id = ud.id
ORDER BY m.created_at DESC;

COMMENT ON VIEW v_historial_movimientos IS 'Historial completo de movimientos de brigadas';

-- Vista: Composición actual de cada unidad
CREATE OR REPLACE VIEW v_composicion_unidades_ahora AS
SELECT
    un.id AS unidad_id,
    un.codigo AS unidad_codigo,
    json_agg(
        json_build_object(
            'usuario_id', u.id,
            'nombre', u.nombre_completo,
            'rol', m.rol_en_destino,
            'tipo_movimiento', m.tipo_movimiento,
            'desde', m.hora_inicio,
            'motivo', m.motivo
        )
        ORDER BY
            CASE m.rol_en_destino
                WHEN 'PILOTO' THEN 1
                WHEN 'COPILOTO' THEN 2
                WHEN 'ACOMPAÑANTE' THEN 3
                ELSE 4
            END
    ) AS tripulacion_actual,
    COUNT(*) AS total_brigadas
FROM movimiento_brigada m
JOIN usuario u ON m.usuario_id = u.id
JOIN unidad un ON m.destino_unidad_id = un.id
WHERE m.hora_fin IS NULL
  AND DATE(m.hora_inicio) = CURRENT_DATE
GROUP BY un.id, un.codigo
ORDER BY un.codigo;

COMMENT ON VIEW v_composicion_unidades_ahora IS 'Tripulación actual de cada unidad en tiempo real';

-- ========================================
-- FUNCIONES
-- ========================================

-- Función: Verificar si un usuario puede acceder a la app
CREATE OR REPLACE FUNCTION verificar_acceso_app(p_usuario_id INT)
RETURNS TABLE (
    tiene_acceso BOOLEAN,
    motivo_bloqueo TEXT
) AS $$
DECLARE
    v_grupo SMALLINT;
    v_acceso_individual BOOLEAN;
    v_grupo_en_descanso BOOLEAN;
    v_control_activo RECORD;
BEGIN
    -- Obtener datos del usuario
    SELECT grupo, acceso_app_activo
    INTO v_grupo, v_acceso_individual
    FROM usuario
    WHERE id = p_usuario_id;

    -- 1. Verificar acceso individual del usuario
    IF v_acceso_individual = FALSE THEN
        RETURN QUERY SELECT FALSE, 'Acceso individual desactivado';
        RETURN;
    END IF;

    -- 2. Verificar si el grupo está en descanso
    IF v_grupo IS NOT NULL THEN
        SELECT NOT esta_de_turno
        INTO v_grupo_en_descanso
        FROM v_estado_grupos_hoy
        WHERE grupo = v_grupo;

        IF v_grupo_en_descanso THEN
            -- Verificar si hay excepción de acceso para este grupo
            SELECT *
            INTO v_control_activo
            FROM control_acceso_app
            WHERE grupo = v_grupo
              AND acceso_permitido = TRUE
              AND fecha_inicio <= CURRENT_DATE
              AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
            LIMIT 1;

            IF v_control_activo IS NULL THEN
                RETURN QUERY SELECT FALSE, 'Grupo en descanso';
                RETURN;
            END IF;
        END IF;
    END IF;

    -- 3. Verificar controles de acceso específicos
    SELECT *
    INTO v_control_activo
    FROM control_acceso_app
    WHERE usuario_id = p_usuario_id
      AND acceso_permitido = FALSE
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    LIMIT 1;

    IF v_control_activo IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, v_control_activo.motivo;
        RETURN;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION verificar_acceso_app IS 'Verifica si un usuario tiene acceso permitido a la app móvil';

-- Función: Cerrar día operativo automáticamente (ejecutar a las 00:00)
CREATE OR REPLACE FUNCTION cerrar_dia_operativo()
RETURNS TABLE (
    asignaciones_cerradas INT,
    situaciones_migradas INT
) AS $$
DECLARE
    v_asignaciones_cerradas INT := 0;
    v_situaciones_migradas INT := 0;
    v_turno_ayer INT;
    v_turno_hoy INT;
    v_situacion RECORD;
BEGIN
    -- 1. Obtener turnos de ayer y hoy
    SELECT id INTO v_turno_ayer
    FROM turno
    WHERE fecha = CURRENT_DATE - INTERVAL '1 day';

    SELECT id INTO v_turno_hoy
    FROM turno
    WHERE fecha = CURRENT_DATE;

    -- Si no existe turno de hoy, crearlo automáticamente
    IF v_turno_hoy IS NULL THEN
        INSERT INTO turno (fecha, estado, observaciones, creado_por)
        VALUES (
            CURRENT_DATE,
            'ACTIVO',
            'Turno creado automáticamente por cierre de día',
            1  -- Usuario sistema
        )
        RETURNING id INTO v_turno_hoy;
    END IF;

    -- 2. Cerrar todas las asignaciones del día anterior
    UPDATE asignacion_unidad
    SET
        dia_cerrado = TRUE,
        fecha_cierre = NOW(),
        cerrado_por = 1  -- Usuario sistema
    WHERE turno_id = v_turno_ayer
      AND dia_cerrado = FALSE;

    GET DIAGNOSTICS v_asignaciones_cerradas = ROW_COUNT;

    -- 3. Cerrar todos los movimientos activos del día anterior
    UPDATE movimiento_brigada
    SET hora_fin = NOW()
    WHERE turno_id = v_turno_ayer
      AND hora_fin IS NULL;

    -- 4. Migrar situaciones activas al nuevo día
    FOR v_situacion IN
        SELECT *
        FROM situacion
        WHERE turno_id = v_turno_ayer
          AND estado = 'ACTIVA'
    LOOP
        -- Actualizar turno de la situación
        UPDATE situacion
        SET turno_id = v_turno_hoy
        WHERE id = v_situacion.id;

        v_situaciones_migradas := v_situaciones_migradas + 1;
    END LOOP;

    RETURN QUERY SELECT v_asignaciones_cerradas, v_situaciones_migradas;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cerrar_dia_operativo IS 'Cierra el día operativo a las 00:00: cierra asignaciones, movimientos y migra situaciones activas';

-- Función: Generar calendario de grupos automáticamente
CREATE OR REPLACE FUNCTION generar_calendario_grupos(
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
RETURNS INT AS $$
DECLARE
    v_fecha DATE;
    v_dias_transcurridos INT;
    v_estado_grupo1 VARCHAR(20);
    v_estado_grupo2 VARCHAR(20);
    v_registros_creados INT := 0;
BEGIN
    v_fecha := p_fecha_inicio;

    WHILE v_fecha <= p_fecha_fin LOOP
        -- Calcular días desde una fecha base (ej: 1 de enero de 2025)
        v_dias_transcurridos := v_fecha - DATE '2025-01-01';

        -- Ciclo de 16 días: 8 trabajo, 8 descanso
        -- Si días_transcurridos mod 16 está entre 0-7: Grupo 1 trabaja
        -- Si días_transcurridos mod 16 está entre 8-15: Grupo 2 trabaja

        IF MOD(v_dias_transcurridos, 16) < 8 THEN
            v_estado_grupo1 := 'TRABAJO';
            v_estado_grupo2 := 'DESCANSO';
        ELSE
            v_estado_grupo1 := 'DESCANSO';
            v_estado_grupo2 := 'TRABAJO';
        END IF;

        -- Insertar para Grupo 1
        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (1, v_fecha, v_estado_grupo1, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        -- Insertar para Grupo 2
        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (2, v_fecha, v_estado_grupo2, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        v_registros_creados := v_registros_creados + 2;
        v_fecha := v_fecha + INTERVAL '1 day';
    END LOOP;

    RETURN v_registros_creados;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_calendario_grupos IS 'Genera calendario de trabajo/descanso para ambos grupos en un rango de fechas';

-- ========================================
-- DATOS INICIALES
-- ========================================

-- Generar calendario para los próximos 90 días
SELECT generar_calendario_grupos(CURRENT_DATE, CURRENT_DATE + INTERVAL '90 days');
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
-- Migración 017: Ajustes al sistema de grupos y controles lógicos

-- ========================================
-- MODIFICAR TABLA USUARIO: Exentos de grupos
-- ========================================

ALTER TABLE usuario
ADD COLUMN exento_grupos BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN usuario.exento_grupos IS 'True si el usuario está exento del sistema de grupos (admins, jefes)';

-- Actualizar usuarios exentos automáticamente (ADMIN, OPERACIONES, MANDOS)
UPDATE usuario
SET exento_grupos = TRUE
WHERE rol_nombre IN ('ADMIN', 'OPERACIONES', 'MANDOS', 'ACCIDENTOLOGIA');

CREATE INDEX idx_usuario_exento ON usuario(exento_grupos) WHERE exento_grupos = TRUE;

-- ========================================
-- TABLA: REGISTRO_CAMBIOS (Auditoría detallada)
-- ========================================

CREATE TABLE registro_cambio (
    id BIGSERIAL PRIMARY KEY,

    -- Tipo de cambio
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN (
        'CAMBIO_BRIGADA',           -- Cambio de brigada en asignación
        'CAMBIO_UNIDAD',            -- Cambio de unidad
        'REMOCION_ASIGNACION',      -- Remover brigada de asignación
        'SUSPENSION_ACCESO',        -- Suspender acceso a app
        'REACTIVACION_ACCESO',      -- Reactivar acceso
        'CAMBIO_GRUPO',             -- Cambiar de grupo 1 a 2 o viceversa
        'EDICION_SITUACION',        -- Editar situación de día cerrado
        'EDICION_ASIGNACION',       -- Editar asignación de día cerrado
        'OTRO'
    )),

    -- Entidades afectadas
    usuario_afectado_id INT REFERENCES usuario(id) ON DELETE SET NULL,
    asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE SET NULL,
    situacion_id BIGINT REFERENCES situacion(id) ON DELETE SET NULL,
    unidad_id INT REFERENCES unidad(id) ON DELETE SET NULL,

    -- Valores anteriores y nuevos (JSON para flexibilidad)
    valores_anteriores JSONB,
    valores_nuevos JSONB,

    -- Motivo del cambio (OBLIGATORIO)
    motivo TEXT NOT NULL,

    -- Quien autorizó/realizó el cambio
    realizado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    autorizado_por INT REFERENCES usuario(id) ON DELETE SET NULL,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE registro_cambio IS 'Registro de auditoría de todos los cambios realizados en el sistema';
COMMENT ON COLUMN registro_cambio.motivo IS 'Motivo obligatorio para el cambio (ej: "Brigada enfermo", "Unidad con falla mecánica")';
COMMENT ON COLUMN registro_cambio.valores_anteriores IS 'Estado anterior en JSON';
COMMENT ON COLUMN registro_cambio.valores_nuevos IS 'Estado nuevo en JSON';

-- Índices
CREATE INDEX idx_registro_tipo ON registro_cambio(tipo_cambio);
CREATE INDEX idx_registro_usuario ON registro_cambio(usuario_afectado_id);
CREATE INDEX idx_registro_asignacion ON registro_cambio(asignacion_id);
CREATE INDEX idx_registro_fecha ON registro_cambio(created_at DESC);
CREATE INDEX idx_registro_realizado_por ON registro_cambio(realizado_por);

-- ========================================
-- MODIFICAR TABLA ASIGNACION_UNIDAD: Campos de auditoría
-- ========================================

ALTER TABLE asignacion_unidad
ADD COLUMN modificado_despues_cierre BOOLEAN DEFAULT FALSE,
ADD COLUMN motivo_modificacion_cierre TEXT;

COMMENT ON COLUMN asignacion_unidad.modificado_despues_cierre IS 'True si fue modificado después de que el día fue cerrado';
COMMENT ON COLUMN asignacion_unidad.motivo_modificacion_cierre IS 'Motivo de la modificación post-cierre';

-- ========================================
-- MODIFICAR TABLA SITUACION: Campos de auditoría
-- ========================================

ALTER TABLE situacion
ADD COLUMN modificado_despues_cierre BOOLEAN DEFAULT FALSE,
ADD COLUMN motivo_modificacion_cierre TEXT;

COMMENT ON COLUMN situacion.modificado_despues_cierre IS 'True si fue modificado después de cerrar el día';
COMMENT ON COLUMN situacion.motivo_modificacion_cierre IS 'Motivo de la modificación post-cierre';

-- ========================================
-- REMOVER TABLA CONTROL_ACCESO_APP: Simplificar
-- ========================================
-- La lógica se manejará directamente con campos en usuario + verificación de grupos

DROP TABLE IF EXISTS control_acceso_app;

-- ========================================
-- FUNCIONES ACTUALIZADAS
-- ========================================

-- Función: Verificar acceso app (versión mejorada)
DROP FUNCTION IF EXISTS verificar_acceso_app(INT);

CREATE OR REPLACE FUNCTION verificar_acceso_app(p_usuario_id INT)
RETURNS TABLE (
    tiene_acceso BOOLEAN,
    motivo_bloqueo TEXT
) AS $$
DECLARE
    v_usuario RECORD;
    v_grupo_en_descanso BOOLEAN;
    v_tiene_asignacion_activa BOOLEAN;
BEGIN
    -- Obtener datos del usuario
    SELECT
        u.id,
        u.rol_nombre,
        u.grupo,
        u.acceso_app_activo,
        u.exento_grupos,
        u.activo
    INTO v_usuario
    FROM usuario u
    WHERE u.id = p_usuario_id;

    -- Validación: Usuario existe y está activo
    IF v_usuario.id IS NULL OR v_usuario.activo = FALSE THEN
        RETURN QUERY SELECT FALSE, 'Usuario inactivo o no existe';
        RETURN;
    END IF;

    -- 1. Usuarios exentos (ADMIN, OPERACIONES, MANDOS) siempre tienen acceso
    IF v_usuario.exento_grupos = TRUE THEN
        -- Solo verificar acceso individual
        IF v_usuario.acceso_app_activo = FALSE THEN
            RETURN QUERY SELECT FALSE, 'Acceso suspendido administrativamente';
            RETURN;
        END IF;
        RETURN QUERY SELECT TRUE, NULL::TEXT;
        RETURN;
    END IF;

    -- 2. Verificar acceso individual
    IF v_usuario.acceso_app_activo = FALSE THEN
        RETURN QUERY SELECT FALSE, 'Acceso suspendido';
        RETURN;
    END IF;

    -- 3. Verificar si el grupo está en descanso (solo para BRIGADA)
    IF v_usuario.rol_nombre = 'BRIGADA' AND v_usuario.grupo IS NOT NULL THEN
        SELECT NOT esta_de_turno
        INTO v_grupo_en_descanso
        FROM v_estado_grupos_hoy
        WHERE grupo = v_usuario.grupo;

        IF v_grupo_en_descanso THEN
            -- Verificar si tiene asignación activa excepcional
            SELECT EXISTS (
                SELECT 1
                FROM tripulacion_turno tt
                JOIN asignacion_unidad au ON tt.asignacion_id = au.id
                JOIN turno t ON au.turno_id = t.id
                WHERE tt.usuario_id = p_usuario_id
                  AND t.fecha = CURRENT_DATE
                  AND au.dia_cerrado = FALSE
            ) INTO v_tiene_asignacion_activa;

            IF NOT v_tiene_asignacion_activa THEN
                RETURN QUERY SELECT FALSE, 'Grupo en período de descanso';
                RETURN;
            END IF;
        END IF;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION verificar_acceso_app IS 'Verifica acceso a la app: exentos siempre pueden, brigadas dependen de grupo y asignación';

-- Función: Validar antes de suspender acceso
CREATE OR REPLACE FUNCTION validar_suspension_acceso(p_usuario_id INT)
RETURNS TABLE (
    puede_suspender BOOLEAN,
    motivo_rechazo TEXT
) AS $$
DECLARE
    v_tiene_asignacion_activa BOOLEAN;
    v_tiene_movimiento_activo BOOLEAN;
    v_tiene_situacion_activa BOOLEAN;
BEGIN
    -- Verificar asignación activa
    SELECT EXISTS (
        SELECT 1
        FROM tripulacion_turno tt
        JOIN asignacion_unidad au ON tt.asignacion_id = au.id
        JOIN turno t ON au.turno_id = t.id
        WHERE tt.usuario_id = p_usuario_id
          AND t.fecha = CURRENT_DATE
          AND au.dia_cerrado = FALSE
    ) INTO v_tiene_asignacion_activa;

    IF v_tiene_asignacion_activa THEN
        RETURN QUERY SELECT FALSE, 'El usuario tiene una asignación activa. Debe ser removido primero.';
        RETURN;
    END IF;

    -- Verificar movimientos activos
    SELECT EXISTS (
        SELECT 1
        FROM movimiento_brigada
        WHERE usuario_id = p_usuario_id
          AND hora_fin IS NULL
    ) INTO v_tiene_movimiento_activo;

    IF v_tiene_movimiento_activo THEN
        RETURN QUERY SELECT FALSE, 'El usuario tiene movimientos activos. Debe finalizarlos primero.';
        RETURN;
    END IF;

    -- Verificar situaciones activas creadas por él
    SELECT EXISTS (
        SELECT 1
        FROM situacion
        WHERE creado_por = p_usuario_id
          AND estado = 'ACTIVA'
    ) INTO v_tiene_situacion_activa;

    IF v_tiene_situacion_activa THEN
        RETURN QUERY SELECT FALSE, 'El usuario tiene situaciones activas. Deben cerrarse primero.';
        RETURN;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_suspension_acceso IS 'Valida que un usuario pueda tener su acceso suspendido';

-- Función: Validar antes de remover de asignación
CREATE OR REPLACE FUNCTION validar_remocion_asignacion(
    p_usuario_id INT,
    p_asignacion_id INT
)
RETURNS TABLE (
    puede_remover BOOLEAN,
    motivo_rechazo TEXT
) AS $$
DECLARE
    v_tiene_movimiento_activo BOOLEAN;
    v_es_unico_piloto BOOLEAN;
BEGIN
    -- Verificar movimientos activos en esta asignación
    SELECT EXISTS (
        SELECT 1
        FROM movimiento_brigada
        WHERE usuario_id = p_usuario_id
          AND (origen_asignacion_id = p_asignacion_id OR destino_asignacion_id = p_asignacion_id)
          AND hora_fin IS NULL
    ) INTO v_tiene_movimiento_activo;

    IF v_tiene_movimiento_activo THEN
        RETURN QUERY SELECT FALSE, 'El brigada tiene movimientos activos. Debe finalizarlos primero.';
        RETURN;
    END IF;

    -- Verificar si es el único piloto (no se puede remover)
    SELECT EXISTS (
        SELECT 1
        FROM tripulacion_turno tt
        WHERE tt.asignacion_id = p_asignacion_id
          AND tt.usuario_id = p_usuario_id
          AND tt.rol_tripulacion = 'PILOTO'
          AND (
            SELECT COUNT(*)
            FROM tripulacion_turno
            WHERE asignacion_id = p_asignacion_id
              AND rol_tripulacion = 'PILOTO'
              AND presente = TRUE
          ) = 1
    ) INTO v_es_unico_piloto;

    IF v_es_unico_piloto THEN
        RETURN QUERY SELECT FALSE, 'No se puede remover al único piloto de la unidad. Asignar otro piloto primero.';
        RETURN;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_remocion_asignacion IS 'Valida que un brigada pueda ser removido de una asignación';

-- Función: Registrar cambio con auditoría
CREATE OR REPLACE FUNCTION registrar_cambio(
    p_tipo_cambio VARCHAR(50),
    p_usuario_afectado_id INT,
    p_motivo TEXT,
    p_realizado_por INT,
    p_valores_anteriores JSONB DEFAULT NULL,
    p_valores_nuevos JSONB DEFAULT NULL,
    p_asignacion_id INT DEFAULT NULL,
    p_situacion_id BIGINT DEFAULT NULL,
    p_unidad_id INT DEFAULT NULL,
    p_autorizado_por INT DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    v_cambio_id BIGINT;
BEGIN
    INSERT INTO registro_cambio (
        tipo_cambio,
        usuario_afectado_id,
        motivo,
        realizado_por,
        valores_anteriores,
        valores_nuevos,
        asignacion_id,
        situacion_id,
        unidad_id,
        autorizado_por
    ) VALUES (
        p_tipo_cambio,
        p_usuario_afectado_id,
        p_motivo,
        p_realizado_por,
        p_valores_anteriores,
        p_valores_nuevos,
        p_asignacion_id,
        p_situacion_id,
        p_unidad_id,
        p_autorizado_por
    )
    RETURNING id INTO v_cambio_id;

    RETURN v_cambio_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_cambio IS 'Registra un cambio en el sistema con auditoría completa';

-- ========================================
-- TRIGGERS: Validaciones automáticas
-- ========================================

-- Trigger: Validar antes de suspender acceso
CREATE OR REPLACE FUNCTION trigger_validar_suspension_acceso()
RETURNS TRIGGER AS $$
DECLARE
    v_validacion RECORD;
BEGIN
    -- Solo validar si se está desactivando el acceso
    IF OLD.acceso_app_activo = TRUE AND NEW.acceso_app_activo = FALSE THEN
        SELECT *
        INTO v_validacion
        FROM validar_suspension_acceso(NEW.id);

        IF v_validacion.puede_suspender = FALSE THEN
            RAISE EXCEPTION 'No se puede suspender acceso: %', v_validacion.motivo_rechazo;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_usuario_validar_suspension
    BEFORE UPDATE ON usuario
    FOR EACH ROW
    WHEN (OLD.acceso_app_activo IS DISTINCT FROM NEW.acceso_app_activo)
    EXECUTE FUNCTION trigger_validar_suspension_acceso();

COMMENT ON TRIGGER trigger_usuario_validar_suspension ON usuario IS 'Valida que un usuario pueda tener su acceso suspendido';

-- Trigger: Auditar cambios en asignaciones cerradas
CREATE OR REPLACE FUNCTION trigger_auditar_cambio_asignacion_cerrada()
RETURNS TRIGGER AS $$
BEGIN
    -- Si el día está cerrado y se está modificando
    IF OLD.dia_cerrado = TRUE THEN
        NEW.modificado_despues_cierre := TRUE;

        -- Si no se proporciona motivo, rechazar
        IF NEW.motivo_modificacion_cierre IS NULL OR NEW.motivo_modificacion_cierre = '' THEN
            RAISE EXCEPTION 'Se requiere motivo para modificar asignación de día cerrado';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_asignacion_auditar_cierre
    BEFORE UPDATE ON asignacion_unidad
    FOR EACH ROW
    WHEN (OLD.dia_cerrado = TRUE)
    EXECUTE FUNCTION trigger_auditar_cambio_asignacion_cerrada();

-- Trigger: Auditar cambios en situaciones de día cerrado
CREATE OR REPLACE FUNCTION trigger_auditar_cambio_situacion_cerrada()
RETURNS TRIGGER AS $$
DECLARE
    v_asignacion_cerrada BOOLEAN;
BEGIN
    -- Verificar si la asignación está cerrada
    SELECT dia_cerrado
    INTO v_asignacion_cerrada
    FROM asignacion_unidad
    WHERE id = OLD.asignacion_id;

    IF v_asignacion_cerrada = TRUE THEN
        NEW.modificado_despues_cierre := TRUE;

        -- Si no se proporciona motivo, rechazar
        IF NEW.motivo_modificacion_cierre IS NULL OR NEW.motivo_modificacion_cierre = '' THEN
            RAISE EXCEPTION 'Se requiere motivo para modificar situación de día cerrado';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_situacion_auditar_cierre
    BEFORE UPDATE ON situacion
    FOR EACH ROW
    EXECUTE FUNCTION trigger_auditar_cambio_situacion_cerrada();

-- ========================================
-- VISTAS ADICIONALES
-- ========================================

-- Vista: Brigadas con asignaciones activas
CREATE OR REPLACE VIEW v_brigadas_con_asignaciones_activas AS
SELECT
    u.id AS usuario_id,
    u.nombre_completo,
    u.grupo,
    t.id AS turno_id,
    t.fecha AS turno_fecha,
    au.id AS asignacion_id,
    un.codigo AS unidad_codigo,
    tt.rol_tripulacion,
    tt.presente,
    au.dia_cerrado
FROM usuario u
JOIN tripulacion_turno tt ON u.id = tt.usuario_id
JOIN asignacion_unidad au ON tt.asignacion_id = au.id
JOIN turno t ON au.turno_id = t.id
JOIN unidad un ON au.unidad_id = un.id
WHERE t.fecha = CURRENT_DATE
  AND au.dia_cerrado = FALSE
ORDER BY un.codigo, tt.rol_tripulacion;

COMMENT ON VIEW v_brigadas_con_asignaciones_activas IS 'Brigadas que tienen asignaciones activas hoy';

-- Vista: Historial de cambios por usuario
CREATE OR REPLACE VIEW v_historial_cambios_usuario AS
SELECT
    rc.id,
    rc.tipo_cambio,
    rc.usuario_afectado_id,
    u_afectado.nombre_completo AS usuario_afectado,
    rc.motivo,
    rc.valores_anteriores,
    rc.valores_nuevos,
    rc.realizado_por,
    u_realizado.nombre_completo AS realizado_por_nombre,
    rc.autorizado_por,
    u_autorizado.nombre_completo AS autorizado_por_nombre,
    rc.created_at
FROM registro_cambio rc
LEFT JOIN usuario u_afectado ON rc.usuario_afectado_id = u_afectado.id
LEFT JOIN usuario u_realizado ON rc.realizado_por = u_realizado.id
LEFT JOIN usuario u_autorizado ON rc.autorizado_por = u_autorizado.id
ORDER BY rc.created_at DESC;

COMMENT ON VIEW v_historial_cambios_usuario IS 'Historial completo de cambios con información de usuarios';
-- Migración 018: Mejoras al sistema de rutas y combustible

-- ========================================
-- 1. AGREGAR RUTA ACTIVA A ASIGNACION
-- ========================================

-- Agregar campo para rastrear la ruta activa durante el día
ALTER TABLE asignacion_unidad
ADD COLUMN IF NOT EXISTS ruta_activa_id INT REFERENCES ruta(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS hora_ultima_actualizacion_ruta TIMESTAMPTZ;

COMMENT ON COLUMN asignacion_unidad.ruta_activa_id IS 'Ruta actualmente activa para esta asignación (se define en SALIDA_SEDE o CAMBIO_RUTA)';
COMMENT ON COLUMN asignacion_unidad.hora_ultima_actualizacion_ruta IS 'Última vez que se actualizó la ruta activa';

-- Índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_asignacion_ruta_activa ON asignacion_unidad(ruta_activa_id) WHERE ruta_activa_id IS NOT NULL;

-- ========================================
-- 2. MEJORAR CAMPO DE COMBUSTIBLE EN SITUACION
-- ========================================

-- Agregar campo para guardar la fracción como texto
ALTER TABLE situacion
ADD COLUMN IF NOT EXISTS combustible_fraccion VARCHAR(10);

COMMENT ON COLUMN situacion.combustible IS 'Nivel de combustible como decimal (0.0 a 1.0)';
COMMENT ON COLUMN situacion.combustible_fraccion IS 'Fracción de combustible legible (ej: 1/2, 3/4, 7/8, LLENO)';

-- ========================================
-- 3. FUNCIÓN: OBTENER RUTA ACTIVA DE UNA ASIGNACIÓN
-- ========================================

CREATE OR REPLACE FUNCTION obtener_ruta_activa(p_asignacion_id INT)
RETURNS INT AS $$
DECLARE
    v_ruta_activa_id INT;
BEGIN
    -- Obtener la ruta activa de la asignación
    SELECT ruta_activa_id INTO v_ruta_activa_id
    FROM asignacion_unidad
    WHERE id = p_asignacion_id;

    -- Si no hay ruta activa, usar la ruta asignada por defecto
    IF v_ruta_activa_id IS NULL THEN
        SELECT ruta_id INTO v_ruta_activa_id
        FROM asignacion_unidad
        WHERE id = p_asignacion_id;
    END IF;

    RETURN v_ruta_activa_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION obtener_ruta_activa IS 'Obtiene la ruta activa de una asignación, o la ruta por defecto si no hay activa';

-- ========================================
-- 4. FUNCIÓN: ACTUALIZAR RUTA ACTIVA
-- ========================================

CREATE OR REPLACE FUNCTION actualizar_ruta_activa(
    p_asignacion_id INT,
    p_nueva_ruta_id INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE asignacion_unidad
    SET
        ruta_activa_id = p_nueva_ruta_id,
        hora_ultima_actualizacion_ruta = NOW()
    WHERE id = p_asignacion_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION actualizar_ruta_activa IS 'Actualiza la ruta activa de una asignación (se llama en SALIDA_SEDE o CAMBIO_RUTA)';

-- ========================================
-- 5. TRIGGER: ACTUALIZAR RUTA ACTIVA EN SITUACIONES ESPECIALES
-- ========================================

CREATE OR REPLACE FUNCTION trigger_actualizar_ruta_activa()
RETURNS TRIGGER AS $$
BEGIN
    -- Si es SALIDA_SEDE o CAMBIO_RUTA, actualizar la ruta activa
    IF NEW.tipo_situacion IN ('SALIDA_SEDE', 'CAMBIO_RUTA') THEN
        IF NEW.ruta_id IS NOT NULL AND NEW.asignacion_id IS NOT NULL THEN
            PERFORM actualizar_ruta_activa(NEW.asignacion_id, NEW.ruta_id);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_situacion_actualizar_ruta_activa'
    ) THEN
        CREATE TRIGGER trigger_situacion_actualizar_ruta_activa
            AFTER INSERT ON situacion
            FOR EACH ROW
            EXECUTE FUNCTION trigger_actualizar_ruta_activa();
    END IF;
END $$;

COMMENT ON TRIGGER trigger_situacion_actualizar_ruta_activa ON situacion IS 'Actualiza automáticamente la ruta activa cuando se crea SALIDA_SEDE o CAMBIO_RUTA';

-- ========================================
-- 6. VISTA MEJORADA: SITUACIONES CON CONSUMO DE COMBUSTIBLE
-- ========================================

CREATE OR REPLACE VIEW v_situaciones_con_combustible AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    s.combustible,
    s.combustible_fraccion,
    s.kilometraje_unidad,
    s.created_at,

    -- Calcular consumo vs situación anterior
    LAG(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS combustible_anterior,
    s.combustible - LAG(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS consumo,

    -- Calcular km recorridos
    s.kilometraje_unidad - LAG(s.kilometraje_unidad) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS km_recorridos,

    -- Tiempo desde última situación
    EXTRACT(EPOCH FROM (s.created_at - LAG(s.created_at) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at))) / 60 AS minutos_desde_anterior,

    s.turno_id,
    t.fecha AS turno_fecha
FROM situacion s
LEFT JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN turno t ON s.turno_id = t.id
WHERE s.combustible IS NOT NULL
ORDER BY s.unidad_id, s.created_at;

COMMENT ON VIEW v_situaciones_con_combustible IS 'Vista de situaciones con análisis de consumo de combustible y km recorridos';

-- ========================================
-- 7. DATOS INICIALES: COPIAR RUTA ASIGNADA COMO RUTA ACTIVA
-- ========================================

-- Para asignaciones existentes, copiar ruta_id a ruta_activa_id
UPDATE asignacion_unidad
SET ruta_activa_id = ruta_id,
    hora_ultima_actualizacion_ruta = created_at
WHERE ruta_id IS NOT NULL
  AND ruta_activa_id IS NULL;

-- ========================================
-- 8. FUNCIÓN: OBTENER HISTORIAL DE COMBUSTIBLE DE UNA UNIDAD
-- ========================================

CREATE OR REPLACE FUNCTION obtener_historial_combustible(
    p_unidad_id INT,
    p_fecha DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    hora TIMESTAMPTZ,
    tipo_situacion VARCHAR,
    combustible_fraccion VARCHAR,
    combustible_decimal DECIMAL,
    consumo DECIMAL,
    km_recorridos DECIMAL,
    ubicacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.created_at AS hora,
        s.tipo_situacion,
        s.combustible_fraccion,
        s.combustible AS combustible_decimal,
        s.combustible - LAG(s.combustible) OVER (ORDER BY s.created_at) AS consumo,
        s.kilometraje_unidad - LAG(s.kilometraje_unidad) OVER (ORDER BY s.created_at) AS km_recorridos,
        CONCAT(r.codigo, ' Km ', s.km) AS ubicacion
    FROM situacion s
    LEFT JOIN ruta r ON s.ruta_id = r.id
    LEFT JOIN turno t ON s.turno_id = t.id
    WHERE s.unidad_id = p_unidad_id
      AND t.fecha = p_fecha
      AND s.combustible IS NOT NULL
    ORDER BY s.created_at;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION obtener_historial_combustible IS 'Obtiene el historial de combustible de una unidad para un día específico';

-- ========================================
-- FIN DE MIGRACIÓN 018
-- ========================================
-- Migración 019: Sistema de Asignaciones Permanentes y Salidas (Opción B)
-- Rediseño completo: Elimina concepto de turnos diarios, implementa asignaciones permanentes

-- ========================================
-- 1. MODIFICAR TABLA USUARIO - Agregar CHAPA
-- ========================================

-- Agregar columna chapa (identificación única de brigadistas)
ALTER TABLE usuario
ADD COLUMN IF NOT EXISTS chapa VARCHAR(20) UNIQUE;

COMMENT ON COLUMN usuario.chapa IS 'Número de chapa del brigadista (ej: 19109, 15056). Se usa como username.';

-- Para brigadistas existentes, copiar username a chapa si no existe
UPDATE usuario
SET chapa = username
WHERE rol_id = (SELECT id FROM rol WHERE codigo = 'BRIGADA')
  AND chapa IS NULL;

-- ========================================
-- 2. TABLA: BRIGADA_UNIDAD (Asignación Permanente)
-- ========================================

CREATE TABLE IF NOT EXISTS brigada_unidad (
    id SERIAL PRIMARY KEY,

    -- Relaciones
    brigada_id INT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE CASCADE,

    -- Rol en la unidad
    rol_tripulacion VARCHAR(30) NOT NULL
        CHECK (rol_tripulacion IN ('PILOTO', 'COPILOTO', 'ACOMPAÑANTE')),

    -- Vigencia
    fecha_asignacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_fin TIMESTAMPTZ, -- NULL = asignación activa
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    -- Observaciones
    observaciones TEXT,
    asignado_por INT REFERENCES usuario(id) ON DELETE SET NULL,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE brigada_unidad IS 'Asignaciones permanentes de brigadistas a unidades';
COMMENT ON COLUMN brigada_unidad.activo IS 'TRUE = asignación vigente, FALSE = terminada';
COMMENT ON COLUMN brigada_unidad.fecha_fin IS 'Fecha en que finalizó la asignación (por reasignación, baja, etc.)';

CREATE INDEX idx_brigada_unidad_brigada ON brigada_unidad(brigada_id);
CREATE INDEX idx_brigada_unidad_unidad ON brigada_unidad(unidad_id);
CREATE INDEX idx_brigada_unidad_activo ON brigada_unidad(activo) WHERE activo = TRUE;

-- Un brigadista solo puede estar asignado a una unidad activa a la vez
CREATE UNIQUE INDEX idx_brigada_activa_unica
    ON brigada_unidad(brigada_id)
    WHERE activo = TRUE;

COMMENT ON INDEX idx_brigada_activa_unica IS 'Garantiza que un brigadista solo tenga una asignación activa';

-- Trigger para updated_at
CREATE TRIGGER update_brigada_unidad_updated_at
    BEFORE UPDATE ON brigada_unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 3. TABLA: SALIDA_UNIDAD (Reemplaza turnos diarios)
-- ========================================

CREATE TABLE IF NOT EXISTS salida_unidad (
    id SERIAL PRIMARY KEY,

    -- Unidad que sale
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Timing (sin restricción de fecha)
    fecha_hora_salida TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_hora_regreso TIMESTAMPTZ, -- NULL mientras esté en salida

    -- Estado
    estado VARCHAR(30) NOT NULL DEFAULT 'EN_SALIDA'
        CHECK (estado IN ('EN_SALIDA', 'FINALIZADA', 'CANCELADA')),

    -- Datos iniciales
    ruta_inicial_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km_inicial DECIMAL(8,2),
    combustible_inicial DECIMAL(5,2), -- Litros

    -- Datos finales (al regresar)
    km_final DECIMAL(8,2),
    combustible_final DECIMAL(5,2),
    km_recorridos DECIMAL(8,2), -- Calculado: km_final - km_inicial

    -- Tripulación que salió (JSON array de brigadistas)
    -- Formato: [{"brigada_id": 1, "nombre": "Juan", "chapa": "19109", "rol": "PILOTO"}, ...]
    tripulacion JSONB,

    -- Quién finalizó la salida
    finalizada_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    observaciones_salida TEXT,
    observaciones_regreso TEXT,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE salida_unidad IS 'Registro de salidas de unidades. Puede durar horas o días sin límite.';
COMMENT ON COLUMN salida_unidad.estado IS 'EN_SALIDA: activa | FINALIZADA: regresó a sede | CANCELADA: cancelada';
COMMENT ON COLUMN salida_unidad.tripulacion IS 'Brigadistas que salieron en esta salida (snapshot al momento de salir)';
COMMENT ON COLUMN salida_unidad.finalizada_por IS 'Usuario que marcó el regreso (puede ser brigadista, COP, Ops, Admin)';

CREATE INDEX idx_salida_unidad_unidad ON salida_unidad(unidad_id);
CREATE INDEX idx_salida_unidad_estado ON salida_unidad(estado);
CREATE INDEX idx_salida_unidad_fecha ON salida_unidad(fecha_hora_salida DESC);

-- Solo una salida activa por unidad a la vez
CREATE UNIQUE INDEX idx_salida_activa_por_unidad
    ON salida_unidad(unidad_id)
    WHERE estado = 'EN_SALIDA';

COMMENT ON INDEX idx_salida_activa_por_unidad IS 'Garantiza que una unidad solo tenga una salida activa a la vez';

-- Trigger para updated_at
CREATE TRIGGER update_salida_unidad_updated_at
    BEFORE UPDATE ON salida_unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 4. MODIFICAR TABLA SITUACION
-- ========================================

-- Agregar FK a salida_unidad
ALTER TABLE situacion
ADD COLUMN IF NOT EXISTS salida_unidad_id INT REFERENCES salida_unidad(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_situacion_salida ON situacion(salida_unidad_id);

COMMENT ON COLUMN situacion.salida_unidad_id IS 'Salida durante la cual se registró esta situación';

-- ========================================
-- 5. TABLA: RELEVO (Para intercambios de unidades/tripulaciones)
-- ========================================

CREATE TABLE IF NOT EXISTS relevo (
    id SERIAL PRIMARY KEY,

    -- Situación donde se registra el relevo
    situacion_id INT REFERENCES situacion(id) ON DELETE CASCADE,

    -- Tipo de relevo
    tipo_relevo VARCHAR(30) NOT NULL
        CHECK (tipo_relevo IN ('UNIDAD_COMPLETA', 'CRUZADO')),

    -- Unidades involucradas
    unidad_saliente_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,
    unidad_entrante_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Brigadistas que se retiran
    brigadistas_salientes JSONB, -- Array de {brigada_id, chapa, nombre}

    -- Brigadistas que llegan
    brigadistas_entrantes JSONB, -- Array de {brigada_id, chapa, nombre}

    -- Datos adicionales
    fecha_hora TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    observaciones TEXT,

    -- Auditoría
    registrado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE relevo IS 'Registro de relevos entre unidades/tripulaciones';
COMMENT ON COLUMN relevo.tipo_relevo IS 'UNIDAD_COMPLETA: 016 se va, 015 llega | CRUZADO: tripulación 016 se queda con unidad 015';

CREATE INDEX idx_relevo_situacion ON relevo(situacion_id);
CREATE INDEX idx_relevo_unidad_saliente ON relevo(unidad_saliente_id);
CREATE INDEX idx_relevo_unidad_entrante ON relevo(unidad_entrante_id);
CREATE INDEX idx_relevo_fecha ON relevo(fecha_hora DESC);

-- ========================================
-- 6. VISTAS
-- ========================================

-- Vista: Mi unidad asignada (para app móvil)
CREATE OR REPLACE VIEW v_mi_unidad_asignada AS
SELECT
    u.id AS brigada_id,
    u.username,
    u.chapa,
    u.nombre_completo,

    -- Unidad asignada
    bu.id AS asignacion_id,
    bu.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    bu.rol_tripulacion AS mi_rol,

    -- Vigencia
    bu.fecha_asignacion,
    bu.activo,

    -- Compañeros de unidad
    (
        SELECT json_agg(
            json_build_object(
                'brigada_id', u2.id,
                'chapa', u2.chapa,
                'nombre', u2.nombre_completo,
                'rol', bu2.rol_tripulacion
            )
            ORDER BY
                CASE bu2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM brigada_unidad bu2
        JOIN usuario u2 ON bu2.brigada_id = u2.id
        WHERE bu2.unidad_id = bu.unidad_id
          AND bu2.activo = TRUE
          AND bu2.brigada_id != u.id
    ) AS companeros

FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id
JOIN unidad un ON bu.unidad_id = un.id
WHERE bu.activo = TRUE;

COMMENT ON VIEW v_mi_unidad_asignada IS 'Unidad asignada permanentemente a un brigadista';

-- Vista: Salida activa de mi unidad
CREATE OR REPLACE VIEW v_mi_salida_activa AS
SELECT
    u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,

    -- Salida
    s.id AS salida_id,
    s.unidad_id,
    un.codigo AS unidad_codigo,
    s.estado,
    s.fecha_hora_salida,
    s.fecha_hora_regreso,

    -- Duración de la salida
    EXTRACT(EPOCH FROM (COALESCE(s.fecha_hora_regreso, NOW()) - s.fecha_hora_salida)) / 3600 AS horas_salida,

    -- Ruta inicial
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.combustible_inicial,

    -- Tripulación
    s.tripulacion,

    -- Primera situación (debe ser SALIDA_SEDE)
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at ASC
        LIMIT 1
    ) AS primera_situacion

FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id AND bu.activo = TRUE
JOIN unidad un ON bu.unidad_id = un.id
JOIN salida_unidad s ON un.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id;

COMMENT ON VIEW v_mi_salida_activa IS 'Salida activa de la unidad de un brigadista';

-- Vista: Resumen de unidades y sus salidas activas
CREATE OR REPLACE VIEW v_unidades_en_salida AS
SELECT
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,

    -- Salida activa
    s.id AS salida_id,
    s.fecha_hora_salida,
    EXTRACT(EPOCH FROM (NOW() - s.fecha_hora_salida)) / 3600 AS horas_en_salida,

    -- Ruta
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,

    -- Tripulación
    s.tripulacion,

    -- Cantidad de situaciones registradas
    (
        SELECT COUNT(*)
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
    ) AS total_situaciones,

    -- Última situación
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'km', sit.km,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at DESC
        LIMIT 1
    ) AS ultima_situacion

FROM unidad u
JOIN salida_unidad s ON u.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id
ORDER BY s.fecha_hora_salida DESC;

COMMENT ON VIEW v_unidades_en_salida IS 'Todas las unidades que actualmente están en salida';

-- ========================================
-- 7. FUNCIONES
-- ========================================

-- Función: Iniciar salida de unidad
CREATE OR REPLACE FUNCTION iniciar_salida_unidad(
    p_unidad_id INT,
    p_ruta_inicial_id INT DEFAULT NULL,
    p_km_inicial DECIMAL DEFAULT NULL,
    p_combustible_inicial DECIMAL DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    v_salida_id INT;
    v_tripulacion JSONB;
    v_salida_existente INT;
BEGIN
    -- Verificar que no haya salida activa
    SELECT id INTO v_salida_existente
    FROM salida_unidad
    WHERE unidad_id = p_unidad_id
      AND estado = 'EN_SALIDA';

    IF v_salida_existente IS NOT NULL THEN
        RAISE EXCEPTION 'La unidad ya tiene una salida activa (ID: %)', v_salida_existente;
    END IF;

    -- Obtener tripulación actual de la unidad
    SELECT json_agg(
        json_build_object(
            'brigada_id', u.id,
            'chapa', u.chapa,
            'nombre', u.nombre_completo,
            'rol', bu.rol_tripulacion
        )
        ORDER BY
            CASE bu.rol_tripulacion
                WHEN 'PILOTO' THEN 1
                WHEN 'COPILOTO' THEN 2
                WHEN 'ACOMPAÑANTE' THEN 3
            END
    )
    INTO v_tripulacion
    FROM brigada_unidad bu
    JOIN usuario u ON bu.brigada_id = u.id
    WHERE bu.unidad_id = p_unidad_id
      AND bu.activo = TRUE;

    -- Crear salida
    INSERT INTO salida_unidad (
        unidad_id,
        ruta_inicial_id,
        km_inicial,
        combustible_inicial,
        tripulacion,
        observaciones_salida,
        estado
    )
    VALUES (
        p_unidad_id,
        p_ruta_inicial_id,
        p_km_inicial,
        p_combustible_inicial,
        v_tripulacion,
        p_observaciones,
        'EN_SALIDA'
    )
    RETURNING id INTO v_salida_id;

    RETURN v_salida_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION iniciar_salida_unidad IS 'Inicia una nueva salida para una unidad. Crea snapshot de tripulación actual.';

-- Función: Finalizar salida de unidad
CREATE OR REPLACE FUNCTION finalizar_salida_unidad(
    p_salida_id INT,
    p_km_final DECIMAL DEFAULT NULL,
    p_combustible_final DECIMAL DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_finalizada_por INT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_km_inicial DECIMAL;
    v_km_recorridos DECIMAL;
BEGIN
    -- Obtener km inicial
    SELECT km_inicial INTO v_km_inicial
    FROM salida_unidad
    WHERE id = p_salida_id;

    -- Calcular km recorridos
    IF p_km_final IS NOT NULL AND v_km_inicial IS NOT NULL THEN
        v_km_recorridos := ABS(p_km_final - v_km_inicial);
    END IF;

    -- Finalizar salida
    UPDATE salida_unidad
    SET estado = 'FINALIZADA',
        fecha_hora_regreso = NOW(),
        km_final = p_km_final,
        combustible_final = p_combustible_final,
        km_recorridos = v_km_recorridos,
        observaciones_regreso = p_observaciones,
        finalizada_por = p_finalizada_por
    WHERE id = p_salida_id
      AND estado = 'EN_SALIDA';

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION finalizar_salida_unidad IS 'Finaliza una salida activa. Calcula km recorridos automáticamente.';

-- Función: Verificar que primera situación sea SALIDA_SEDE
CREATE OR REPLACE FUNCTION verificar_primera_situacion_es_salida()
RETURNS TRIGGER AS $$
DECLARE
    v_count_situaciones INT;
BEGIN
    -- Contar situaciones existentes de esta salida
    SELECT COUNT(*)
    INTO v_count_situaciones
    FROM situacion
    WHERE salida_unidad_id = NEW.salida_unidad_id;

    -- Si es la primera situación y NO es SALIDA_SEDE, rechazar
    IF v_count_situaciones = 0 AND NEW.tipo_situacion != 'SALIDA_SEDE' THEN
        RAISE EXCEPTION 'La primera situación de una salida DEBE ser SALIDA_SEDE. Tipo recibido: %', NEW.tipo_situacion;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_primera_situacion
    BEFORE INSERT ON situacion
    FOR EACH ROW
    WHEN (NEW.salida_unidad_id IS NOT NULL)
    EXECUTE FUNCTION verificar_primera_situacion_es_salida();

COMMENT ON FUNCTION verificar_primera_situacion_es_salida IS 'Fuerza que la primera situación de una salida sea SALIDA_SEDE';

-- ========================================
-- 8. DATOS DE EJEMPLO (OPCIONAL - COMENTADO)
-- ========================================

/*
-- Asignar brigada01 a unidad PROV-001 como PILOTO
INSERT INTO brigada_unidad (brigada_id, unidad_id, rol_tripulacion, asignado_por)
SELECT
    u.id,
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    'PILOTO',
    u.id
FROM usuario u
WHERE u.username = 'brigada01';

-- Iniciar salida de PROV-001
SELECT iniciar_salida_unidad(
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM ruta WHERE codigo = 'CA-1'),
    0.0,
    30.0,
    'Salida de prueba'
);
*/
-- Migración 020: Sistema de Sedes e Ingresos Múltiples
-- Implementa: sedes, jurisdicción, ingresos múltiples durante salida, finalización de día laboral

-- ========================================
-- 1. TABLA: SEDE
-- ========================================

CREATE TABLE IF NOT EXISTS sede (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,

    -- Ubicación
    departamento_id INT REFERENCES departamento(id) ON DELETE RESTRICT,
    municipio_id INT REFERENCES municipio(id) ON DELETE RESTRICT,
    direccion TEXT,
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),

    -- Contacto
    telefono VARCHAR(50),
    email VARCHAR(100),

    -- Estado
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    es_sede_central BOOLEAN NOT NULL DEFAULT FALSE,

    -- Metadata
    observaciones TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE sede IS 'Sedes de PROVIAL distribuidas por el país';
COMMENT ON COLUMN sede.es_sede_central IS 'TRUE si es la sede central (Guatemala)';
COMMENT ON COLUMN sede.activa IS 'FALSE si la sede fue cerrada o está inactiva';

CREATE INDEX idx_sede_codigo ON sede(codigo);
CREATE INDEX idx_sede_activa ON sede(activa) WHERE activa = TRUE;

-- Solo una sede central
CREATE UNIQUE INDEX idx_una_sede_central
    ON sede(es_sede_central)
    WHERE es_sede_central = TRUE;

-- Trigger para updated_at
CREATE TRIGGER update_sede_updated_at
    BEFORE UPDATE ON sede
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 2. MODIFICAR TABLAS EXISTENTES - Agregar sede_id
-- ========================================

-- Usuario pertenece a una sede
ALTER TABLE usuario
ADD COLUMN IF NOT EXISTS sede_id INT REFERENCES sede(id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_usuario_sede ON usuario(sede_id);

COMMENT ON COLUMN usuario.sede_id IS 'Sede a la que pertenece el usuario. NULL = acceso a todas (COP)';

-- Unidad pertenece a una sede
ALTER TABLE unidad
ADD COLUMN IF NOT EXISTS sede_id INT REFERENCES unidad(id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_unidad_sede ON unidad(sede_id);

COMMENT ON COLUMN unidad.sede_id IS 'Sede base de la unidad';

-- ========================================
-- 3. TABLA: REASIGNACION_SEDE
-- ========================================

CREATE TABLE IF NOT EXISTS reasignacion_sede (
    id SERIAL PRIMARY KEY,

    -- Puede ser usuario o unidad
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('USUARIO', 'UNIDAD')),
    recurso_id INT NOT NULL, -- ID del usuario o unidad

    -- Reasignación
    sede_origen_id INT NOT NULL REFERENCES sede(id) ON DELETE RESTRICT,
    sede_destino_id INT NOT NULL REFERENCES sede(id) ON DELETE RESTRICT,

    -- Temporalidad
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE, -- NULL = permanente
    es_permanente BOOLEAN NOT NULL DEFAULT FALSE,

    -- Motivo
    motivo TEXT,
    -- Ejemplo: "Apoyo en reparación de puente", "Cobertura de carrera de ciclismo"

    -- Estado
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVA'
        CHECK (estado IN ('ACTIVA', 'FINALIZADA', 'CANCELADA')),

    -- Auditoría
    autorizado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE reasignacion_sede IS 'Reasignaciones temporales o permanentes de personal/unidades entre sedes';
COMMENT ON COLUMN reasignacion_sede.tipo IS 'USUARIO: brigadista | UNIDAD: vehículo';
COMMENT ON COLUMN reasignacion_sede.recurso_id IS 'ID del usuario o unidad reasignado';

CREATE INDEX idx_reasignacion_tipo_recurso ON reasignacion_sede(tipo, recurso_id);
CREATE INDEX idx_reasignacion_estado ON reasignacion_sede(estado);
CREATE INDEX idx_reasignacion_fechas ON reasignacion_sede(fecha_inicio, fecha_fin);

-- Trigger para updated_at
CREATE TRIGGER update_reasignacion_sede_updated_at
    BEFORE UPDATE ON reasignacion_sede
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 4. TABLA: INGRESO_SEDE
-- ========================================

CREATE TABLE IF NOT EXISTS ingreso_sede (
    id SERIAL PRIMARY KEY,

    -- Salida a la que pertenece este ingreso
    salida_unidad_id INT NOT NULL REFERENCES salida_unidad(id) ON DELETE CASCADE,

    -- Sede a la que ingresa
    sede_id INT NOT NULL REFERENCES sede(id) ON DELETE RESTRICT,

    -- Timing
    fecha_hora_ingreso TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_hora_salida TIMESTAMPTZ, -- NULL mientras esté ingresado

    -- Tipo de ingreso
    tipo_ingreso VARCHAR(30) NOT NULL
        CHECK (tipo_ingreso IN ('COMBUSTIBLE', 'COMISION', 'APOYO', 'ALMUERZO', 'MANTENIMIENTO', 'FINALIZACION')),

    -- Datos del ingreso
    km_ingreso DECIMAL(8,2),
    combustible_ingreso DECIMAL(5,2),

    -- Datos de salida (si vuelve a salir)
    km_salida_nueva DECIMAL(8,2),
    combustible_salida_nueva DECIMAL(5,2),

    -- Observaciones
    observaciones_ingreso TEXT,
    observaciones_salida TEXT,

    -- Es el ingreso final? (finalización del día laboral)
    es_ingreso_final BOOLEAN NOT NULL DEFAULT FALSE,

    -- Auditoría
    registrado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE ingreso_sede IS 'Ingresos de unidades a sedes durante una salida. Puede haber múltiples ingresos por salida.';
COMMENT ON COLUMN ingreso_sede.tipo_ingreso IS 'Motivo del ingreso a sede';
COMMENT ON COLUMN ingreso_sede.es_ingreso_final IS 'TRUE si es el ingreso que finaliza la jornada laboral';
COMMENT ON COLUMN ingreso_sede.fecha_hora_salida IS 'NULL si todavía está ingresado, timestamp si volvió a salir';

CREATE INDEX idx_ingreso_salida ON ingreso_sede(salida_unidad_id);
CREATE INDEX idx_ingreso_sede_sede ON ingreso_sede(sede_id);
CREATE INDEX idx_ingreso_fecha ON ingreso_sede(fecha_hora_ingreso DESC);

-- Solo un ingreso activo (sin fecha_hora_salida) por salida
CREATE UNIQUE INDEX idx_ingreso_activo_por_salida
    ON ingreso_sede(salida_unidad_id)
    WHERE fecha_hora_salida IS NULL;

COMMENT ON INDEX idx_ingreso_activo_por_salida IS 'Garantiza que una salida solo tenga un ingreso activo a la vez';

-- Trigger para updated_at
CREATE TRIGGER update_ingreso_sede_updated_at
    BEFORE UPDATE ON ingreso_sede
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 5. MODIFICAR TABLA SALIDA_UNIDAD
-- ========================================

-- Agregar sede de origen (de donde salió)
ALTER TABLE salida_unidad
ADD COLUMN IF NOT EXISTS sede_origen_id INT REFERENCES sede(id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_salida_sede_origen ON salida_unidad(sede_origen_id);

COMMENT ON COLUMN salida_unidad.sede_origen_id IS 'Sede desde donde salió la unidad';

-- ========================================
-- 6. VISTAS ACTUALIZADAS
-- ========================================

-- Vista: Mi unidad asignada (CON SEDE)
DROP VIEW IF EXISTS v_mi_unidad_asignada;
CREATE VIEW v_mi_unidad_asignada AS
SELECT
    u.id AS brigada_id,
    u.username,
    u.chapa,
    u.nombre_completo,

    -- Sede del brigadista
    u.sede_id AS mi_sede_id,
    s.codigo AS mi_sede_codigo,
    s.nombre AS mi_sede_nombre,

    -- Unidad asignada
    bu.id AS asignacion_id,
    bu.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    bu.rol_tripulacion AS mi_rol,

    -- Sede de la unidad
    un.sede_id AS unidad_sede_id,
    su.codigo AS unidad_sede_codigo,
    su.nombre AS unidad_sede_nombre,

    -- Vigencia
    bu.fecha_asignacion,
    bu.activo,

    -- Compañeros de unidad
    (
        SELECT json_agg(
            json_build_object(
                'brigada_id', u2.id,
                'chapa', u2.chapa,
                'nombre', u2.nombre_completo,
                'rol', bu2.rol_tripulacion
            )
            ORDER BY
                CASE bu2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM brigada_unidad bu2
        JOIN usuario u2 ON bu2.brigada_id = u2.id
        WHERE bu2.unidad_id = bu.unidad_id
          AND bu2.activo = TRUE
          AND bu2.brigada_id != u.id
    ) AS companeros

FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id
JOIN unidad un ON bu.unidad_id = un.id
LEFT JOIN sede s ON u.sede_id = s.id
LEFT JOIN sede su ON un.sede_id = su.id
WHERE bu.activo = TRUE;

-- Vista: Salida activa CON ingresos
DROP VIEW IF EXISTS v_mi_salida_activa;
CREATE VIEW v_mi_salida_activa AS
SELECT
    u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,

    -- Salida
    sal.id AS salida_id,
    sal.unidad_id,
    un.codigo AS unidad_codigo,
    sal.estado,
    sal.fecha_hora_salida,
    sal.fecha_hora_regreso,

    -- Sede origen
    sal.sede_origen_id,
    so.codigo AS sede_origen_codigo,
    so.nombre AS sede_origen_nombre,

    -- Duración
    EXTRACT(EPOCH FROM (COALESCE(sal.fecha_hora_regreso, NOW()) - sal.fecha_hora_salida)) / 3600 AS horas_salida,

    -- Ruta inicial
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    sal.km_inicial,
    sal.combustible_inicial,

    -- Tripulación
    sal.tripulacion,

    -- Ingreso activo (si está ingresado en alguna sede)
    (
        SELECT json_build_object(
            'id', i.id,
            'sede_id', i.sede_id,
            'sede_codigo', se.codigo,
            'sede_nombre', se.nombre,
            'tipo', i.tipo_ingreso,
            'fecha_hora_ingreso', i.fecha_hora_ingreso,
            'km_ingreso', i.km_ingreso,
            'es_ingreso_final', i.es_ingreso_final
        )
        FROM ingreso_sede i
        JOIN sede se ON i.sede_id = se.id
        WHERE i.salida_unidad_id = sal.id
          AND i.fecha_hora_salida IS NULL
        LIMIT 1
    ) AS ingreso_activo,

    -- Cantidad de ingresos realizados
    (
        SELECT COUNT(*)
        FROM ingreso_sede i
        WHERE i.salida_unidad_id = sal.id
    ) AS total_ingresos,

    -- Primera situación
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = sal.id
        ORDER BY sit.created_at ASC
        LIMIT 1
    ) AS primera_situacion

FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id AND bu.activo = TRUE
JOIN unidad un ON bu.unidad_id = un.id
JOIN salida_unidad sal ON un.id = sal.unidad_id AND sal.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON sal.ruta_inicial_id = r.id
LEFT JOIN sede so ON sal.sede_origen_id = so.id;

-- Vista: Unidades en salida CON sedes
DROP VIEW IF EXISTS v_unidades_en_salida;
CREATE VIEW v_unidades_en_salida AS
SELECT
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,

    -- Sede de la unidad
    u.sede_id,
    s.codigo AS sede_codigo,
    s.nombre AS sede_nombre,

    -- Salida activa
    sal.id AS salida_id,
    sal.fecha_hora_salida,
    EXTRACT(EPOCH FROM (NOW() - sal.fecha_hora_salida)) / 3600 AS horas_en_salida,

    -- Sede origen de la salida
    sal.sede_origen_id,
    so.codigo AS sede_origen_codigo,

    -- Ruta
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    sal.km_inicial,

    -- Tripulación
    sal.tripulacion,

    -- ¿Está ingresada en alguna sede?
    EXISTS (
        SELECT 1 FROM ingreso_sede i
        WHERE i.salida_unidad_id = sal.id
          AND i.fecha_hora_salida IS NULL
    ) AS esta_ingresada,

    -- Cantidad de situaciones
    (
        SELECT COUNT(*)
        FROM situacion sit
        WHERE sit.salida_unidad_id = sal.id
    ) AS total_situaciones,

    -- Última situación
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'km', sit.km,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = sal.id
        ORDER BY sit.created_at DESC
        LIMIT 1
    ) AS ultima_situacion

FROM unidad u
JOIN salida_unidad sal ON u.id = sal.unidad_id AND sal.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON sal.ruta_inicial_id = r.id
LEFT JOIN sede s ON u.sede_id = s.id
LEFT JOIN sede so ON sal.sede_origen_id = so.id
ORDER BY sal.fecha_hora_salida DESC;

-- ========================================
-- 7. FUNCIONES
-- ========================================

-- Función: Obtener sede efectiva de usuario (considerando reasignaciones)
CREATE OR REPLACE FUNCTION obtener_sede_efectiva_usuario(p_usuario_id INT)
RETURNS INT AS $$
DECLARE
    v_sede_id INT;
BEGIN
    -- Buscar reasignación activa
    SELECT sede_destino_id INTO v_sede_id
    FROM reasignacion_sede
    WHERE tipo = 'USUARIO'
      AND recurso_id = p_usuario_id
      AND estado = 'ACTIVA'
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    ORDER BY created_at DESC
    LIMIT 1;

    -- Si no hay reasignación, usar sede original
    IF v_sede_id IS NULL THEN
        SELECT sede_id INTO v_sede_id
        FROM usuario
        WHERE id = p_usuario_id;
    END IF;

    RETURN v_sede_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION obtener_sede_efectiva_usuario IS 'Retorna la sede efectiva del usuario considerando reasignaciones temporales';

-- Función: Obtener sede efectiva de unidad
CREATE OR REPLACE FUNCTION obtener_sede_efectiva_unidad(p_unidad_id INT)
RETURNS INT AS $$
DECLARE
    v_sede_id INT;
BEGIN
    -- Buscar reasignación activa
    SELECT sede_destino_id INTO v_sede_id
    FROM reasignacion_sede
    WHERE tipo = 'UNIDAD'
      AND recurso_id = p_unidad_id
      AND estado = 'ACTIVA'
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    ORDER BY created_at DESC
    LIMIT 1;

    -- Si no hay reasignación, usar sede original
    IF v_sede_id IS NULL THEN
        SELECT sede_id INTO v_sede_id
        FROM unidad
        WHERE id = p_unidad_id;
    END IF;

    RETURN v_sede_id;
END;
$$ LANGUAGE plpgsql;

-- Función: Verificar si usuario tiene permiso sobre sede
CREATE OR REPLACE FUNCTION tiene_permiso_sede(
    p_usuario_id INT,
    p_sede_id INT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_rol VARCHAR(50);
    v_sede_usuario INT;
BEGIN
    -- Obtener rol del usuario
    SELECT r.nombre INTO v_rol
    FROM usuario u
    JOIN rol r ON u.rol_id = r.id
    WHERE u.id = p_usuario_id;

    -- COP tiene acceso a TODAS las sedes
    IF v_rol = 'COP' THEN
        RETURN TRUE;
    END IF;

    -- Otros roles solo tienen acceso a su sede
    v_sede_usuario := obtener_sede_efectiva_usuario(p_usuario_id);

    RETURN v_sede_usuario = p_sede_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION tiene_permiso_sede IS 'Verifica si un usuario tiene permiso para operar en una sede. COP tiene acceso universal.';

-- Función: Registrar ingreso a sede
CREATE OR REPLACE FUNCTION registrar_ingreso_sede(
    p_salida_id INT,
    p_sede_id INT,
    p_tipo_ingreso VARCHAR,
    p_km_ingreso DECIMAL DEFAULT NULL,
    p_combustible_ingreso DECIMAL DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_es_ingreso_final BOOLEAN DEFAULT FALSE,
    p_registrado_por INT DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    v_ingreso_id INT;
    v_ingreso_existente INT;
BEGIN
    -- Verificar que no haya ingreso activo
    SELECT id INTO v_ingreso_existente
    FROM ingreso_sede
    WHERE salida_unidad_id = p_salida_id
      AND fecha_hora_salida IS NULL;

    IF v_ingreso_existente IS NOT NULL THEN
        RAISE EXCEPTION 'Ya existe un ingreso activo para esta salida (ID: %)', v_ingreso_existente;
    END IF;

    -- Crear ingreso
    INSERT INTO ingreso_sede (
        salida_unidad_id,
        sede_id,
        tipo_ingreso,
        km_ingreso,
        combustible_ingreso,
        observaciones_ingreso,
        es_ingreso_final,
        registrado_por
    )
    VALUES (
        p_salida_id,
        p_sede_id,
        p_tipo_ingreso,
        p_km_ingreso,
        p_combustible_ingreso,
        p_observaciones,
        p_es_ingreso_final,
        p_registrado_por
    )
    RETURNING id INTO v_ingreso_id;

    -- Si es ingreso final, marcar salida como FINALIZADA
    IF p_es_ingreso_final THEN
        UPDATE salida_unidad
        SET estado = 'FINALIZADA',
            fecha_hora_regreso = NOW(),
            km_final = p_km_ingreso,
            combustible_final = p_combustible_ingreso
        WHERE id = p_salida_id;
    END IF;

    RETURN v_ingreso_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_ingreso_sede IS 'Registra ingreso de unidad a sede. Si es_ingreso_final=TRUE, finaliza la salida.';

-- Función: Registrar salida de sede (volver a la calle)
CREATE OR REPLACE FUNCTION registrar_salida_de_sede(
    p_ingreso_id INT,
    p_km_salida DECIMAL DEFAULT NULL,
    p_combustible_salida DECIMAL DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE ingreso_sede
    SET fecha_hora_salida = NOW(),
        km_salida_nueva = p_km_salida,
        combustible_salida_nueva = p_combustible_salida,
        observaciones_salida = p_observaciones
    WHERE id = p_ingreso_id
      AND fecha_hora_salida IS NULL
      AND es_ingreso_final = FALSE; -- No se puede salir de un ingreso final

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_salida_de_sede IS 'Marca que la unidad volvió a salir después de un ingreso temporal';

-- ========================================
-- 8. DATOS INICIALES - SEDES
-- ========================================

-- Insertar sedes principales de Guatemala
INSERT INTO sede (codigo, nombre, es_sede_central, activa, observaciones)
VALUES
    ('CENTRAL', 'Sede Central Guatemala', TRUE, TRUE, 'Oficinas centrales de PROVIAL'),
    ('SANCRISTO', 'Sede San Cristóbal', FALSE, TRUE, 'Sede regional San Cristóbal')
ON CONFLICT (codigo) DO NOTHING;

-- Actualizar unidades existentes con sede central por defecto
UPDATE unidad
SET sede_id = (SELECT id FROM sede WHERE codigo = 'CENTRAL')
WHERE sede_id IS NULL;

-- Actualizar usuarios existentes con sede central por defecto
UPDATE usuario
SET sede_id = (SELECT id FROM sede WHERE codigo = 'CENTRAL')
WHERE sede_id IS NULL
  AND rol_id != (SELECT id FROM rol WHERE nombre = 'COP'); -- COP no tiene sede específica

-- Actualizar salidas existentes con sede origen
UPDATE salida_unidad
SET sede_origen_id = (SELECT id FROM sede WHERE codigo = 'CENTRAL')
WHERE sede_origen_id IS NULL;
-- Migración 021: Sistema de Gestión Manual de Grupos
-- Fecha: 2025-11-30
-- Autor: Antigravity

-- 1. Limpiar calendario futuro (eliminar generación automática)
DELETE FROM calendario_grupo WHERE fecha > CURRENT_DATE;

-- 2. Actualizar función verificar_acceso_app
-- Lógica: Asignación Activa > Calendario Manual > Default (Abierto)
CREATE OR REPLACE FUNCTION verificar_acceso_app(p_usuario_id INT)
RETURNS TABLE (
  tiene_acceso BOOLEAN,
  motivo_bloqueo TEXT
) AS $$
DECLARE
  v_usuario RECORD;
  v_calendario RECORD;
  v_tiene_asignacion BOOLEAN;
BEGIN
  -- Obtener información del usuario
  SELECT * INTO v_usuario
  FROM usuario
  WHERE id = p_usuario_id;

  -- Si el usuario no existe
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, 'Usuario no encontrado';
    RETURN;
  END IF;

  -- Si el usuario no está activo
  IF NOT v_usuario.activo THEN
    RETURN QUERY SELECT FALSE, 'Usuario inactivo';
    RETURN;
  END IF;

  -- Si tiene suspensión individual
  IF NOT v_usuario.acceso_app_activo THEN
    RETURN QUERY SELECT FALSE, 'Acceso suspendido individualmente';
    RETURN;
  END IF;

  -- PRIORIDAD 1: Verificar si tiene asignación activa a una unidad
  -- Si tiene asignación, SIEMPRE tiene acceso (ignora calendario)
  SELECT EXISTS(
    SELECT 1 FROM brigada_unidad
    WHERE brigada_id = p_usuario_id
      AND activo = TRUE
  ) INTO v_tiene_asignacion;

  IF v_tiene_asignacion THEN
    RETURN QUERY SELECT TRUE, NULL::TEXT;
    RETURN;
  END IF;

  -- Si está exento de grupos, tiene acceso
  IF v_usuario.exento_grupos THEN
    RETURN QUERY SELECT TRUE, NULL::TEXT;
    RETURN;
  END IF;

  -- Si no tiene grupo asignado, tiene acceso
  IF v_usuario.grupo IS NULL THEN
    RETURN QUERY SELECT TRUE, NULL::TEXT;
    RETURN;
  END IF;

  -- PRIORIDAD 2: Verificar calendario del grupo
  SELECT * INTO v_calendario
  FROM calendario_grupo
  WHERE grupo = v_usuario.grupo
    AND fecha = CURRENT_DATE;

  -- Si no hay entrada en calendario, tiene acceso (Default: Abierto)
  IF NOT FOUND THEN
    RETURN QUERY SELECT TRUE, NULL::TEXT;
    RETURN;
  END IF;

  -- Si el grupo está de DESCANSO, bloquear
  IF v_calendario.estado = 'DESCANSO' THEN
    RETURN QUERY SELECT FALSE, 'Tu grupo está de descanso hoy';
    RETURN;
  END IF;

  -- Si llegamos aquí (estado TRABAJO), tiene acceso
  RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

-- 3. Crear vista para dashboard de estado de grupos
CREATE OR REPLACE VIEW v_estado_grupos_detallado AS
SELECT
  g.grupo,
  g.fecha,
  g.estado,
  COUNT(DISTINCT u.id) as total_brigadas,
  COUNT(DISTINCT CASE WHEN bu.id IS NOT NULL THEN u.id END) as brigadas_con_asignacion,
  json_agg(
    DISTINCT jsonb_build_object(
      'brigada_id', u.id,
      'nombre', u.nombre_completo,
      'unidad_id', un.id,
      'unidad_codigo', un.codigo
    )
  ) FILTER (WHERE bu.id IS NOT NULL) as brigadas_asignadas
FROM calendario_grupo g
LEFT JOIN usuario u ON u.grupo = g.grupo AND u.activo = TRUE
LEFT JOIN brigada_unidad bu ON bu.brigada_id = u.id AND bu.activo = TRUE
LEFT JOIN unidad un ON un.id = bu.unidad_id
WHERE g.fecha >= CURRENT_DATE
GROUP BY g.grupo, g.fecha, g.estado
ORDER BY g.fecha, g.grupo;
-- Migration: 022_incident_overhaul
-- Description: Overhaul incident schema to support detailed reporting (PROVIALSinExcel logic)

-- 1. Update 'incidente' table
ALTER TABLE incidente
ADD COLUMN IF NOT EXISTS jurisdiccion VARCHAR(255),
ADD COLUMN IF NOT EXISTS direccion_detallada TEXT, -- For obstruction direction text
ADD COLUMN IF NOT EXISTS obstruccion_detalle JSONB, -- { sentidos: [...], carriles: [...] }
ADD COLUMN IF NOT EXISTS danios_infraestructura_desc TEXT,
ADD COLUMN IF NOT EXISTS danios_materiales BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS danios_infraestructura BOOLEAN DEFAULT FALSE;

-- 2. Update 'vehiculo_incidente' table (Corrected table name)
ALTER TABLE vehiculo_incidente
ADD COLUMN IF NOT EXISTS color VARCHAR(100),
ADD COLUMN IF NOT EXISTS modelo VARCHAR(50),
ADD COLUMN IF NOT EXISTS marca VARCHAR(100),
ADD COLUMN IF NOT EXISTS tarjeta_circulacion VARCHAR(100),
ADD COLUMN IF NOT EXISTS nit VARCHAR(50),
ADD COLUMN IF NOT EXISTS direccion_propietario TEXT,
ADD COLUMN IF NOT EXISTS nombre_propietario VARCHAR(255),
ADD COLUMN IF NOT EXISTS nombre_piloto VARCHAR(255),
ADD COLUMN IF NOT EXISTS licencia_tipo VARCHAR(50),
ADD COLUMN IF NOT EXISTS licencia_numero VARCHAR(50),
ADD COLUMN IF NOT EXISTS licencia_vencimiento DATE,
ADD COLUMN IF NOT EXISTS licencia_antiguedad INTEGER,
ADD COLUMN IF NOT EXISTS piloto_nacimiento DATE,
ADD COLUMN IF NOT EXISTS piloto_etnia VARCHAR(50),
ADD COLUMN IF NOT EXISTS piloto_edad INTEGER,
ADD COLUMN IF NOT EXISTS piloto_sexo VARCHAR(20),
ADD COLUMN IF NOT EXISTS cargado BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS carga_tipo VARCHAR(255),
ADD COLUMN IF NOT EXISTS carga_detalle JSONB, -- For future extensibility
ADD COLUMN IF NOT EXISTS contenedor BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS doble_remolque BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS contenedor_detalle JSONB, -- { tc, placa, empresa, ejes, etc. }
ADD COLUMN IF NOT EXISTS bus_extraurbano BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS bus_detalle JSONB, -- { licencia_ops, seguro, ruta, etc. }
ADD COLUMN IF NOT EXISTS sancion BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS sancion_detalle JSONB, -- { articulo, motivo, boleta, impuesto_por }
ADD COLUMN IF NOT EXISTS personas_asistidas INTEGER DEFAULT 0;

-- 3. Create 'persona_involucrada' table (For Pilots, Passengers, Pedestrians)
CREATE TABLE IF NOT EXISTS persona_involucrada (
    id SERIAL PRIMARY KEY,
    incidente_id INTEGER REFERENCES incidente(id) ON DELETE CASCADE,
    vehiculo_id INTEGER REFERENCES vehiculo_incidente(id) ON DELETE SET NULL, -- Null if pedestrian
    tipo VARCHAR(50) NOT NULL, -- PILOTO, COPILOTO, PASAJERO, PEATON
    nombre VARCHAR(255),
    genero VARCHAR(20),
    edad INTEGER,
    estado VARCHAR(50), -- ILESO, HERIDO, FALLECIDO, CRISIS_NERVIOSA
    trasladado BOOLEAN DEFAULT FALSE,
    lugar_traslado VARCHAR(255), -- Hospital name, Morgue, etc.
    consignado BOOLEAN DEFAULT FALSE,
    lugar_consignacion VARCHAR(255), -- Police station, Court, etc.
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. Create 'grua_involucrada' table
CREATE TABLE IF NOT EXISTS grua_involucrada (
    id SERIAL PRIMARY KEY,
    incidente_id INTEGER REFERENCES incidente(id) ON DELETE CASCADE,
    vehiculo_asignado_id INTEGER REFERENCES vehiculo_incidente(id) ON DELETE SET NULL, -- Linked to a specific vehicle
    tipo VARCHAR(100), -- Plataforma, Pluma, etc.
    placa VARCHAR(20),
    empresa VARCHAR(255),
    piloto VARCHAR(255),
    color VARCHAR(100),
    marca VARCHAR(100),
    traslado BOOLEAN DEFAULT FALSE,
    traslado_a VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 5. Create 'ajustador_involucrado' table
CREATE TABLE IF NOT EXISTS ajustador_involucrado (
    id SERIAL PRIMARY KEY,
    incidente_id INTEGER REFERENCES incidente(id) ON DELETE CASCADE,
    vehiculo_asignado_id INTEGER REFERENCES vehiculo_incidente(id) ON DELETE SET NULL,
    nombre VARCHAR(255),
    empresa VARCHAR(255),
    vehiculo_tipo VARCHAR(100),
    vehiculo_placa VARCHAR(20),
    vehiculo_color VARCHAR(100),
    vehiculo_marca VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 6. Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_persona_incidente ON persona_involucrada(incidente_id);
CREATE INDEX IF NOT EXISTS idx_grua_incidente ON grua_involucrada(incidente_id);
CREATE INDEX IF NOT EXISTS idx_ajustador_incidente ON ajustador_involucrado(incidente_id);
-- Migration: 023_update_view
-- Description: Recreate v_incidentes_completos to include new columns

DROP VIEW IF EXISTS v_incidentes_completos;

CREATE VIEW v_incidentes_completos AS
SELECT 
    i.*,
    th.nombre as tipo_hecho,
    th.color as tipo_hecho_color,
    th.icono as tipo_hecho_icono,
    sth.nombre as subtipo_hecho,
    r.codigo as ruta_codigo,
    r.nombre as ruta_nombre,
    u.codigo as unidad_codigo,
    b.nombre_completo as brigada_nombre,
    c.nombre_completo as creado_por_nombre
FROM incidente i
JOIN tipo_hecho th ON i.tipo_hecho_id = th.id
LEFT JOIN subtipo_hecho sth ON i.subtipo_hecho_id = sth.id
JOIN ruta r ON i.ruta_id = r.id
LEFT JOIN unidad u ON i.unidad_id = u.id
LEFT JOIN usuario b ON i.brigada_id = b.id -- Corrected: b.id instead of b.usuario_id
JOIN usuario c ON i.creado_por = c.id; -- Corrected: c.id instead of c.usuario_id
-- ========================================
-- Migración 024: Normalización de Datos de Incidentes
-- ========================================
-- Objetivo: Eliminar duplicación de datos creando tablas maestras
-- para vehículos, pilotos, grúas, aseguradoras y relacionarlas con incidentes

-- ========================================
-- 1. TABLA MAESTRA: VEHICULO
-- ========================================

CREATE TABLE IF NOT EXISTS vehiculo (
    id SERIAL PRIMARY KEY,

    -- Identificación
    placa VARCHAR(20) UNIQUE NOT NULL, -- Ampliado para soportar placas extranjeras y formatos especiales
    es_extranjero BOOLEAN DEFAULT FALSE,

    -- Características básicas
    tipo_vehiculo_id INTEGER REFERENCES tipo_vehiculo(id) ON DELETE SET NULL,
    color VARCHAR(100),
    marca_id INTEGER REFERENCES marca_vehiculo(id) ON DELETE SET NULL,

    -- Carga (datos generales)
    cargado BOOLEAN DEFAULT FALSE,
    tipo_carga VARCHAR(100),

    -- Estadísticas calculadas (se actualizan con triggers)
    total_incidentes INTEGER DEFAULT 0,
    primer_incidente TIMESTAMPTZ,
    ultimo_incidente TIMESTAMPTZ,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vehiculo_master_placa ON vehiculo(placa);
CREATE INDEX IF NOT EXISTS idx_vehiculo_master_tipo ON vehiculo(tipo_vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_vehiculo_master_marca ON vehiculo(marca_id);

COMMENT ON TABLE vehiculo IS 'Tabla maestra de vehículos. Un registro por placa única.';
COMMENT ON COLUMN vehiculo.placa IS 'Placa del vehículo (formato Guatemala: L###LLL)';
COMMENT ON COLUMN vehiculo.es_extranjero IS 'TRUE si es placa extranjera (sin validación de formato)';
COMMENT ON COLUMN vehiculo.total_incidentes IS 'Contador de incidentes (actualizado por trigger)';

-- ========================================
-- 2. TABLA: TARJETA_CIRCULACION
-- ========================================

CREATE TABLE IF NOT EXISTS tarjeta_circulacion (
    id SERIAL PRIMARY KEY,

    -- Relación con vehículo
    vehiculo_id INTEGER NOT NULL REFERENCES vehiculo(id) ON DELETE CASCADE,

    -- Datos de la TC
    numero BIGINT NOT NULL,
    nit BIGINT,
    direccion_propietario TEXT,
    nombre_propietario VARCHAR(255),
    modelo INTEGER, -- Año del modelo

    -- Fecha de registro de esta TC
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tc_vehiculo ON tarjeta_circulacion(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_tc_numero ON tarjeta_circulacion(numero);
CREATE INDEX IF NOT EXISTS idx_tc_nit ON tarjeta_circulacion(nit);

COMMENT ON TABLE tarjeta_circulacion IS 'Datos de tarjetas de circulación vinculadas a vehículos';
COMMENT ON COLUMN tarjeta_circulacion.numero IS 'Número de tarjeta de circulación';
COMMENT ON COLUMN tarjeta_circulacion.nit IS 'NIT del propietario';

-- ========================================
-- 3. TABLA MAESTRA: PILOTO
-- ========================================

CREATE TABLE IF NOT EXISTS piloto (
    id SERIAL PRIMARY KEY,

    -- Identificación
    nombre VARCHAR(255) NOT NULL,

    -- Licencia
    licencia_tipo VARCHAR(1) CHECK (licencia_tipo IN ('A','B','C','M','E')),
    licencia_numero BIGINT UNIQUE NOT NULL,
    licencia_vencimiento DATE,
    licencia_antiguedad INTEGER, -- Años de experiencia

    -- Datos personales
    fecha_nacimiento DATE,
    etnia VARCHAR(50),

    -- Estadísticas calculadas
    total_incidentes INTEGER DEFAULT 0,
    total_sanciones INTEGER DEFAULT 0,
    primer_incidente TIMESTAMPTZ,
    ultimo_incidente TIMESTAMPTZ,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_piloto_licencia ON piloto(licencia_numero);
CREATE INDEX IF NOT EXISTS idx_piloto_nombre ON piloto(nombre);

COMMENT ON TABLE piloto IS 'Tabla maestra de pilotos. Un registro por licencia única.';
COMMENT ON COLUMN piloto.licencia_tipo IS 'Tipo de licencia: A=Moto, B=Liviano, C=Pesado, M=Maquinaria, E=Especial';
COMMENT ON COLUMN piloto.total_incidentes IS 'Contador de incidentes (actualizado por trigger)';
COMMENT ON COLUMN piloto.total_sanciones IS 'Contador de sanciones (actualizado por trigger)';

-- ========================================
-- 4. TABLA: CONTENEDOR
-- ========================================

CREATE TABLE IF NOT EXISTS contenedor (
    id SERIAL PRIMARY KEY,

    -- Relación con vehículo
    vehiculo_id INTEGER NOT NULL REFERENCES vehiculo(id) ON DELETE CASCADE,

    -- Datos del contenedor
    numero_contenedor VARCHAR(50),
    linea_naviera VARCHAR(100),
    tipo_contenedor VARCHAR(50), -- Ej: 20', 40', refrigerado

    -- Fecha de registro
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contenedor_vehiculo ON contenedor(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_contenedor_numero ON contenedor(numero_contenedor);

COMMENT ON TABLE contenedor IS 'Datos de contenedores/remolques vinculados a vehículos';

-- ========================================
-- 5. TABLA: BUS
-- ========================================

CREATE TABLE IF NOT EXISTS bus (
    id SERIAL PRIMARY KEY,

    -- Relación con vehículo
    vehiculo_id INTEGER NOT NULL REFERENCES vehiculo(id) ON DELETE CASCADE,

    -- Datos del bus
    empresa VARCHAR(255),
    ruta_bus VARCHAR(100), -- Ruta que cubre (ej: "Guatemala - Quetzaltenango")
    numero_unidad VARCHAR(50),
    capacidad_pasajeros INTEGER,

    -- Fecha de registro
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bus_vehiculo ON bus(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_bus_empresa ON bus(empresa);

COMMENT ON TABLE bus IS 'Datos de buses extraurbanos vinculados a vehículos';

-- ========================================
-- 6. TABLA: ARTICULO_SANCION (Catálogo)
-- ========================================

CREATE TABLE IF NOT EXISTS articulo_sancion (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(20) NOT NULL UNIQUE, -- Ej: "Art. 145"
    descripcion TEXT NOT NULL,
    monto_multa DECIMAL(10,2),
    puntos_licencia INTEGER DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_articulo_numero ON articulo_sancion(numero);

COMMENT ON TABLE articulo_sancion IS 'Catálogo de artículos de ley de tránsito para sanciones';

-- Insertar artículos de ejemplo
INSERT INTO articulo_sancion (numero, descripcion, monto_multa, puntos_licencia) VALUES
('Art. 145', 'Conducir sin licencia', 500.00, 0),
('Art. 146', 'Exceso de velocidad', 300.00, 3),
('Art. 147', 'Conducir en estado de ebriedad', 1000.00, 5),
('Art. 148', 'No respetar señal de alto', 250.00, 2),
('Art. 149', 'Conducir sin cinturón de seguridad', 100.00, 1)
ON CONFLICT (numero) DO NOTHING;

-- ========================================
-- 7. TABLA: SANCION
-- ========================================

CREATE TABLE IF NOT EXISTS sancion (
    id SERIAL PRIMARY KEY,

    -- Relaciones
    incidente_id INTEGER NOT NULL REFERENCES incidente(id) ON DELETE CASCADE,
    vehiculo_id INTEGER NOT NULL REFERENCES vehiculo(id) ON DELETE CASCADE,
    piloto_id INTEGER REFERENCES piloto(id) ON DELETE SET NULL,
    articulo_sancion_id INTEGER REFERENCES articulo_sancion(id) ON DELETE SET NULL,

    -- Datos de la sanción
    descripcion TEXT,
    monto DECIMAL(10,2),
    pagada BOOLEAN DEFAULT FALSE,
    fecha_pago DATE,

    -- Auditoría
    aplicada_por INTEGER REFERENCES usuario(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sancion_incidente ON sancion(incidente_id);
CREATE INDEX IF NOT EXISTS idx_sancion_vehiculo ON sancion(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_sancion_piloto ON sancion(piloto_id);
CREATE INDEX IF NOT EXISTS idx_sancion_articulo ON sancion(articulo_sancion_id);

COMMENT ON TABLE sancion IS 'Sanciones aplicadas en incidentes a vehículos/pilotos';

-- ========================================
-- 8. TABLA MAESTRA: GRUA
-- ========================================

CREATE TABLE IF NOT EXISTS grua (
    id SERIAL PRIMARY KEY,

    -- Identificación
    nombre VARCHAR(255) NOT NULL,
    placa VARCHAR(20),
    telefono VARCHAR(50),

    -- Empresa
    empresa VARCHAR(255),
    nit BIGINT,

    -- Estadísticas
    total_servicios INTEGER DEFAULT 0,
    ultima_vez_usado TIMESTAMPTZ,

    -- Estado
    activa BOOLEAN DEFAULT TRUE,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_grua_master_nombre ON grua(nombre);
CREATE INDEX IF NOT EXISTS idx_grua_master_empresa ON grua(empresa);
CREATE INDEX IF NOT EXISTS idx_grua_master_placa ON grua(placa);

COMMENT ON TABLE grua IS 'Tabla maestra de grúas. Catálogo reutilizable.';

-- ========================================
-- 9. TABLA MAESTRA: ASEGURADORA
-- ========================================

CREATE TABLE IF NOT EXISTS aseguradora (
    id SERIAL PRIMARY KEY,

    -- Identificación
    nombre VARCHAR(255) NOT NULL UNIQUE,
    codigo VARCHAR(20),

    -- Contacto
    telefono VARCHAR(50),
    email VARCHAR(100),

    -- Estadísticas
    total_incidentes INTEGER DEFAULT 0,

    -- Estado
    activa BOOLEAN DEFAULT TRUE,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_aseguradora_nombre ON aseguradora(nombre);

COMMENT ON TABLE aseguradora IS 'Tabla maestra de aseguradoras. Catálogo reutilizable.';

-- ========================================
-- 10. TABLA DE UNIÓN: INCIDENTE_VEHICULO
-- ========================================

CREATE TABLE IF NOT EXISTS incidente_vehiculo (
    id SERIAL PRIMARY KEY,

    -- Relaciones
    incidente_id INTEGER NOT NULL REFERENCES incidente(id) ON DELETE CASCADE,
    vehiculo_id INTEGER NOT NULL REFERENCES vehiculo(id) ON DELETE CASCADE,
    piloto_id INTEGER REFERENCES piloto(id) ON DELETE SET NULL,

    -- Datos específicos del incidente para este vehículo
    estado_piloto VARCHAR(50), -- Ej: "ILESO", "HERIDO", "FALLECIDO", "EBRIO"
    personas_asistidas INTEGER DEFAULT 0,

    -- Aseguradora
    aseguradora_id INTEGER REFERENCES aseguradora(id) ON DELETE SET NULL,
    numero_poliza VARCHAR(100),

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_incidente_vehiculo_incidente ON incidente_vehiculo(incidente_id);
CREATE INDEX IF NOT EXISTS idx_incidente_vehiculo_vehiculo ON incidente_vehiculo(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_incidente_vehiculo_piloto ON incidente_vehiculo(piloto_id);

COMMENT ON TABLE incidente_vehiculo IS 'Relación many-to-many entre incidentes y vehículos';

-- ========================================
-- 11. TABLA DE UNIÓN: INCIDENTE_GRUA
-- ========================================

CREATE TABLE IF NOT EXISTS incidente_grua (
    id SERIAL PRIMARY KEY,

    -- Relaciones
    incidente_id INTEGER NOT NULL REFERENCES incidente(id) ON DELETE CASCADE,
    grua_id INTEGER NOT NULL REFERENCES grua(id) ON DELETE CASCADE,

    -- Datos del servicio
    hora_llamada TIME,
    hora_llegada TIME,
    destino TEXT,
    costo DECIMAL(10,2),

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_incidente_grua_incidente ON incidente_grua(incidente_id);
CREATE INDEX IF NOT EXISTS idx_incidente_grua_grua ON incidente_grua(grua_id);

COMMENT ON TABLE incidente_grua IS 'Relación many-to-many entre incidentes y grúas';

-- ========================================
-- 12. TRIGGERS PARA ACTUALIZAR CONTADORES
-- ========================================

-- Función para actualizar contadores de vehículo
CREATE OR REPLACE FUNCTION update_vehiculo_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE vehiculo SET
            total_incidentes = total_incidentes + 1,
            ultimo_incidente = NOW(),
            primer_incidente = COALESCE(primer_incidente, NOW())
        WHERE id = NEW.vehiculo_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_vehiculo_stats
AFTER INSERT ON incidente_vehiculo
FOR EACH ROW
EXECUTE FUNCTION update_vehiculo_stats();

-- Función para actualizar contadores de piloto
CREATE OR REPLACE FUNCTION update_piloto_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.piloto_id IS NOT NULL THEN
        UPDATE piloto SET
            total_incidentes = total_incidentes + 1,
            ultimo_incidente = NOW(),
            primer_incidente = COALESCE(primer_incidente, NOW())
        WHERE id = NEW.piloto_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_piloto_stats
AFTER INSERT ON incidente_vehiculo
FOR EACH ROW
EXECUTE FUNCTION update_piloto_stats();

-- Función para actualizar contadores de piloto en sanciones
CREATE OR REPLACE FUNCTION update_piloto_sancion_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.piloto_id IS NOT NULL THEN
        UPDATE piloto SET
            total_sanciones = total_sanciones + 1
        WHERE id = NEW.piloto_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_piloto_sancion_stats
AFTER INSERT ON sancion
FOR EACH ROW
EXECUTE FUNCTION update_piloto_sancion_stats();

-- Función para actualizar contadores de grúa
CREATE OR REPLACE FUNCTION update_grua_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE grua SET
            total_servicios = total_servicios + 1,
            ultima_vez_usado = NOW()
        WHERE id = NEW.grua_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_grua_stats
AFTER INSERT ON incidente_grua
FOR EACH ROW
EXECUTE FUNCTION update_grua_stats();

-- Función para actualizar contadores de aseguradora
CREATE OR REPLACE FUNCTION update_aseguradora_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.aseguradora_id IS NOT NULL THEN
        UPDATE aseguradora SET
            total_incidentes = total_incidentes + 1
        WHERE id = NEW.aseguradora_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_aseguradora_stats
AFTER INSERT ON incidente_vehiculo
FOR EACH ROW
EXECUTE FUNCTION update_aseguradora_stats();

-- Trigger para updated_at en vehiculo
CREATE TRIGGER update_vehiculo_updated_at
BEFORE UPDATE ON vehiculo
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger para updated_at en piloto
CREATE TRIGGER update_piloto_updated_at
BEFORE UPDATE ON piloto
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger para updated_at en grua
CREATE TRIGGER update_grua_updated_at
BEFORE UPDATE ON grua
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

COMMENT ON FUNCTION update_vehiculo_stats IS 'Actualiza contadores de incidentes en tabla vehiculo';
COMMENT ON FUNCTION update_piloto_stats IS 'Actualiza contadores de incidentes en tabla piloto';
COMMENT ON FUNCTION update_piloto_sancion_stats IS 'Actualiza contadores de sanciones en tabla piloto';
COMMENT ON FUNCTION update_grua_stats IS 'Actualiza contadores de servicios en tabla grua';
COMMENT ON FUNCTION update_aseguradora_stats IS 'Actualiza contadores de incidentes en tabla aseguradora';
-- ========================================
-- Migración 024b: Migración de Datos Existentes
-- ========================================
-- Objetivo: Migrar datos de vehiculo_incidente a las nuevas tablas normalizadas

-- ========================================
-- 1. MIGRAR VEHÍCULOS
-- ========================================

-- Insertar vehículos únicos desde vehiculo_incidente
INSERT INTO vehiculo (placa, es_extranjero, tipo_vehiculo_id, color, marca_id, cargado, tipo_carga)
SELECT DISTINCT ON (placa)
    placa,
    FALSE as es_extranjero, -- Columna no existe en vehiculo_incidente, usar FALSE por defecto
    tipo_vehiculo_id,
    color,
    marca_id,
    cargado,
    carga_tipo as tipo_carga -- La columna se llama carga_tipo en vehiculo_incidente
FROM vehiculo_incidente
WHERE placa IS NOT NULL AND placa != ''
ON CONFLICT (placa) DO NOTHING;

-- Actualizar contador de incidentes y fechas para vehículos migrados
UPDATE vehiculo v SET
    total_incidentes = (
        SELECT COUNT(DISTINCT vi.incidente_id)
        FROM vehiculo_incidente vi
        WHERE vi.placa = v.placa
    ),
    primer_incidente = (
        SELECT MIN(i.created_at)
        FROM vehiculo_incidente vi
        JOIN incidente i ON vi.incidente_id = i.id
        WHERE vi.placa = v.placa
    ),
    ultimo_incidente = (
        SELECT MAX(i.created_at)
        FROM vehiculo_incidente vi
        JOIN incidente i ON vi.incidente_id = i.id
        WHERE vi.placa = v.placa
    );

-- ========================================
-- 2. MIGRAR PILOTOS
-- ========================================

-- Insertar pilotos únicos desde vehiculo_incidente
INSERT INTO piloto (
    nombre,
    licencia_tipo,
    licencia_numero,
    licencia_vencimiento,
    licencia_antiguedad,
    fecha_nacimiento,
    etnia
)
SELECT DISTINCT ON (licencia_numero)
    nombre_piloto,
    licencia_tipo,
    CAST(licencia_numero AS BIGINT), -- Convertir a BIGINT
    licencia_vencimiento,
    licencia_antiguedad,
    piloto_nacimiento as fecha_nacimiento, -- Columna correcta
    piloto_etnia as etnia -- Columna correcta
FROM vehiculo_incidente
WHERE licencia_numero IS NOT NULL
ON CONFLICT (licencia_numero) DO NOTHING;

-- Actualizar contador de incidentes para pilotos migrados
UPDATE piloto p SET
    total_incidentes = (
        SELECT COUNT(DISTINCT vi.incidente_id)
        FROM vehiculo_incidente vi
        WHERE CAST(vi.licencia_numero AS BIGINT) = p.licencia_numero
    ),
    primer_incidente = (
        SELECT MIN(i.created_at)
        FROM vehiculo_incidente vi
        JOIN incidente i ON vi.incidente_id = i.id
        WHERE CAST(vi.licencia_numero AS BIGINT) = p.licencia_numero
    ),
    ultimo_incidente = (
        SELECT MAX(i.created_at)
        FROM vehiculo_incidente vi
        JOIN incidente i ON vi.incidente_id = i.id
        WHERE CAST(vi.licencia_numero AS BIGINT) = p.licencia_numero
    );

-- ========================================
-- 3. MIGRAR TARJETAS DE CIRCULACIÓN
-- ========================================

-- Insertar TCs desde vehiculo_incidente (solo si hay datos)
INSERT INTO tarjeta_circulacion (
    vehiculo_id,
    numero,
    nit,
    direccion_propietario,
    nombre_propietario,
    modelo
)
SELECT DISTINCT ON (v.id, vi.tarjeta_circulacion)
    v.id,
    CAST(vi.tarjeta_circulacion AS BIGINT) as numero, -- Columna correcta
    CASE
        WHEN vi.nit ~ '^[0-9]+$' THEN CAST(vi.nit AS BIGINT)
        ELSE NULL
    END as nit, -- nit es VARCHAR, convertir solo si es numérico
    vi.direccion_propietario,
    vi.nombre_propietario,
    vi.anio as modelo -- anio es el año del modelo
FROM vehiculo_incidente vi
JOIN vehiculo v ON vi.placa = v.placa
WHERE vi.tarjeta_circulacion IS NOT NULL AND vi.tarjeta_circulacion ~ '^[0-9]+$';

-- ========================================
-- 4. MIGRAR CONTENEDORES
-- ========================================

-- Insertar contenedores desde vehiculo_incidente (datos en JSONB)
INSERT INTO contenedor (
    vehiculo_id,
    numero_contenedor,
    linea_naviera,
    tipo_contenedor
)
SELECT DISTINCT ON (v.id, vi.contenedor_detalle->>'numero_contenedor')
    v.id,
    vi.contenedor_detalle->>'numero_contenedor' as numero_contenedor,
    vi.contenedor_detalle->>'linea_naviera' as linea_naviera,
    vi.contenedor_detalle->>'tipo' as tipo_contenedor
FROM vehiculo_incidente vi
JOIN vehiculo v ON vi.placa = v.placa
WHERE vi.contenedor = TRUE
  AND vi.contenedor_detalle IS NOT NULL
  AND vi.contenedor_detalle->>'numero_contenedor' IS NOT NULL;

-- ========================================
-- 5. MIGRAR BUSES
-- ========================================

-- Insertar buses desde vehiculo_incidente (datos en JSONB)
INSERT INTO bus (
    vehiculo_id,
    empresa,
    ruta_bus,
    numero_unidad,
    capacidad_pasajeros
)
SELECT DISTINCT ON (v.id)
    v.id,
    vi.bus_detalle->>'empresa' as empresa,
    vi.bus_detalle->>'ruta' as ruta_bus,
    vi.bus_detalle->>'numero_unidad' as numero_unidad,
    CASE
        WHEN vi.bus_detalle->>'capacidad_pasajeros' ~ '^[0-9]+$'
        THEN CAST(vi.bus_detalle->>'capacidad_pasajeros' AS INTEGER)
        ELSE NULL
    END as capacidad_pasajeros
FROM vehiculo_incidente vi
JOIN vehiculo v ON vi.placa = v.placa
WHERE vi.bus_extraurbano = TRUE
  AND vi.bus_detalle IS NOT NULL
  AND vi.bus_detalle->>'empresa' IS NOT NULL;

-- ========================================
-- 6. MIGRAR ASEGURADORAS
-- ========================================

-- NOTA: No hay columna 'aseguradora' en vehiculo_incidente
-- Esta sección se puede usar cuando se agregue esa información
-- Por ahora, dejamos las tablas vacías

-- Insertar aseguradoras únicas desde vehiculo_incidente (SKIP - no existe la columna)
-- INSERT INTO aseguradora (nombre)
-- SELECT DISTINCT aseguradora
-- FROM vehiculo_incidente
-- WHERE aseguradora IS NOT NULL
--   AND aseguradora != ''
-- ON CONFLICT (nombre) DO NOTHING;

-- ========================================
-- 7. MIGRAR GRÚAS
-- ========================================

-- Insertar grúas únicas desde grua_involucrada
INSERT INTO grua (
    nombre,
    placa,
    telefono,
    empresa,
    nit
)
SELECT DISTINCT ON (piloto, empresa, placa)
    COALESCE(piloto, 'Grúa ' || placa, 'Grúa sin nombre') as nombre,
    placa,
    NULL as telefono, -- No existe en grua_involucrada
    empresa,
    NULL as nit -- No existe en grua_involucrada
FROM grua_involucrada
WHERE placa IS NOT NULL OR piloto IS NOT NULL;

-- Actualizar contador de servicios para grúas
UPDATE grua g SET
    total_servicios = (
        SELECT COUNT(*)
        FROM grua_involucrada gi
        WHERE (gi.placa = g.placa OR (gi.placa IS NULL AND g.placa IS NULL))
          AND (gi.empresa = g.empresa OR (gi.empresa IS NULL AND g.empresa IS NULL))
    ),
    ultima_vez_usado = (
        SELECT MAX(i.created_at)
        FROM grua_involucrada gi
        JOIN incidente i ON gi.incidente_id = i.id
        WHERE (gi.placa = g.placa OR (gi.placa IS NULL AND g.placa IS NULL))
          AND (gi.empresa = g.empresa OR (gi.empresa IS NULL AND g.empresa IS NULL))
    );

-- ========================================
-- 8. MIGRAR RELACIONES INCIDENTE-VEHICULO
-- ========================================

-- Insertar relaciones desde vehiculo_incidente
INSERT INTO incidente_vehiculo (
    incidente_id,
    vehiculo_id,
    piloto_id,
    estado_piloto,
    personas_asistidas,
    aseguradora_id,
    numero_poliza
)
SELECT
    vi.incidente_id,
    v.id AS vehiculo_id,
    p.id AS piloto_id,
    vi.estado_piloto,
    vi.personas_asistidas,
    NULL as aseguradora_id, -- No hay datos de aseguradora en vehiculo_incidente
    NULL as numero_poliza -- No hay datos de poliza en vehiculo_incidente
FROM vehiculo_incidente vi
LEFT JOIN vehiculo v ON vi.placa = v.placa
LEFT JOIN piloto p ON CAST(vi.licencia_numero AS BIGINT) = p.licencia_numero
WHERE v.id IS NOT NULL; -- Solo migrar si el vehículo existe

-- ========================================
-- 9. MIGRAR RELACIONES INCIDENTE-GRÚA
-- ========================================

-- Insertar relaciones desde grua_involucrada
INSERT INTO incidente_grua (
    incidente_id,
    grua_id,
    hora_llamada,
    hora_llegada,
    destino,
    costo
)
SELECT
    gi.incidente_id,
    g.id AS grua_id,
    NULL as hora_llamada, -- No existe en grua_involucrada
    NULL as hora_llegada, -- No existe en grua_involucrada
    gi.traslado_a as destino,
    NULL as costo -- No existe en grua_involucrada
FROM grua_involucrada gi
LEFT JOIN grua g ON (gi.placa = g.placa OR (gi.placa IS NULL AND g.placa IS NULL))
  AND (gi.empresa = g.empresa OR (gi.empresa IS NULL AND g.empresa IS NULL))
WHERE g.id IS NOT NULL AND gi.traslado = TRUE; -- Solo migrar si la grúa existe y hubo traslado

-- ========================================
-- 10. VERIFICACIÓN DE LA MIGRACIÓN
-- ========================================

-- Mostrar resumen de la migración
SELECT
    'Vehículos migrados' AS tabla,
    COUNT(*) AS total
FROM vehiculo

UNION ALL

SELECT
    'Pilotos migrados' AS tabla,
    COUNT(*) AS total
FROM piloto

UNION ALL

SELECT
    'Tarjetas circulación migradas' AS tabla,
    COUNT(*) AS total
FROM tarjeta_circulacion

UNION ALL

SELECT
    'Contenedores migrados' AS tabla,
    COUNT(*) AS total
FROM contenedor

UNION ALL

SELECT
    'Buses migrados' AS tabla,
    COUNT(*) AS total
FROM bus

UNION ALL

SELECT
    'Aseguradoras migradas' AS tabla,
    COUNT(*) AS total
FROM aseguradora

UNION ALL

SELECT
    'Grúas migradas' AS tabla,
    COUNT(*) AS total
FROM grua

UNION ALL

SELECT
    'Relaciones incidente-vehiculo migradas' AS tabla,
    COUNT(*) AS total
FROM incidente_vehiculo

UNION ALL

SELECT
    'Relaciones incidente-grúa migradas' AS tabla,
    COUNT(*) AS total
FROM incidente_grua;

-- ========================================
-- IMPORTANTE: NO ELIMINAR TABLAS ANTIGUAS TODAVÍA
-- ========================================
-- Las tablas vehiculo_incidente y grua_involucrada se mantienen
-- por seguridad hasta verificar que todo funciona correctamente.
-- Se eliminarán en una migración posterior (025_cleanup.sql)
-- ========================================
-- CREAR TABLAS FALTANTES PARA CATÁLOGOS
-- ========================================

-- Tabla de Marcas de Vehículos
CREATE TABLE IF NOT EXISTS marca (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de Tipos de Vehículos
CREATE TABLE IF NOT EXISTS tipo_vehiculo (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_marca_nombre ON marca(nombre);
CREATE INDEX IF NOT EXISTS idx_tipo_vehiculo_nombre ON tipo_vehiculo(nombre);

-- Comentarios
COMMENT ON TABLE marca IS 'Catálogo de marcas de vehículos';
COMMENT ON TABLE tipo_vehiculo IS 'Catálogo de tipos de vehículos';
-- ========================================
-- Migración 025: Vistas Materializadas de Inteligencia
-- ========================================
-- Objetivo: Crear vistas materializadas para análisis y alertas inteligentes

-- ========================================
-- 1. VEHÍCULOS REINCIDENTES
-- ========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_vehiculos_reincidentes AS
SELECT
    v.id,
    v.placa,
    v.es_extranjero,
    tv.nombre as tipo_vehiculo,
    m.nombre as marca,
    v.color,
    v.total_incidentes,
    v.primer_incidente,
    v.ultimo_incidente,
    -- Calcular días desde el primer incidente
    CASE
        WHEN v.primer_incidente IS NOT NULL
        THEN EXTRACT(DAY FROM (NOW() - v.primer_incidente))::INTEGER
        ELSE NULL
    END as dias_desde_primer_incidente,
    -- Calcular días desde el último incidente
    CASE
        WHEN v.ultimo_incidente IS NOT NULL
        THEN EXTRACT(DAY FROM (NOW() - v.ultimo_incidente))::INTEGER
        ELSE NULL
    END as dias_desde_ultimo_incidente,
    -- Calcular frecuencia de incidentes (incidentes por mes)
    CASE
        WHEN v.primer_incidente IS NOT NULL AND v.ultimo_incidente IS NOT NULL
        THEN v.total_incidentes::NUMERIC / GREATEST(1, EXTRACT(EPOCH FROM (v.ultimo_incidente - v.primer_incidente)) / (30 * 24 * 60 * 60))
        ELSE 0
    END as frecuencia_mensual,
    -- Nivel de riesgo (1-5)
    CASE
        WHEN v.total_incidentes >= 5 THEN 5
        WHEN v.total_incidentes >= 4 THEN 4
        WHEN v.total_incidentes >= 3 THEN 3
        WHEN v.total_incidentes >= 2 THEN 2
        ELSE 1
    END as nivel_riesgo
FROM vehiculo v
LEFT JOIN tipo_vehiculo tv ON v.tipo_vehiculo_id = tv.id
LEFT JOIN marca_vehiculo m ON v.marca_id = m.id
WHERE v.total_incidentes >= 2 -- Solo vehículos con 2+ incidentes
ORDER BY v.total_incidentes DESC, v.ultimo_incidente DESC;

CREATE UNIQUE INDEX ON mv_vehiculos_reincidentes (id);
CREATE INDEX ON mv_vehiculos_reincidentes (placa);
CREATE INDEX ON mv_vehiculos_reincidentes (nivel_riesgo DESC);

COMMENT ON MATERIALIZED VIEW mv_vehiculos_reincidentes IS 'Vehículos con múltiples incidentes y su nivel de riesgo';

-- ========================================
-- 2. PILOTOS PROBLEMÁTICOS
-- ========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_pilotos_problematicos AS
SELECT
    p.id,
    p.nombre,
    p.licencia_tipo,
    p.licencia_numero,
    p.licencia_vencimiento,
    p.total_incidentes,
    p.total_sanciones,
    p.primer_incidente,
    p.ultimo_incidente,
    -- Calcular edad aproximada
    CASE
        WHEN p.fecha_nacimiento IS NOT NULL
        THEN EXTRACT(YEAR FROM AGE(p.fecha_nacimiento))
        ELSE NULL
    END as edad,
    -- Verificar si la licencia está vencida
    CASE
        WHEN p.licencia_vencimiento IS NOT NULL AND p.licencia_vencimiento < NOW()
        THEN true
        ELSE false
    END as licencia_vencida,
    -- Días hasta vencimiento (negativo si ya venció)
    CASE
        WHEN p.licencia_vencimiento IS NOT NULL
        THEN (p.licencia_vencimiento - NOW()::DATE)
        ELSE NULL
    END as dias_hasta_vencimiento,
    -- Nivel de riesgo combinado (1-5)
    CASE
        WHEN p.total_sanciones >= 5 OR p.total_incidentes >= 5 THEN 5
        WHEN p.total_sanciones >= 3 OR p.total_incidentes >= 4 THEN 4
        WHEN p.total_sanciones >= 2 OR p.total_incidentes >= 3 THEN 3
        WHEN p.total_sanciones >= 1 OR p.total_incidentes >= 2 THEN 2
        ELSE 1
    END as nivel_riesgo
FROM piloto p
WHERE p.total_incidentes >= 1 OR p.total_sanciones >= 1
ORDER BY (p.total_incidentes + p.total_sanciones) DESC, p.ultimo_incidente DESC;

CREATE UNIQUE INDEX ON mv_pilotos_problematicos (id);
CREATE INDEX ON mv_pilotos_problematicos (licencia_numero);
CREATE INDEX ON mv_pilotos_problematicos (nivel_riesgo DESC);
CREATE INDEX ON mv_pilotos_problematicos (licencia_vencida) WHERE licencia_vencida = true;

COMMENT ON MATERIALIZED VIEW mv_pilotos_problematicos IS 'Pilotos con incidentes/sanciones y su nivel de riesgo';

-- ========================================
-- 3. PUNTOS CALIENTES (HOTSPOTS)
-- ========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_puntos_calientes AS
SELECT
    -- Identificador compuesto
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as id,

    -- Ubicación
    COALESCE(r.codigo, 'SIN_RUTA') as ruta_codigo,
    COALESCE(r.nombre, 'Sin ruta asignada') as ruta_nombre,
    i.municipio_id as municipio_codigo,
    m.nombre as municipio_nombre,
    i.km as kilometro,

    -- Estadísticas
    COUNT(*) as total_incidentes,
    COUNT(*) as total_accidentes, -- Todos los incidentes son accidentes en esta tabla
    0 as total_asistencias, -- No hay campo tipo en incidente
    0 as total_emergencias, -- No hay campo tipo en incidente

    -- Heridos y fallecidos
    COALESCE(SUM(i.cantidad_heridos), 0) as total_heridos,
    COALESCE(SUM(i.cantidad_fallecidos), 0) as total_fallecidos,

    -- Fechas
    MIN(i.created_at) as primer_incidente,
    MAX(i.created_at) as ultimo_incidente,

    -- Frecuencia (incidentes por mes)
    COUNT(*)::NUMERIC / GREATEST(1, EXTRACT(EPOCH FROM (MAX(i.created_at) - MIN(i.created_at))) / (30 * 24 * 60 * 60)) as frecuencia_mensual,

    -- Nivel de peligrosidad (1-5)
    CASE
        WHEN COUNT(*) >= 10 OR SUM(i.cantidad_fallecidos) >= 3 THEN 5
        WHEN COUNT(*) >= 7 OR SUM(i.cantidad_fallecidos) >= 2 THEN 4
        WHEN COUNT(*) >= 5 OR SUM(i.cantidad_heridos) >= 5 THEN 3
        WHEN COUNT(*) >= 3 OR SUM(i.cantidad_heridos) >= 2 THEN 2
        ELSE 1
    END as nivel_peligrosidad,

    -- Coordenadas promedio (para mapas)
    AVG(i.latitud) as latitud_promedio,
    AVG(i.longitud) as longitud_promedio

FROM incidente i
LEFT JOIN ruta r ON i.ruta_id = r.id
LEFT JOIN municipio m ON i.municipio_id = m.id
WHERE i.estado IN ('REGISTRADO', 'CERRADO') -- Estados del incidente
GROUP BY r.codigo, r.nombre, i.municipio_id, m.nombre, i.km
HAVING COUNT(*) >= 2 -- Solo puntos con 2+ incidentes
ORDER BY total_incidentes DESC, total_fallecidos DESC, total_heridos DESC;

CREATE UNIQUE INDEX ON mv_puntos_calientes (id);
CREATE INDEX ON mv_puntos_calientes (ruta_codigo, kilometro);
CREATE INDEX ON mv_puntos_calientes (nivel_peligrosidad DESC);
CREATE INDEX ON mv_puntos_calientes (municipio_codigo);

COMMENT ON MATERIALIZED VIEW mv_puntos_calientes IS 'Puntos geográficos con alta concentración de incidentes';

-- ========================================
-- 4. TENDENCIAS TEMPORALES
-- ========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tendencias_temporales AS
SELECT
    -- Fecha
    DATE(i.created_at) as fecha,
    EXTRACT(YEAR FROM i.created_at)::INTEGER as anio,
    EXTRACT(MONTH FROM i.created_at)::INTEGER as mes,
    EXTRACT(DOW FROM i.created_at)::INTEGER as dia_semana, -- 0=Domingo, 6=Sábado
    EXTRACT(HOUR FROM i.created_at)::INTEGER as hora,

    -- Nombre del día
    CASE EXTRACT(DOW FROM i.created_at)::INTEGER
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
    END as nombre_dia,

    -- Tipo de día
    CASE
        WHEN EXTRACT(DOW FROM i.created_at)::INTEGER IN (0, 6) THEN 'Fin de semana'
        ELSE 'Entre semana'
    END as tipo_dia,

    -- Franja horaria
    CASE
        WHEN EXTRACT(HOUR FROM i.created_at)::INTEGER BETWEEN 0 AND 5 THEN 'Madrugada (00:00-05:59)'
        WHEN EXTRACT(HOUR FROM i.created_at)::INTEGER BETWEEN 6 AND 11 THEN 'Mañana (06:00-11:59)'
        WHEN EXTRACT(HOUR FROM i.created_at)::INTEGER BETWEEN 12 AND 17 THEN 'Tarde (12:00-17:59)'
        ELSE 'Noche (18:00-23:59)'
    END as franja_horaria,

    -- Estadísticas
    COUNT(*) as total_incidentes,
    COUNT(*) as total_accidentes, -- Todos son accidentes
    0 as total_asistencias, -- No hay campo tipo
    0 as total_emergencias, -- No hay campo tipo

    COALESCE(SUM(i.cantidad_heridos), 0) as total_heridos,
    COALESCE(SUM(i.cantidad_fallecidos), 0) as total_fallecidos

FROM incidente i
WHERE i.estado IN ('REGISTRADO', 'CERRADO')
GROUP BY fecha, anio, mes, dia_semana, hora, nombre_dia, tipo_dia, franja_horaria
ORDER BY fecha DESC, hora DESC;

CREATE UNIQUE INDEX ON mv_tendencias_temporales (fecha, hora);
CREATE INDEX ON mv_tendencias_temporales (fecha DESC);
CREATE INDEX ON mv_tendencias_temporales (anio, mes);
CREATE INDEX ON mv_tendencias_temporales (dia_semana);
CREATE INDEX ON mv_tendencias_temporales (hora);
CREATE INDEX ON mv_tendencias_temporales (franja_horaria);

COMMENT ON MATERIALIZED VIEW mv_tendencias_temporales IS 'Análisis temporal de incidentes por fecha, hora y día de la semana';

-- ========================================
-- 5. FUNCIÓN PARA REFRESCAR TODAS LAS VISTAS
-- ========================================

CREATE OR REPLACE FUNCTION refresh_intelligence_views()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_vehiculos_reincidentes;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_pilotos_problematicos;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_puntos_calientes;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_tendencias_temporales;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION refresh_intelligence_views IS 'Refresca todas las vistas materializadas de inteligencia';

-- ========================================
-- 6. TRIGGER PARA AUTO-REFRESH (OPCIONAL)
-- ========================================

-- Crear tabla para controlar cuando refrescar
CREATE TABLE IF NOT EXISTS intelligence_refresh_log (
    id SERIAL PRIMARY KEY,
    view_name VARCHAR(100) NOT NULL,
    refreshed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duration_ms INTEGER,
    rows_affected INTEGER
);

COMMENT ON TABLE intelligence_refresh_log IS 'Log de refrescos de vistas materializadas';

-- ========================================
-- NOTAS:
-- ========================================
-- - Las vistas materializadas se deben refrescar periódicamente (ej: cada hora)
-- - Se puede usar un cron job o scheduler para llamar refresh_intelligence_views()
-- - El índice UNIQUE permite usar REFRESH MATERIALIZED VIEW CONCURRENTLY (sin bloquear lecturas)
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
-- ========================================
-- Migración 026: Mejoras al Módulo de Operaciones
-- ========================================
-- Cambios principales:
-- 1. Agregar teléfono de contacto a usuarios y tripulación
-- 2. Control de combustible mejorado
-- 3. Permitir turnos planificados con fecha específica (no solo hoy)
-- 4. Alertas de descanso para brigadas
-- 5. Multi-sede (cada operaciones ve sus recursos)
-- ========================================

-- ========================================
-- 1. VERIFICAR COLUMNA TELÉFONO EN USUARIOS
-- ========================================

-- La columna telefono ya existe en usuario (creada en migración 002)
-- Solo agregamos un índice si no existe

CREATE INDEX IF NOT EXISTS idx_usuario_telefono ON usuario(telefono) WHERE telefono IS NOT NULL;

-- ========================================
-- 2. AGREGAR COMBUSTIBLE ACTUAL A UNIDAD
-- ========================================

ALTER TABLE unidad
ADD COLUMN IF NOT EXISTS combustible_actual DECIMAL(6,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS capacidad_combustible DECIMAL(6,2),
ADD COLUMN IF NOT EXISTS odometro_actual DECIMAL(10,2) DEFAULT 0;

COMMENT ON COLUMN unidad.combustible_actual IS 'Combustible actual en litros (actualizado por brigadas)';
COMMENT ON COLUMN unidad.capacidad_combustible IS 'Capacidad total del tanque en litros';
COMMENT ON COLUMN unidad.odometro_actual IS 'Kilometraje total del vehículo';

CREATE INDEX IF NOT EXISTS idx_unidad_combustible ON unidad(combustible_actual) WHERE activa = TRUE;

-- ========================================
-- 3. TABLA: COMBUSTIBLE_REGISTRO
-- ========================================

CREATE TABLE IF NOT EXISTS combustible_registro (
    id BIGSERIAL PRIMARY KEY,

    -- Relaciones
    unidad_id INTEGER NOT NULL REFERENCES unidad(id) ON DELETE CASCADE,
    asignacion_id INTEGER REFERENCES asignacion_unidad(id) ON DELETE SET NULL,
    turno_id INTEGER REFERENCES turno(id) ON DELETE SET NULL,

    -- Tipo de registro
    tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('INICIAL', 'RECARGA', 'FINAL', 'AJUSTE')),

    -- Cantidades
    combustible_anterior DECIMAL(6,2) NOT NULL,
    combustible_agregado DECIMAL(6,2) DEFAULT 0,
    combustible_nuevo DECIMAL(6,2) NOT NULL,
    combustible_consumido DECIMAL(6,2), -- Calculado para tipo FINAL

    -- Odómetro
    odometro_anterior DECIMAL(10,2),
    odometro_actual DECIMAL(10,2),
    km_recorridos DECIMAL(8,2),

    -- Eficiencia
    rendimiento_km_litro DECIMAL(6,2), -- km/litro calculado

    -- Metadata
    observaciones TEXT,
    registrado_por INTEGER NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE combustible_registro IS 'Historial detallado de combustible por unidad y turno';
COMMENT ON COLUMN combustible_registro.tipo IS 'INICIAL: al iniciar turno | RECARGA: durante turno | FINAL: al terminar turno | AJUSTE: corrección manual';
COMMENT ON COLUMN combustible_registro.rendimiento_km_litro IS 'Rendimiento calculado (km_recorridos / combustible_consumido)';

CREATE INDEX idx_combustible_unidad ON combustible_registro(unidad_id);
CREATE INDEX idx_combustible_asignacion ON combustible_registro(asignacion_id);
CREATE INDEX idx_combustible_turno ON combustible_registro(turno_id);
CREATE INDEX idx_combustible_tipo ON combustible_registro(tipo);
CREATE INDEX idx_combustible_created ON combustible_registro(created_at DESC);

-- Trigger para actualizar combustible actual de unidad
CREATE OR REPLACE FUNCTION update_combustible_unidad()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE unidad
    SET
        combustible_actual = NEW.combustible_nuevo,
        odometro_actual = COALESCE(NEW.odometro_actual, odometro_actual),
        updated_at = NOW()
    WHERE id = NEW.unidad_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_combustible_unidad
AFTER INSERT ON combustible_registro
FOR EACH ROW
EXECUTE FUNCTION update_combustible_unidad();

COMMENT ON FUNCTION update_combustible_unidad IS 'Actualiza automáticamente el combustible actual de la unidad';

-- ========================================
-- 4. AGREGAR TELÉFONO DE CONTACTO A TRIPULACIÓN
-- ========================================

ALTER TABLE tripulacion_turno
ADD COLUMN IF NOT EXISTS telefono_contacto VARCHAR(20);

COMMENT ON COLUMN tripulacion_turno.telefono_contacto IS 'Teléfono de contacto para este turno específico (puede diferir del usuario)';

-- ========================================
-- 5. AGREGAR NOTIFICACIÓN ENVIADA
-- ========================================

ALTER TABLE asignacion_unidad
ADD COLUMN IF NOT EXISTS notificacion_enviada BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS fecha_notificacion TIMESTAMPTZ;

COMMENT ON COLUMN asignacion_unidad.notificacion_enviada IS 'Si ya se notificó a la tripulación de esta asignación';

-- ========================================
-- 6. VISTA: ESTADÍSTICAS DE BRIGADAS
-- ========================================

CREATE OR REPLACE VIEW v_estadisticas_brigadas AS
SELECT
    u.id AS usuario_id,
    u.nombre_completo,
    u.chapa,
    u.telefono,
    u.sede_id,
    s.nombre AS sede_nombre,
    r.nombre AS rol_nombre,

    -- Contadores
    COUNT(DISTINCT t.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS turnos_ultimo_mes,
    COUNT(DISTINCT t.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '90 days') AS turnos_ultimo_trimestre,

    -- Último turno
    MAX(t.fecha) AS ultimo_turno_fecha,
    CURRENT_DATE - MAX(t.fecha) AS dias_desde_ultimo_turno,

    -- Próximo turno
    MIN(t.fecha) FILTER (WHERE t.fecha >= CURRENT_DATE) AS proximo_turno_fecha,

    -- Roles más frecuentes en tripulación
    MODE() WITHIN GROUP (ORDER BY tt.rol_tripulacion) AS rol_tripulacion_frecuente,

    -- Estado
    u.activo

FROM usuario u
INNER JOIN sede s ON u.sede_id = s.id
INNER JOIN rol r ON u.rol_id = r.id
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id
LEFT JOIN turno t ON au.turno_id = t.id
WHERE r.nombre = 'BRIGADA'
GROUP BY u.id, u.nombre_completo, u.chapa, u.telefono, u.sede_id, s.nombre, r.nombre, u.activo;

COMMENT ON VIEW v_estadisticas_brigadas IS 'Estadísticas de turnos y disponibilidad por brigada';

-- ========================================
-- 7. VISTA: ESTADÍSTICAS DE UNIDADES
-- ========================================

CREATE OR REPLACE VIEW v_estadisticas_unidades AS
SELECT
    un.id AS unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    un.marca,
    un.modelo,
    un.sede_id,
    s.nombre AS sede_nombre,

    -- Estado actual
    un.activa,
    un.combustible_actual,
    un.capacidad_combustible,
    un.odometro_actual,

    -- Contadores de uso
    COUNT(DISTINCT au.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS turnos_ultimo_mes,
    COUNT(DISTINCT au.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '90 days') AS turnos_ultimo_trimestre,

    -- Último uso
    MAX(t.fecha) AS ultimo_turno_fecha,
    CURRENT_DATE - MAX(t.fecha) AS dias_desde_ultimo_uso,

    -- Próximo turno
    MIN(t.fecha) FILTER (WHERE t.fecha >= CURRENT_DATE) AS proximo_turno_fecha,

    -- Combustible
    AVG(cr.combustible_consumido) FILTER (WHERE cr.created_at >= CURRENT_DATE - INTERVAL '30 days') AS consumo_promedio_diario,
    AVG(cr.rendimiento_km_litro) FILTER (WHERE cr.created_at >= CURRENT_DATE - INTERVAL '30 days') AS rendimiento_promedio,

    -- Kilometraje
    SUM(au.km_recorridos) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS km_ultimo_mes

FROM unidad un
INNER JOIN sede s ON un.sede_id = s.id
LEFT JOIN asignacion_unidad au ON un.id = au.unidad_id
LEFT JOIN turno t ON au.turno_id = t.id
LEFT JOIN combustible_registro cr ON un.id = cr.unidad_id AND cr.tipo = 'FINAL'
GROUP BY un.id, un.codigo, un.tipo_unidad, un.marca, un.modelo, un.sede_id, s.nombre;

COMMENT ON VIEW v_estadisticas_unidades IS 'Estadísticas de uso y combustible por unidad';

-- ========================================
-- 8. VISTA: DISPONIBILIDAD DE RECURSOS
-- ========================================

CREATE OR REPLACE VIEW v_disponibilidad_recursos AS
SELECT
    s.id AS sede_id,
    s.nombre AS sede_nombre,

    -- Brigadas
    COUNT(DISTINCT u.id) FILTER (WHERE r.nombre = 'BRIGADA' AND u.activo = TRUE) AS total_brigadas_activas,
    COUNT(DISTINCT tt.usuario_id) FILTER (
        WHERE t.fecha = CURRENT_DATE
        AND r.nombre = 'BRIGADA'
        AND u.activo = TRUE
    ) AS brigadas_en_turno_hoy,

    -- Unidades
    COUNT(DISTINCT un.id) FILTER (WHERE un.activa = TRUE) AS total_unidades_activas,
    COUNT(DISTINCT au.unidad_id) FILTER (
        WHERE t.fecha = CURRENT_DATE
    ) AS unidades_en_turno_hoy,

    -- Disponibles
    COUNT(DISTINCT u.id) FILTER (
        WHERE r.nombre = 'BRIGADA'
        AND u.activo = TRUE
        AND u.id NOT IN (
            SELECT tt2.usuario_id
            FROM tripulacion_turno tt2
            JOIN asignacion_unidad au2 ON tt2.asignacion_id = au2.id
            JOIN turno t2 ON au2.turno_id = t2.id
            WHERE t2.fecha = CURRENT_DATE
        )
    ) AS brigadas_disponibles_hoy,

    COUNT(DISTINCT un.id) FILTER (
        WHERE un.activa = TRUE
        AND un.id NOT IN (
            SELECT au3.unidad_id
            FROM asignacion_unidad au3
            JOIN turno t3 ON au3.turno_id = t3.id
            WHERE t3.fecha = CURRENT_DATE
        )
    ) AS unidades_disponibles_hoy

FROM sede s
LEFT JOIN usuario u ON s.id = u.sede_id
LEFT JOIN rol r ON u.rol_id = r.id
LEFT JOIN unidad un ON s.id = un.sede_id
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id AND un.id = au.unidad_id
LEFT JOIN turno t ON au.turno_id = t.id
GROUP BY s.id, s.nombre;

COMMENT ON VIEW v_disponibilidad_recursos IS 'Resumen de disponibilidad de recursos por sede';

-- ========================================
-- 9. FUNCIÓN: VALIDAR DISPONIBILIDAD BRIGADA
-- ========================================

CREATE OR REPLACE FUNCTION validar_disponibilidad_brigada(
    p_usuario_id INTEGER,
    p_fecha DATE
)
RETURNS TABLE (
    disponible BOOLEAN,
    mensaje TEXT,
    ultimo_turno_fecha DATE,
    dias_descanso INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN COUNT(au.id) > 0 THEN FALSE -- Ya tiene turno ese día
            WHEN MAX(t.fecha) IS NOT NULL
                 AND (p_fecha - MAX(t.fecha)) < 2 THEN FALSE -- Salió hace menos de 2 días
            ELSE TRUE
        END AS disponible,

        CASE
            WHEN COUNT(au.id) > 0 THEN 'Brigada ya tiene asignación para esta fecha'
            WHEN MAX(t.fecha) IS NOT NULL
                 AND (p_fecha - MAX(t.fecha)) = 0 THEN 'Brigada sale el mismo día'
            WHEN MAX(t.fecha) IS NOT NULL
                 AND (p_fecha - MAX(t.fecha)) = 1 THEN 'Brigada salió ayer - descanso recomendado'
            ELSE 'Brigada disponible'
        END AS mensaje,

        MAX(t.fecha) AS ultimo_turno_fecha,
        COALESCE(p_fecha - MAX(t.fecha), 999) AS dias_descanso

    FROM tripulacion_turno tt
    JOIN asignacion_unidad au ON tt.asignacion_id = au.id
    JOIN turno t ON au.turno_id = t.id
    WHERE tt.usuario_id = p_usuario_id
      AND (
          t.fecha = p_fecha
          OR t.fecha >= p_fecha - INTERVAL '7 days'
      )
    GROUP BY tt.usuario_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_disponibilidad_brigada IS 'Valida si una brigada está disponible para una fecha y retorna alertas';

-- ========================================
-- 10. FUNCIÓN: VALIDAR DISPONIBILIDAD UNIDAD
-- ========================================

CREATE OR REPLACE FUNCTION validar_disponibilidad_unidad(
    p_unidad_id INTEGER,
    p_fecha DATE
)
RETURNS TABLE (
    disponible BOOLEAN,
    mensaje TEXT,
    ultimo_uso_fecha DATE,
    dias_descanso INTEGER,
    combustible_suficiente BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN COUNT(au.id) > 0 THEN FALSE -- Ya está asignada ese día
            WHEN un.activa = FALSE THEN FALSE -- Unidad inactiva
            WHEN un.combustible_actual < 10 THEN FALSE -- Poco combustible
            ELSE TRUE
        END AS disponible,

        CASE
            WHEN COUNT(au.id) > 0 THEN 'Unidad ya asignada para esta fecha'
            WHEN un.activa = FALSE THEN 'Unidad está inactiva'
            WHEN un.combustible_actual < 10 THEN 'Combustible insuficiente (menos de 10L)'
            ELSE 'Unidad disponible'
        END AS mensaje,

        MAX(t.fecha) AS ultimo_uso_fecha,
        COALESCE(p_fecha - MAX(t.fecha), 999) AS dias_descanso,
        COALESCE(un.combustible_actual >= 10, FALSE) AS combustible_suficiente

    FROM unidad un
    LEFT JOIN asignacion_unidad au ON un.id = au.unidad_id
    LEFT JOIN turno t ON au.turno_id = t.id AND (t.fecha = p_fecha OR t.fecha >= p_fecha - INTERVAL '7 days')
    WHERE un.id = p_unidad_id
    GROUP BY un.id, un.activa, un.combustible_actual;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_disponibilidad_unidad IS 'Valida si una unidad está disponible para una fecha';

-- ========================================
-- 11. ÍNDICES ADICIONALES PARA PERFORMANCE
-- ========================================

CREATE INDEX IF NOT EXISTS idx_turno_fecha_estado ON turno(fecha, estado);
CREATE INDEX IF NOT EXISTS idx_asignacion_turno_unidad ON asignacion_unidad(turno_id, unidad_id);
CREATE INDEX IF NOT EXISTS idx_tripulacion_usuario_fecha ON tripulacion_turno(usuario_id, created_at);

-- ========================================
-- GRANTS (si es necesario)
-- ========================================

-- Los usuarios de operaciones deben poder gestionar turnos
-- GRANT SELECT, INSERT, UPDATE ON turno TO operaciones_role;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON asignacion_unidad TO operaciones_role;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON tripulacion_turno TO operaciones_role;
-- ========================================
-- Migración 027: Ajustar Sentidos a Solo 4 Direcciones
-- ========================================
-- Cambios:
-- 1. Actualizar tabla asignacion_unidad para solo permitir NORTE, SUR, ORIENTE, OCCIDENTE
-- ========================================

-- ========================================
-- 1. ACTUALIZAR CONSTRAINT DE SENTIDO EN ASIGNACION_UNIDAD
-- ========================================

-- Eliminar el constraint existente primero
ALTER TABLE asignacion_unidad DROP CONSTRAINT IF EXISTS asignacion_unidad_sentido_check;

-- Actualizar valores existentes de ESTE a ORIENTE y OESTE a OCCIDENTE
UPDATE asignacion_unidad SET sentido = 'ORIENTE' WHERE sentido = 'ESTE';
UPDATE asignacion_unidad SET sentido = 'OCCIDENTE' WHERE sentido = 'OESTE';

-- Actualizar valores de ASCENDENTE/DESCENDENTE/AMBOS a NULL o un valor por defecto
UPDATE asignacion_unidad SET sentido = NULL WHERE sentido IN ('ASCENDENTE', 'DESCENDENTE', 'AMBOS');

-- Agregar nuevo constraint con solo 4 sentidos
ALTER TABLE asignacion_unidad
ADD CONSTRAINT asignacion_unidad_sentido_check
CHECK (sentido IN ('NORTE', 'SUR', 'ORIENTE', 'OCCIDENTE'));

COMMENT ON COLUMN asignacion_unidad.sentido IS 'Sentido de recorrido: NORTE, SUR, ORIENTE, OCCIDENTE';
-- ========================================
-- INSERCIÓN COMPLETA DE DATOS MAESTROS
-- Limpia datos existentes y re-inserta todo
-- ========================================

-- Limpiar datos existentes (CASCADE eliminará relaciones)
TRUNCATE TABLE unidad CASCADE;
TRUNCATE TABLE ruta CASCADE;
TRUNCATE TABLE tipo_vehiculo CASCADE;
TRUNCATE TABLE sede CASCADE;

-- ========================================
-- 1. SEDES (9 sedes)
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
('Rio Dulce', 'Río Dulce, Izabal', true);

-- ========================================
-- 2. TIPOS DE VEHÍCULOS (37 tipos)
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
('Otro', true);

-- ========================================
-- 3. RUTAS (62 rutas)
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
('RUTA VAS OR', 'RUTA VAS OR', 'Ruta VAS Oriente', true);

-- ========================================
-- 4. UNIDADES (77 unidades)
-- ========================================
DO $$
DECLARE
    sede_central_id INTEGER;
BEGIN
    SELECT id INTO sede_central_id FROM sede WHERE nombre = 'Central' LIMIT 1;
    
    INSERT INTO unidad (codigo, tipo_unidad, marca, modelo, placa, capacidad_combustible, odometro_actual, combustible_actual, activa, sede_id) VALUES
    -- Motos (7)
    ('M001', 'MOTOCICLETA', 'Honda', 2020, 'M001XXX', 15, 10000, 10.0, true, sede_central_id),
    ('M002', 'MOTOCICLETA', 'Suzuki', 2021, 'M002XXX', 15, 8000, 12.0, true, sede_central_id),
    ('M003', 'MOTOCICLETA', 'Honda', 2019, 'M003XXX', 15, 15000, 8.0, true, sede_central_id),
    ('M004', 'MOTOCICLETA', 'Italika', 2022, 'M004XXX', 15, 5000, 14.0, true, sede_central_id),
    ('M005', 'MOTOCICLETA', 'Suzuki', 2020, 'M005XXX', 15, 12000, 11.0, true, sede_central_id),
    ('M006', 'MOTOCICLETA', 'Honda', 2021, 'M006XXX', 15, 9000, 13.0, true, sede_central_id),
    ('M007', 'MOTOCICLETA', 'Suzuki', 2022, 'M007XXX', 15, 3000, 15.0, true, sede_central_id),
    
    -- Pickups 1100s (36)
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
    
    -- Unidades especiales 1170s (7)
    ('1170', 'CAMIONETA', 'Toyota', 2020, 'P1170XX', 100, 95000, 70.0, true, sede_central_id),
    ('1171', 'CAMIONETA', 'Nissan', 2021, 'P1171XX', 100, 85000, 75.0, true, sede_central_id),
    ('1172', 'CAMIONETA', 'Ford', 2019, 'P1172XX', 100, 105000, 65.0, true, sede_central_id),
    ('1173', 'CAMIONETA', 'Toyota', 2020, 'P1173XX', 100, 90000, 72.0, true, sede_central_id),
    ('1174', 'CAMIONETA', 'Chevrolet', 2021, 'P1174XX', 100, 80000, 78.0, true, sede_central_id),
    ('1175', 'CAMIONETA', 'Nissan', 2019, 'P1175XX', 100, 110000, 60.0, true, sede_central_id),
    ('1176', 'CAMIONETA', 'Toyota', 2020, 'P1176XX', 100, 88000, 74.0, true, sede_central_id),
    
    -- Unidades 00X (26)
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
    
    -- Peatonal (1)
    ('Peatonal', 'PEATONAL', NULL, NULL, NULL, 0, 0, 0.0, true, sede_central_id);
END $$;

-- ========================================
-- RESUMEN
-- ========================================
SELECT 'Sedes insertadas: ' || COUNT(*) FROM sede;
SELECT 'Tipos de vehículo insertados: ' || COUNT(*) FROM tipo_vehiculo;
SELECT 'Rutas insertadas: ' || COUNT(*) FROM ruta;
SELECT 'Unidades insertadas: ' || COUNT(*) FROM unidad;
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
INSERT INTO usuario (username, password_hash, nombre_completo, email, rol_id, activo, created_at, updated_at) VALUES ('admin', '$2a$10$.N5Cg9.FtpnE3Rs32/Eud.BmvcHtdzNFScnrBYbt.HFaeP80xSDyi', 'Administrador Sistema', 'admin@provial.gob.gt', 1, true, NOW(), NOW()) ON CONFLICT (username) DO NOTHING;
INSERT INTO usuario (username, password_hash, nombre_completo, email, rol_id, activo, created_at, updated_at) VALUES ('operaciones', '$2a$10$Q1fOnleGZsQowJXkAJ/Rd.aIpYiIvUCt0BN9JWLbWhJ.2fWGF/DJ6', 'Operaciones Central', 'operaciones@provial.gob.gt', 4, true, NOW(), NOW()) ON CONFLICT (username) DO NOTHING;
INSERT INTO usuario (username, password_hash, nombre_completo, email, rol_id, activo, created_at, updated_at) VALUES ('brigada01', '$2a$10$k2pMwouCrFphH0TWZQUbU.nJGrcb.76l20Omw7qk.kDfsgn9DP1h2', 'Agente Brigada 01', 'brigada01@provial.gob.gt', 3, true, NOW(), NOW()) ON CONFLICT (username) DO NOTHING;

DO $$
DECLARE
    v_usuario_id INTEGER;
    v_unidad_id INTEGER;
    v_ruta_id INTEGER;
    v_turno_id INTEGER;
    v_asignacion_id INTEGER;
BEGIN
    -- 1. Obtener IDs
    SELECT id INTO v_usuario_id FROM usuario WHERE username = 'brigada01';
    IF v_usuario_id IS NULL THEN
        RAISE EXCEPTION 'Usuario brigada01 no encontrado';
    END IF;

    SELECT id INTO v_unidad_id FROM unidad WHERE codigo = '1104';
    IF v_unidad_id IS NULL THEN
        RAISE EXCEPTION 'Unidad 1104 no encontrada';
    END IF;

    SELECT id INTO v_ruta_id FROM ruta WHERE codigo = 'CA-1 Occidente';
    IF v_ruta_id IS NULL THEN
        RAISE EXCEPTION 'Ruta CA-1 Occidente no encontrada';
    END IF;

    -- 2. Crear o obtener turno
    SELECT id INTO v_turno_id FROM turno WHERE fecha = CURRENT_DATE;
    IF v_turno_id IS NULL THEN
        INSERT INTO turno (fecha, estado, creado_por) 
        VALUES (CURRENT_DATE, 'ACTIVO', v_usuario_id) 
        RETURNING id INTO v_turno_id;
        RAISE NOTICE 'Turno creado: %', v_turno_id;
    ELSE
        RAISE NOTICE 'Turno existente: %', v_turno_id;
    END IF;

    -- 3. Crear asignación
    INSERT INTO asignacion_unidad (turno_id, unidad_id, ruta_id, km_inicio, combustible_inicial, combustible_asignado, hora_salida)
    VALUES (v_turno_id, v_unidad_id, v_ruta_id, 150000, 60, 60, '06:00:00')
    RETURNING id INTO v_asignacion_id;
    RAISE NOTICE 'Asignación creada: %', v_asignacion_id;

    -- 4. Asignar tripulación
    INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente)
    VALUES (v_asignacion_id, v_usuario_id, 'PILOTO', true);
    RAISE NOTICE 'Tripulación asignada';

END $$;

-- Aumentar precisión de columnas de kilometraje
ALTER TABLE asignacion_unidad 
    ALTER COLUMN km_inicio TYPE NUMERIC(10,2),
    ALTER COLUMN km_final TYPE NUMERIC(10,2),
    ALTER COLUMN km_recorridos TYPE NUMERIC(10,2);

-- 1. Eliminar vistas dependientes (CASCADE eliminará las que dependen de estas)
DROP VIEW IF EXISTS v_mi_asignacion_hoy CASCADE;
DROP VIEW IF EXISTS v_turnos_completos CASCADE;
DROP VIEW IF EXISTS v_estadisticas_brigadas CASCADE;
DROP VIEW IF EXISTS v_estadisticas_unidades CASCADE;
DROP VIEW IF EXISTS v_disponibilidad_recursos CASCADE;
DROP VIEW IF EXISTS v_situaciones_con_combustible CASCADE;
DROP VIEW IF EXISTS v_mi_unidad_asignada CASCADE;
DROP VIEW IF EXISTS v_mi_salida_activa CASCADE;
DROP VIEW IF EXISTS v_unidades_en_salida CASCADE;
DROP VIEW IF EXISTS v_incidentes_completos CASCADE;
DROP VIEW IF EXISTS v_actividades_completas CASCADE;
DROP VIEW IF EXISTS v_estado_actual_unidades CASCADE;

-- 2. Modificar columnas de kilometraje
ALTER TABLE asignacion_unidad 
    ALTER COLUMN km_inicio TYPE NUMERIC(10,2),
    ALTER COLUMN km_final TYPE NUMERIC(10,2),
    ALTER COLUMN km_recorridos TYPE NUMERIC(10,2);

-- 3. Recrear vistas

-- v_turnos_completos
CREATE OR REPLACE VIEW v_turnos_completos AS
SELECT
    t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
    a.combustible_inicial,
    a.combustible_asignado,
    a.hora_salida,
    a.hora_entrada_estimada,
    (
        SELECT json_agg(
            json_build_object(
                'usuario_id', usr.id,
                'nombre', usr.nombre_completo,
                'rol', tc.rol_tripulacion,
                'presente', tc.presente
            )
            ORDER BY
                CASE tc.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM tripulacion_turno tc
        JOIN usuario usr ON tc.usuario_id = usr.id
        WHERE tc.asignacion_id = a.id
    ) AS tripulacion,
    (
        SELECT json_build_object(
            'km', rh.km_actual,
            'sentido', rh.sentido_actual,
            'novedad', rh.novedad,
            'hora', rh.created_at
        )
        FROM reporte_horario rh
        WHERE rh.asignacion_id = a.id
        ORDER BY rh.created_at DESC
        LIMIT 1
    ) AS ultimo_reporte,
    t.created_at
FROM turno t
JOIN asignacion_unidad a ON t.id = a.turno_id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
ORDER BY t.fecha DESC, u.codigo;

-- v_mi_asignacion_hoy
CREATE OR REPLACE VIEW v_mi_asignacion_hoy AS
SELECT
    usr.id AS usuario_id,
    usr.nombre_completo,
    t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    tc.rol_tripulacion AS mi_rol,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
    a.hora_salida,
    a.hora_entrada_estimada,
    (
        SELECT json_agg(
            json_build_object(
                'nombre', u2.nombre_completo,
                'rol', tc2.rol_tripulacion
            )
            ORDER BY
                CASE tc2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM tripulacion_turno tc2
        JOIN usuario u2 ON tc2.usuario_id = u2.id
        WHERE tc2.asignacion_id = a.id
          AND tc2.usuario_id != usr.id
    ) AS companeros
FROM usuario usr
JOIN tripulacion_turno tc ON usr.id = tc.usuario_id
JOIN asignacion_unidad a ON tc.asignacion_id = a.id
JOIN turno t ON a.turno_id = t.id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
WHERE t.fecha = CURRENT_DATE
  AND t.estado IN ('PLANIFICADO', 'ACTIVO');

-- v_estadisticas_brigadas
CREATE OR REPLACE VIEW v_estadisticas_brigadas AS
SELECT
    u.id AS usuario_id,
    u.nombre_completo,
    u.chapa,
    u.telefono,
    u.sede_id,
    s.nombre AS sede_nombre,
    r.nombre AS rol_nombre,
    COUNT(DISTINCT t.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS turnos_ultimo_mes,
    COUNT(DISTINCT t.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '90 days') AS turnos_ultimo_trimestre,
    MAX(t.fecha) AS ultimo_turno_fecha,
    CURRENT_DATE - MAX(t.fecha) AS dias_desde_ultimo_turno,
    MIN(t.fecha) FILTER (WHERE t.fecha >= CURRENT_DATE) AS proximo_turno_fecha,
    MODE() WITHIN GROUP (ORDER BY tt.rol_tripulacion) AS rol_tripulacion_frecuente,
    u.activo
FROM usuario u
INNER JOIN sede s ON u.sede_id = s.id
INNER JOIN rol r ON u.rol_id = r.id
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id
LEFT JOIN turno t ON au.turno_id = t.id
WHERE r.nombre = 'BRIGADA'
GROUP BY u.id, u.nombre_completo, u.chapa, u.telefono, u.sede_id, s.nombre, r.nombre, u.activo;

-- v_estadisticas_unidades
CREATE OR REPLACE VIEW v_estadisticas_unidades AS
SELECT
    un.id AS unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    un.marca,
    un.modelo,
    un.sede_id,
    s.nombre AS sede_nombre,
    un.activa,
    un.combustible_actual,
    un.capacidad_combustible,
    un.odometro_actual,
    COUNT(DISTINCT au.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS turnos_ultimo_mes,
    COUNT(DISTINCT au.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '90 days') AS turnos_ultimo_trimestre,
    MAX(t.fecha) AS ultimo_turno_fecha,
    CURRENT_DATE - MAX(t.fecha) AS dias_desde_ultimo_uso,
    MIN(t.fecha) FILTER (WHERE t.fecha >= CURRENT_DATE) AS proximo_turno_fecha,
    AVG(cr.combustible_consumido) FILTER (WHERE cr.created_at >= CURRENT_DATE - INTERVAL '30 days') AS consumo_promedio_diario,
    AVG(cr.rendimiento_km_litro) FILTER (WHERE cr.created_at >= CURRENT_DATE - INTERVAL '30 days') AS rendimiento_promedio,
    SUM(au.km_recorridos) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS km_ultimo_mes
FROM unidad un
INNER JOIN sede s ON un.sede_id = s.id
LEFT JOIN asignacion_unidad au ON un.id = au.unidad_id
LEFT JOIN turno t ON au.turno_id = t.id
LEFT JOIN combustible_registro cr ON un.id = cr.unidad_id AND cr.tipo = 'FINAL'
GROUP BY un.id, un.codigo, un.tipo_unidad, un.marca, un.modelo, un.sede_id, s.nombre;

-- v_disponibilidad_recursos
CREATE OR REPLACE VIEW v_disponibilidad_recursos AS
SELECT
    s.id AS sede_id,
    s.nombre AS sede_nombre,
    COUNT(DISTINCT u.id) FILTER (WHERE r.nombre = 'BRIGADA' AND u.activo = TRUE) AS total_brigadas_activas,
    COUNT(DISTINCT tt.usuario_id) FILTER (
        WHERE t.fecha = CURRENT_DATE
        AND r.nombre = 'BRIGADA'
        AND u.activo = TRUE
    ) AS brigadas_en_turno_hoy,
    COUNT(DISTINCT un.id) FILTER (WHERE un.activa = TRUE) AS total_unidades_activas,
    COUNT(DISTINCT au.unidad_id) FILTER (
        WHERE t.fecha = CURRENT_DATE
    ) AS unidades_en_turno_hoy,
    COUNT(DISTINCT u.id) FILTER (
        WHERE r.nombre = 'BRIGADA'
        AND u.activo = TRUE
        AND u.id NOT IN (
            SELECT tt2.usuario_id
            FROM tripulacion_turno tt2
            JOIN asignacion_unidad au2 ON tt2.asignacion_id = au2.id
            JOIN turno t2 ON au2.turno_id = t2.id
            WHERE t2.fecha = CURRENT_DATE
        )
    ) AS brigadas_disponibles_hoy,
    COUNT(DISTINCT un.id) FILTER (
        WHERE un.activa = TRUE
        AND un.id NOT IN (
            SELECT au3.unidad_id
            FROM asignacion_unidad au3
            JOIN turno t3 ON au3.turno_id = t3.id
            WHERE t3.fecha = CURRENT_DATE
        )
    ) AS unidades_disponibles_hoy
FROM sede s
LEFT JOIN usuario u ON s.id = u.sede_id
LEFT JOIN rol r ON u.rol_id = r.id
LEFT JOIN unidad un ON s.id = un.sede_id
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id AND un.id = au.unidad_id
LEFT JOIN turno t ON au.turno_id = t.id
GROUP BY s.id, s.nombre;

-- v_situaciones_con_combustible
CREATE OR REPLACE VIEW v_situaciones_con_combustible AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    s.combustible,
    s.combustible_fraccion,
    s.kilometraje_unidad,
    s.created_at,
    LAG(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS combustible_anterior,
    s.combustible - LAG(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS consumo,
    s.kilometraje_unidad - LAG(s.kilometraje_unidad) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS km_recorridos,
    EXTRACT(EPOCH FROM (s.created_at - LAG(s.created_at) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at))) / 60 AS minutos_desde_anterior,
    s.turno_id,
    t.fecha AS turno_fecha
FROM situacion s
LEFT JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN turno t ON s.turno_id = t.id
WHERE s.combustible IS NOT NULL
ORDER BY s.unidad_id, s.created_at;

-- v_mi_unidad_asignada
CREATE OR REPLACE VIEW v_mi_unidad_asignada AS
SELECT
    u.id AS brigada_id,
    u.username,
    u.chapa,
    u.nombre_completo,
    bu.id AS asignacion_id,
    bu.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    bu.rol_tripulacion AS mi_rol,
    bu.fecha_asignacion,
    bu.activo,
    (
        SELECT json_agg(
            json_build_object(
                'brigada_id', u2.id,
                'chapa', u2.chapa,
                'nombre', u2.nombre_completo,
                'rol', bu2.rol_tripulacion
            )
            ORDER BY
                CASE bu2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM brigada_unidad bu2
        JOIN usuario u2 ON bu2.brigada_id = u2.id
        WHERE bu2.unidad_id = bu.unidad_id
          AND bu2.activo = TRUE
          AND bu2.brigada_id != u.id
    ) AS companeros
FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id
JOIN unidad un ON bu.unidad_id = un.id
WHERE bu.activo = TRUE;

-- v_mi_salida_activa
CREATE OR REPLACE VIEW v_mi_salida_activa AS
SELECT
    u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,
    s.id AS salida_id,
    s.unidad_id,
    un.codigo AS unidad_codigo,
    s.estado,
    s.fecha_hora_salida,
    s.fecha_hora_regreso,
    EXTRACT(EPOCH FROM (COALESCE(s.fecha_hora_regreso, NOW()) - s.fecha_hora_salida)) / 3600 AS horas_salida,
    s.ruta_inicial_id AS ruta_id, -- Added ruta_id
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.combustible_inicial,
    s.tripulacion,
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at ASC
        LIMIT 1
    ) AS primera_situacion
FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id AND bu.activo = TRUE
JOIN unidad un ON bu.unidad_id = un.id
JOIN salida_unidad s ON un.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id;

-- v_unidades_en_salida
CREATE OR REPLACE VIEW v_unidades_en_salida AS
SELECT
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.id AS salida_id,
    s.fecha_hora_salida,
    EXTRACT(EPOCH FROM (NOW() - s.fecha_hora_salida)) / 3600 AS horas_en_salida,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.tripulacion,
    (
        SELECT COUNT(*)
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
    ) AS total_situaciones,
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'km', sit.km,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at DESC
        LIMIT 1
    ) AS ultima_situacion
FROM unidad u
JOIN salida_unidad s ON u.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id
ORDER BY s.fecha_hora_salida DESC;

-- v_incidentes_completos
CREATE OR REPLACE VIEW v_incidentes_completos AS
SELECT 
    i.*,
    th.nombre as tipo_hecho,
    th.color as tipo_hecho_color,
    th.icono as tipo_hecho_icono,
    sth.nombre as subtipo_hecho,
    r.codigo as ruta_codigo,
    r.nombre as ruta_nombre,
    u.codigo as unidad_codigo,
    b.nombre_completo as brigada_nombre,
    c.nombre_completo as creado_por_nombre
FROM incidente i
JOIN tipo_hecho th ON i.tipo_hecho_id = th.id
LEFT JOIN subtipo_hecho sth ON i.subtipo_hecho_id = sth.id
JOIN ruta r ON i.ruta_id = r.id
LEFT JOIN unidad u ON i.unidad_id = u.id
LEFT JOIN usuario b ON i.brigada_id = b.id
JOIN usuario c ON i.creado_por = c.id;

-- v_actividades_completas
CREATE OR REPLACE VIEW v_actividades_completas AS
SELECT
    a.id,
    a.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.nombre AS sede_nombre,
    ta.nombre AS tipo_actividad,
    ta.color AS tipo_actividad_color,
    a.hora_inicio,
    a.hora_fin,
    EXTRACT(EPOCH FROM (COALESCE(a.hora_fin, NOW()) - a.hora_inicio))/60 AS duracion_min,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km,
    a.sentido,
    a.incidente_id,
    i.numero_reporte AS incidente_numero,
    usr.nombre_completo AS registrado_por_nombre,
    a.observaciones,
    a.created_at
FROM actividad_unidad a
JOIN unidad u ON a.unidad_id = u.id
JOIN sede s ON u.sede_id = s.id
JOIN tipo_actividad ta ON a.tipo_actividad_id = ta.id
LEFT JOIN ruta r ON a.ruta_id = r.id
LEFT JOIN incidente i ON a.incidente_id = i.id
JOIN usuario usr ON a.registrado_por = usr.id;

-- v_estado_actual_unidades
CREATE OR REPLACE VIEW v_estado_actual_unidades AS
SELECT DISTINCT ON (u.id)
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.nombre AS sede_nombre,
    u.activa,
    ta.nombre AS actividad_actual,
    ta.color AS actividad_color,
    a.hora_inicio AS desde,
    r.codigo AS ruta_codigo,
    a.km,
    a.sentido,
    a.observaciones,
    i.numero_reporte AS incidente_numero,
    i.estado AS incidente_estado
FROM unidad u
JOIN sede s ON u.sede_id = s.id
LEFT JOIN LATERAL (
    SELECT *
    FROM actividad_unidad au
    WHERE au.unidad_id = u.id
      AND au.hora_fin IS NULL
    ORDER BY au.hora_inicio DESC
    LIMIT 1
) a ON TRUE
LEFT JOIN tipo_actividad ta ON a.tipo_actividad_id = ta.id
LEFT JOIN ruta r ON a.ruta_id = r.id
LEFT JOIN incidente i ON a.incidente_id = i.id
ORDER BY u.id;

-- Asignación permanente para brigada01
INSERT INTO brigada_unidad (brigada_id, unidad_id, rol_tripulacion, asignado_por, activo)
VALUES (
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    (SELECT id FROM unidad WHERE codigo = '1104'),
    'PILOTO',
    (SELECT id FROM usuario WHERE username = 'admin'),
    TRUE
)
ON CONFLICT DO NOTHING;
-- Script básico para configurar brigada01

-- 1. Configurar usuario brigada01 con grupo y acceso
UPDATE usuario
SET
    grupo = 1,
    fecha_inicio_ciclo = CURRENT_DATE,
    acceso_app_activo = TRUE,
    exento_grupos = FALSE
WHERE username = 'brigada01';

-- 2. Asegurar que hay un turno para hoy y asignar brigada01
DO $$
DECLARE
    v_turno_id INT;
    v_unidad_id INT;
    v_usuario_id INT;
    v_asignacion_id INT;
    v_ruta_id INT;
BEGIN
    -- Obtener turno de hoy o crear uno
    SELECT id INTO v_turno_id
    FROM turno
    WHERE fecha = CURRENT_DATE;

    IF v_turno_id IS NULL THEN
        INSERT INTO turno (fecha, estado, observaciones, creado_por)
        VALUES (CURRENT_DATE, 'ACTIVO', 'Turno para pruebas', 1)
        RETURNING id INTO v_turno_id;
    END IF;

    -- Obtener una unidad y ruta
    SELECT id INTO v_unidad_id FROM unidad WHERE activa = TRUE LIMIT 1;
    SELECT id INTO v_ruta_id FROM ruta LIMIT 1;

    -- Obtener el ID del usuario brigada01
    SELECT id INTO v_usuario_id FROM usuario WHERE username = 'brigada01';

    -- Crear o actualizar asignación
    INSERT INTO asignacion_unidad (
        turno_id,
        unidad_id,
        ruta_id,
        km_inicio,
        km_final,
        sentido,
        combustible_inicial,
        hora_salida
    )
    VALUES (
        v_turno_id,
        v_unidad_id,
        v_ruta_id,
        0,
        999,
        'AMBOS',
        80,
        '06:00:00'::TIME
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_asignacion_id;

    -- Si no se insertó (porque ya existía), obtener el ID
    IF v_asignacion_id IS NULL THEN
        SELECT id INTO v_asignacion_id
        FROM asignacion_unidad
        WHERE turno_id = v_turno_id
          AND unidad_id = v_unidad_id
        LIMIT 1;
    END IF;

    -- Agregar brigada01 a la tripulación si no existe
    INSERT INTO tripulacion_turno (
        asignacion_id,
        usuario_id,
        rol_tripulacion,
        presente
    )
    VALUES (
        v_asignacion_id,
        v_usuario_id,
        'PILOTO',
        TRUE
    )
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Usuario brigada01 configurado';
    RAISE NOTICE 'Turno ID: %, Unidad ID: %, Asignación ID: %', v_turno_id, v_unidad_id, v_asignacion_id;
END $$;

-- 3. Verificar configuración final
SELECT
    u.username,
    u.grupo,
    u.acceso_app_activo,
    t.fecha AS turno_fecha,
    un.codigo AS unidad,
    r.codigo AS ruta,
    tt.rol_tripulacion
FROM usuario u
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id
LEFT JOIN turno t ON au.turno_id = t.id
LEFT JOIN unidad un ON au.unidad_id = un.id
LEFT JOIN ruta r ON au.ruta_id = r.id
WHERE u.username = 'brigada01'
  AND (t.fecha = CURRENT_DATE OR t.fecha IS NULL)
LIMIT 1;
-- Script para crear tablas faltantes SIN dependencias de PostGIS

-- ========================================
-- 1. TABLA: SITUACION (sin índice PostGIS)
-- ========================================

CREATE TABLE IF NOT EXISTS situacion (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    numero_situacion VARCHAR(50) UNIQUE,

    tipo_situacion VARCHAR(50) NOT NULL CHECK (tipo_situacion IN (
        'SALIDA_SEDE',
        'PATRULLAJE',
        'CAMBIO_RUTA',
        'PARADA_ESTRATEGICA',
        'COMIDA',
        'DESCANSO',
        'INCIDENTE',
        'REGULACION_TRAFICO',
        'ASISTENCIA_VEHICULAR',
        'OTROS'
    )),
    estado VARCHAR(20) DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA', 'CERRADA', 'CANCELADA')),

    asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,
    turno_id INT REFERENCES turno(id) ON DELETE CASCADE,

    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km DECIMAL(6,2),
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE', 'AMBOS')),
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    ubicacion_manual BOOLEAN DEFAULT FALSE,

    combustible DECIMAL(5,2),
    kilometraje_unidad DECIMAL(8,1),

    tripulacion_confirmada JSONB,

    descripcion TEXT,
    observaciones TEXT,

    incidente_id INT REFERENCES incidente(id) ON DELETE SET NULL,

    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    actualizado_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices (sin PostGIS)
CREATE INDEX IF NOT EXISTS idx_situacion_unidad ON situacion(unidad_id);
CREATE INDEX IF NOT EXISTS idx_situacion_turno ON situacion(turno_id);
CREATE INDEX IF NOT EXISTS idx_situacion_asignacion ON situacion(asignacion_id);
CREATE INDEX IF NOT EXISTS idx_situacion_tipo ON situacion(tipo_situacion);
CREATE INDEX IF NOT EXISTS idx_situacion_estado ON situacion(estado);
CREATE INDEX IF NOT EXISTS idx_situacion_created ON situacion(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_situacion_incidente ON situacion(incidente_id) WHERE incidente_id IS NOT NULL;

-- Trigger para updated_at
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'update_situacion_updated_at'
    ) THEN
        CREATE TRIGGER update_situacion_updated_at
            BEFORE UPDATE ON situacion
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ========================================
-- 2. TABLA: DETALLE_SITUACION
-- ========================================

CREATE TABLE IF NOT EXISTS detalle_situacion (
    id BIGSERIAL PRIMARY KEY,
    situacion_id BIGINT NOT NULL REFERENCES situacion(id) ON DELETE CASCADE,

    tipo_detalle VARCHAR(50) NOT NULL CHECK (tipo_detalle IN (
        'VEHICULO',
        'AUTORIDAD',
        'RECURSO',
        'VICTIMA',
        'GRUA',
        'ASEGURADORA',
        'OTRO'
    )),

    datos JSONB NOT NULL,

    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_detalle_situacion ON detalle_situacion(situacion_id);
CREATE INDEX IF NOT EXISTS idx_detalle_tipo ON detalle_situacion(tipo_detalle);

-- ========================================
-- 3. AGREGAR COLUMNAS A USUARIO (si no existen)
-- ========================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'grupo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN grupo SMALLINT CHECK (grupo IN (1, 2));
        CREATE INDEX idx_usuario_grupo ON usuario(grupo) WHERE grupo IS NOT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'fecha_inicio_ciclo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN fecha_inicio_ciclo DATE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'acceso_app_activo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN acceso_app_activo BOOLEAN DEFAULT TRUE;
        CREATE INDEX idx_usuario_acceso ON usuario(acceso_app_activo);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'exento_grupos'
    ) THEN
        ALTER TABLE usuario ADD COLUMN exento_grupos BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- ========================================
-- 4. TABLA: CALENDARIO_GRUPO
-- ========================================

CREATE TABLE IF NOT EXISTS calendario_grupo (
    id SERIAL PRIMARY KEY,
    grupo SMALLINT NOT NULL CHECK (grupo IN (1, 2)),
    fecha DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('TRABAJO', 'DESCANSO')),
    observaciones TEXT,

    creado_por INT REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(grupo, fecha)
);

CREATE INDEX IF NOT EXISTS idx_calendario_grupo_fecha ON calendario_grupo(grupo, fecha DESC);
CREATE INDEX IF NOT EXISTS idx_calendario_grupo_estado ON calendario_grupo(estado, fecha);

-- ========================================
-- 5. TABLA: CONTROL_ACCESO_APP
-- ========================================

CREATE TABLE IF NOT EXISTS control_acceso_app (
    id SERIAL PRIMARY KEY,

    usuario_id INT REFERENCES usuario(id) ON DELETE CASCADE,
    grupo SMALLINT CHECK (grupo IN (1, 2)),
    unidad_id INT REFERENCES unidad(id) ON DELETE CASCADE,
    sede_id INT REFERENCES sede(id) ON DELETE CASCADE,

    acceso_permitido BOOLEAN NOT NULL DEFAULT TRUE,
    motivo TEXT,

    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,

    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CHECK (
        usuario_id IS NOT NULL OR
        grupo IS NOT NULL OR
        unidad_id IS NOT NULL OR
        sede_id IS NOT NULL
    )
);

CREATE INDEX IF NOT EXISTS idx_control_acceso_usuario ON control_acceso_app(usuario_id) WHERE usuario_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_control_acceso_grupo ON control_acceso_app(grupo) WHERE grupo IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_control_acceso_vigencia ON control_acceso_app(fecha_inicio, fecha_fin);

-- ========================================
-- 6. VISTAS
-- ========================================

-- Vista: Estado de grupos HOY
CREATE OR REPLACE VIEW v_estado_grupos_hoy AS
SELECT
    grupo,
    estado,
    CASE WHEN estado = 'TRABAJO' THEN TRUE ELSE FALSE END AS esta_de_turno
FROM calendario_grupo
WHERE fecha = CURRENT_DATE;

-- Vista: Situaciones completas
CREATE OR REPLACE VIEW v_situaciones_completas AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.ubicacion_manual,
    s.combustible,
    s.kilometraje_unidad,
    s.tripulacion_confirmada,
    s.descripcion,
    s.observaciones,
    s.incidente_id,
    s.turno_id,
    t.fecha AS turno_fecha,
    s.asignacion_id,
    s.creado_por,
    uc.nombre_completo AS creado_por_nombre,
    s.created_at,
    s.updated_at
FROM situacion s
LEFT JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN turno t ON s.turno_id = t.id
LEFT JOIN usuario uc ON s.creado_por = uc.id;

-- ========================================
-- 7. FUNCIONES
-- ========================================

-- Función: Verificar acceso a la app
CREATE OR REPLACE FUNCTION verificar_acceso_app(p_usuario_id INT)
RETURNS TABLE (
    tiene_acceso BOOLEAN,
    motivo_bloqueo TEXT
) AS $$
DECLARE
    v_grupo SMALLINT;
    v_acceso_individual BOOLEAN;
    v_grupo_en_descanso BOOLEAN;
    v_control_activo RECORD;
BEGIN
    -- Obtener datos del usuario
    SELECT grupo, COALESCE(acceso_app_activo, TRUE)
    INTO v_grupo, v_acceso_individual
    FROM usuario
    WHERE id = p_usuario_id;

    -- 1. Verificar acceso individual del usuario
    IF v_acceso_individual = FALSE THEN
        RETURN QUERY SELECT FALSE, 'Acceso individual desactivado';
        RETURN;
    END IF;

    -- 2. Verificar si el grupo está en descanso
    IF v_grupo IS NOT NULL THEN
        SELECT NOT COALESCE(esta_de_turno, TRUE)
        INTO v_grupo_en_descanso
        FROM v_estado_grupos_hoy
        WHERE grupo = v_grupo;

        IF v_grupo_en_descanso THEN
            RETURN QUERY SELECT FALSE, 'Grupo en descanso';
            RETURN;
        END IF;
    END IF;

    -- 3. Verificar controles de acceso específicos
    SELECT *
    INTO v_control_activo
    FROM control_acceso_app
    WHERE usuario_id = p_usuario_id
      AND acceso_permitido = FALSE
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    LIMIT 1;

    IF v_control_activo IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, v_control_activo.motivo;
        RETURN;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Función: Generar calendario de grupos
CREATE OR REPLACE FUNCTION generar_calendario_grupos(
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
RETURNS INT AS $$
DECLARE
    v_fecha DATE;
    v_dias_transcurridos INT;
    v_estado_grupo1 VARCHAR(20);
    v_estado_grupo2 VARCHAR(20);
    v_registros_creados INT := 0;
BEGIN
    v_fecha := p_fecha_inicio;

    WHILE v_fecha <= p_fecha_fin LOOP
        v_dias_transcurridos := v_fecha - DATE '2025-01-01';

        IF MOD(v_dias_transcurridos, 16) < 8 THEN
            v_estado_grupo1 := 'TRABAJO';
            v_estado_grupo2 := 'DESCANSO';
        ELSE
            v_estado_grupo1 := 'DESCANSO';
            v_estado_grupo2 := 'TRABAJO';
        END IF;

        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (1, v_fecha, v_estado_grupo1, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (2, v_fecha, v_estado_grupo2, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        v_registros_creados := v_registros_creados + 2;
        v_fecha := v_fecha + INTERVAL '1 day';
    END LOOP;

    RETURN v_registros_creados;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 8. GENERAR CALENDARIO DE GRUPOS
-- ========================================

SELECT generar_calendario_grupos((CURRENT_DATE - INTERVAL '30 days')::DATE, (CURRENT_DATE + INTERVAL '90 days')::DATE);
-- Script para arreglar problemas de la app móvil

-- ========================================
-- 1. ELIMINAR ÍNDICES QUE DEPENDEN DE POSTGIS
-- ========================================

DROP INDEX IF EXISTS idx_situacion_ubicacion;

-- ========================================
-- 2. CREAR VISTA V_SITUACIONES_COMPLETAS (si no existe)
-- ========================================

CREATE OR REPLACE VIEW v_situaciones_completas AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.ubicacion_manual,
    s.combustible,
    s.kilometraje_unidad,
    s.tripulacion_confirmada,
    s.descripcion,
    s.observaciones,
    s.incidente_id,
    s.turno_id,
    t.fecha AS turno_fecha,
    s.asignacion_id,
    s.creado_por,
    uc.nombre_completo AS creado_por_nombre,
    s.created_at,
    s.updated_at
FROM situacion s
LEFT JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN turno t ON s.turno_id = t.id
LEFT JOIN usuario uc ON s.creado_por = uc.id;

COMMENT ON VIEW v_situaciones_completas IS 'Vista completa de situaciones con datos relacionados';

-- ========================================
-- 3. ASEGURAR QUE LA TABLA USUARIO TENGA LAS COLUMNAS NECESARIAS
-- ========================================

DO $$
BEGIN
    -- Agregar columna grupo si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'grupo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN grupo SMALLINT CHECK (grupo IN (1, 2));
    END IF;

    -- Agregar columna fecha_inicio_ciclo si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'fecha_inicio_ciclo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN fecha_inicio_ciclo DATE;
    END IF;

    -- Agregar columna acceso_app_activo si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'acceso_app_activo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN acceso_app_activo BOOLEAN DEFAULT TRUE;
    END IF;

    -- Agregar columna exento_grupos si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'exento_grupos'
    ) THEN
        ALTER TABLE usuario ADD COLUMN exento_grupos BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- ========================================
-- 4. CONFIGURAR USUARIO BRIGADA01
-- ========================================

-- Actualizar usuario brigada01 para que tenga grupo y acceso
UPDATE usuario
SET
    grupo = 1,
    fecha_inicio_ciclo = CURRENT_DATE,
    acceso_app_activo = TRUE,
    exento_grupos = FALSE
WHERE username = 'brigada01';

-- ========================================
-- 5. ASIGNAR UNIDAD Y TRIPULACIÓN A BRIGADA01
-- ========================================

-- Primero, verificar que existe un turno para hoy
DO $$
DECLARE
    v_turno_id INT;
    v_unidad_id INT;
    v_usuario_id INT;
    v_asignacion_id INT;
BEGIN
    -- Obtener turno de hoy o crear uno
    SELECT id INTO v_turno_id
    FROM turno
    WHERE fecha = CURRENT_DATE;

    IF v_turno_id IS NULL THEN
        INSERT INTO turno (fecha, estado, observaciones, creado_por)
        VALUES (CURRENT_DATE, 'ACTIVO', 'Turno para pruebas', 1)
        RETURNING id INTO v_turno_id;
    END IF;

    -- Obtener una unidad (la primera disponible)
    SELECT id INTO v_unidad_id FROM unidad LIMIT 1;

    -- Obtener el ID del usuario brigada01
    SELECT id INTO v_usuario_id FROM usuario WHERE username = 'brigada01';

    -- Verificar si ya tiene asignación hoy
    SELECT id INTO v_asignacion_id
    FROM asignacion_unidad
    WHERE turno_id = v_turno_id
      AND unidad_id = v_unidad_id;

    -- Si no existe asignación, crear una
    IF v_asignacion_id IS NULL THEN
        -- Crear asignación de unidad
        INSERT INTO asignacion_unidad (
            turno_id,
            unidad_id,
            ruta_asignada_id,
            hora_inicio_asignada,
            hora_fin_asignada,
            estado,
            creado_por
        )
        VALUES (
            v_turno_id,
            v_unidad_id,
            (SELECT id FROM ruta LIMIT 1),  -- Primera ruta disponible
            '06:00:00'::TIME,
            '18:00:00'::TIME,
            'ASIGNADA',
            1
        )
        RETURNING id INTO v_asignacion_id;
    END IF;

    -- Verificar si ya existe tripulación para brigada01
    IF NOT EXISTS (
        SELECT 1 FROM tripulacion_unidad
        WHERE asignacion_id = v_asignacion_id
          AND usuario_id = v_usuario_id
    ) THEN
        -- Agregar brigada01 a la tripulación como piloto
        INSERT INTO tripulacion_unidad (
            asignacion_id,
            usuario_id,
            es_piloto,
            hora_entrada,
            estado,
            creado_por
        )
        VALUES (
            v_asignacion_id,
            v_usuario_id,
            TRUE,  -- Es piloto
            NOW(),
            'PRESENTE',
            1
        );
    END IF;
END $$;

-- ========================================
-- 6. CREAR CALENDARIO DE GRUPOS SI NO EXISTE
-- ========================================

DO $$
BEGIN
    -- Solo si existe la función generar_calendario_grupos
    IF EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'generar_calendario_grupos'
    ) THEN
        -- Generar calendario para los próximos 90 días si no existe
        IF NOT EXISTS (SELECT 1 FROM calendario_grupo WHERE fecha = CURRENT_DATE) THEN
            PERFORM generar_calendario_grupos(CURRENT_DATE, CURRENT_DATE + INTERVAL '90 days');
        END IF;
    END IF;
END $$;

-- ========================================
-- 7. VERIFICAR CONFIGURACIÓN
-- ========================================

-- Mostrar configuración del usuario brigada01
SELECT
    id,
    username,
    nombre_completo,
    rol,
    grupo,
    fecha_inicio_ciclo,
    acceso_app_activo,
    exento_grupos,
    activo
FROM usuario
WHERE username = 'brigada01';

-- Mostrar asignación de hoy
SELECT
    au.id AS asignacion_id,
    u.codigo AS unidad_codigo,
    r.codigo AS ruta_codigo,
    t.fecha AS turno_fecha,
    au.estado AS asignacion_estado
FROM asignacion_unidad au
JOIN unidad u ON au.unidad_id = u.id
JOIN turno t ON au.turno_id = t.id
LEFT JOIN ruta r ON au.ruta_asignada_id = r.id
WHERE t.fecha = CURRENT_DATE
  AND EXISTS (
      SELECT 1 FROM tripulacion_unidad tu
      WHERE tu.asignacion_id = au.id
        AND tu.usuario_id = (SELECT id FROM usuario WHERE username = 'brigada01')
  );

-- Mostrar tripulación
SELECT
    tu.id,
    u.nombre_completo,
    tu.es_piloto,
    tu.estado,
    tu.hora_entrada
FROM tripulacion_unidad tu
JOIN usuario u ON tu.usuario_id = u.id
JOIN asignacion_unidad au ON tu.asignacion_id = au.id
JOIN turno t ON au.turno_id = t.id
WHERE t.fecha = CURRENT_DATE
  AND u.username = 'brigada01';
-- Script simple para configurar usuario brigada01

-- 1. Configurar usuario brigada01
UPDATE usuario
SET
    grupo = 1,
    fecha_inicio_ciclo = CURRENT_DATE,
    acceso_app_activo = TRUE,
    exento_grupos = FALSE
WHERE username = 'brigada01';

-- 2. Asegurar que hay un turno para hoy
DO $$
DECLARE
    v_turno_id INT;
    v_unidad_id INT;
    v_usuario_id INT;
    v_asignacion_id INT;
BEGIN
    -- Obtener turno de hoy o crear uno
    SELECT id INTO v_turno_id
    FROM turno
    WHERE fecha = CURRENT_DATE;

    IF v_turno_id IS NULL THEN
        INSERT INTO turno (fecha, estado, observaciones, creado_por)
        VALUES (CURRENT_DATE, 'ACTIVO', 'Turno para pruebas', 1)
        RETURNING id INTO v_turno_id;
    END IF;

    -- Obtener una unidad (la primera disponible)
    SELECT id INTO v_unidad_id FROM unidad WHERE activa = TRUE LIMIT 1;

    -- Obtener el ID del usuario brigada01
    SELECT id INTO v_usuario_id FROM usuario WHERE username = 'brigada01';

    -- Verificar si ya tiene asignación hoy
    SELECT id INTO v_asignacion_id
    FROM asignacion_unidad
    WHERE turno_id = v_turno_id
      AND unidad_id = v_unidad_id;

    -- Si no existe asignación, crear una
    IF v_asignacion_id IS NULL THEN
        -- Crear asignación de unidad
        INSERT INTO asignacion_unidad (
            turno_id,
            unidad_id,
            ruta_asignada_id,
            hora_inicio_asignada,
            hora_fin_asignada,
            estado,
            creado_por
        )
        VALUES (
            v_turno_id,
            v_unidad_id,
            (SELECT id FROM ruta LIMIT 1),
            '06:00:00'::TIME,
            '18:00:00'::TIME,
            'ASIGNADA',
            1
        )
        RETURNING id INTO v_asignacion_id;
    END IF;

    -- Verificar si ya existe tripulación para brigada01 en la asignación
    IF NOT EXISTS (
        SELECT 1 FROM tripulacion_turno
        WHERE asignacion_id = v_asignacion_id
          AND usuario_id = v_usuario_id
    ) THEN
        -- Agregar brigada01 a la tripulación
        INSERT INTO tripulacion_turno (
            asignacion_id,
            usuario_id,
            rol_tripulacion,
            presente
        )
        VALUES (
            v_asignacion_id,
            v_usuario_id,
            'PILOTO',
            TRUE
        );
    END IF;

    RAISE NOTICE 'Usuario brigada01 configurado correctamente';
    RAISE NOTICE 'Turno ID: %', v_turno_id;
    RAISE NOTICE 'Unidad ID: %', v_unidad_id;
    RAISE NOTICE 'Asignación ID: %', v_asignacion_id;
END $$;

-- 3. Verificar configuración
SELECT
    'Usuario' AS tipo,
    id::TEXT,
    username AS detalle,
    grupo::TEXT AS info1,
    acceso_app_activo::TEXT AS info2
FROM usuario
WHERE username = 'brigada01'

UNION ALL

SELECT
    'Turno' AS tipo,
    t.id::TEXT,
    t.fecha::TEXT AS detalle,
    t.estado AS info1,
    '' AS info2
FROM turno t
WHERE t.fecha = CURRENT_DATE

UNION ALL

SELECT
    'Asignación' AS tipo,
    au.id::TEXT,
    u.codigo AS detalle,
    au.estado AS info1,
    r.codigo AS info2
FROM asignacion_unidad au
JOIN turno t ON au.turno_id = t.id
JOIN unidad u ON au.unidad_id = u.id
LEFT JOIN ruta r ON au.ruta_asignada_id = r.id
WHERE t.fecha = CURRENT_DATE

UNION ALL

SELECT
    'Tripulación' AS tipo,
    tt.id::TEXT,
    us.username AS detalle,
    tt.rol_tripulacion AS info1,
    tt.presente::TEXT AS info2
FROM tripulacion_turno tt
JOIN usuario us ON tt.usuario_id = us.id
JOIN asignacion_unidad au ON tt.asignacion_id = au.id
JOIN turno t ON au.turno_id = t.id
WHERE t.fecha = CURRENT_DATE
  AND us.username = 'brigada01';
