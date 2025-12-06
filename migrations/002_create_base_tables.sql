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
