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
