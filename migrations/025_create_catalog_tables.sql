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
