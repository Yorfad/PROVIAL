-- Script que se ejecuta automáticamente al crear el contenedor de PostgreSQL
-- Habilita las extensiones necesarias

-- UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Búsquedas fuzzy
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- PostGIS (comentar si no se necesita)
-- CREATE EXTENSION IF NOT EXISTS "postgis";

SELECT 'Extensiones habilitadas correctamente' AS status;
