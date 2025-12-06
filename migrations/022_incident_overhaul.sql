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
