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
