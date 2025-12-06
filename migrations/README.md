# Migraciones de Base de Datos - Sistema Provial

Este directorio contiene todas las migraciones de PostgreSQL para el sistema Provial.

## Archivos de Migración

Las migraciones están numeradas y deben ejecutarse en orden:

1. **001_create_extensions.sql** - Habilita extensiones necesarias (UUID, pg_trgm, PostGIS)
2. **002_create_base_tables.sql** - Tablas base (usuarios, roles, sedes, unidades, brigadas)
3. **003_create_catalog_tables.sql** - Catálogos (rutas, tipos de hechos, vehículos, etc.)
4. **004_create_incidents_tables.sql** - Tablas de incidentes (core del sistema)
5. **005_create_activities_tables.sql** - Actividades de unidades
6. **006_create_audit_tables.sql** - Tabla de auditoría
7. **007_create_triggers_functions.sql** - Triggers y funciones PL/pgSQL
8. **008_create_views.sql** - Vistas y vistas materializadas
9. **009_create_seed_data.sql** - Datos de prueba (OPCIONAL, solo dev/testing)

## Ejecución de Migraciones

### Opción 1: Script automatizado (Linux/Mac)

```bash
chmod +x run_migrations.sh
./run_migrations.sh postgresql://usuario:password@localhost:5432/provial_db
```

### Opción 2: Script automatizado (Windows PowerShell)

```powershell
$env:DATABASE_URL="postgresql://postgres:postgres@localhost:5432/provial_db"
Get-ChildItem -Path . -Filter "*.sql" | Sort-Object Name | ForEach-Object {
    Write-Host "Ejecutando: $($_.Name)"
    psql $env:DATABASE_URL -f $_.FullName
}
```

### Opción 3: Manual con psql

```bash
# Conectar a PostgreSQL
psql -U postgres -d provial_db

# Ejecutar cada migración en orden
\i 001_create_extensions.sql
\i 002_create_base_tables.sql
\i 003_create_catalog_tables.sql
\i 004_create_incidents_tables.sql
\i 005_create_activities_tables.sql
\i 006_create_audit_tables.sql
\i 007_create_triggers_functions.sql
\i 008_create_views.sql

# Opcional: Datos de prueba
\i 009_create_seed_data.sql
```

### Opción 4: Desde Docker

```bash
docker exec -i postgres_container psql -U postgres -d provial_db < 001_create_extensions.sql
docker exec -i postgres_container psql -U postgres -d provial_db < 002_create_base_tables.sql
# ... etc
```

## Crear la Base de Datos

Antes de ejecutar las migraciones, crear la base de datos:

```bash
# Desde línea de comandos
createdb -U postgres provial_db

# O desde psql
CREATE DATABASE provial_db
    WITH ENCODING 'UTF8'
    LC_COLLATE = 'es_GT.UTF-8'
    LC_CTYPE = 'es_GT.UTF-8'
    TEMPLATE = template0;
```

## Verificación

Después de ejecutar las migraciones, verificar:

```sql
-- Ver todas las tablas
\dt

-- Ver vistas
\dv

-- Ver vistas materializadas
\dm

-- Ver funciones
\df

-- Ver triggers
\dy

-- Contar registros de catálogos
SELECT 'rol' AS tabla, COUNT(*) FROM rol
UNION ALL
SELECT 'sede', COUNT(*) FROM sede
UNION ALL
SELECT 'ruta', COUNT(*) FROM ruta
UNION ALL
SELECT 'tipo_hecho', COUNT(*) FROM tipo_hecho
UNION ALL
SELECT 'subtipo_hecho', COUNT(*) FROM subtipo_hecho
UNION ALL
SELECT 'tipo_vehiculo', COUNT(*) FROM tipo_vehiculo
UNION ALL
SELECT 'tipo_actividad', COUNT(*) FROM tipo_actividad
UNION ALL
SELECT 'motivo_no_atendido', COUNT(*) FROM motivo_no_atendido;
```

## Datos de Prueba

El archivo `009_create_seed_data.sql` crea usuarios y datos de ejemplo:

**Usuarios de prueba:**
- **admin** / password123 (Admin)
- **cop01** / password123 (COP)
- **cop02** / password123 (COP)
- **brigada01** / password123 (Brigada)
- **brigada02** / password123 (Brigada)
- **operaciones01** / password123 (Operaciones)
- **accidentologia01** / password123 (Accidentología)
- **mando01** / password123 (Mandos)

⚠️ **IMPORTANTE:** NO ejecutar `009_create_seed_data.sql` en producción. Solo para desarrollo/testing.

## Mantenimiento de Vistas Materializadas

Las vistas materializadas deben refrescarse periódicamente:

```sql
-- Refresh manual (con bloqueo)
REFRESH MATERIALIZED VIEW mv_estadisticas_diarias;
REFRESH MATERIALIZED VIEW mv_no_atendidos_por_motivo;

-- Refresh concurrente (sin bloqueo, requiere índice único)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_estadisticas_diarias;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_no_atendidos_por_motivo;
```

**Recomendación:** Configurar cron job para refrescar nightly:

```bash
# Crontab: Ejecutar diariamente a las 00:30
30 0 * * * psql $DATABASE_URL -c "REFRESH MATERIALIZED VIEW CONCURRENTLY mv_estadisticas_diarias; REFRESH MATERIALIZED VIEW CONCURRENTLY mv_no_atendidos_por_motivo;"
```

## Rollback

Si necesitas revertir todas las migraciones (PELIGRO: elimina todos los datos):

```sql
-- Eliminar todas las tablas
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

-- Luego volver a ejecutar migraciones
```

## Troubleshooting

### Error: "extension already exists"
No es un problema, PostgreSQL ignora `IF NOT EXISTS`. Continuar.

### Error: "permission denied"
El usuario necesita permisos de superuser para crear extensiones:
```sql
ALTER USER tu_usuario WITH SUPERUSER;
```

### Error: "relation already exists"
Ya ejecutaste las migraciones antes. Opciones:
1. Hacer rollback completo (ver arriba)
2. Ejecutar solo las nuevas migraciones

### PostGIS no disponible
Si no necesitas funcionalidades geoespaciales avanzadas, comenta la línea en `001_create_extensions.sql`:
```sql
-- CREATE EXTENSION IF NOT EXISTS "postgis";
```

## Próximos Pasos

Después de ejecutar las migraciones:

1. ✅ Backend: Conectar a la BD desde Node.js
2. ✅ Implementar endpoints CRUD
3. ✅ Configurar autenticación JWT
4. ✅ Implementar WebSockets para tiempo real

Consulta `../DATABASE_DESIGN.md` para documentación completa del modelo de datos.
