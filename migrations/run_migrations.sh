#!/bin/bash

# Script para ejecutar migraciones de PostgreSQL
# Uso: ./run_migrations.sh [DATABASE_URL]

set -e  # Detener si hay error

# Configuración
DB_URL="${1:-postgresql://postgres:postgres@localhost:5432/provial_db}"
MIGRATIONS_DIR="$(dirname "$0")"

echo "====================================="
echo "Ejecutando migraciones de PostgreSQL"
echo "====================================="
echo ""

# Función para ejecutar una migración
run_migration() {
    local file=$1
    echo "▶ Ejecutando: $(basename $file)"
    psql "$DB_URL" -f "$file"
    echo "✓ Completado: $(basename $file)"
    echo ""
}

# Ejecutar migraciones en orden
for migration in $(ls -1 "$MIGRATIONS_DIR"/*.sql | sort); do
    if [[ "$(basename $migration)" == "run_migrations.sh" ]]; then
        continue
    fi
    run_migration "$migration"
done

echo "====================================="
echo "✅ Todas las migraciones completadas"
echo "====================================="

# Refrescar vistas materializadas
echo ""
echo "Refrescando vistas materializadas..."
psql "$DB_URL" -c "REFRESH MATERIALIZED VIEW CONCURRENTLY mv_estadisticas_diarias;"
psql "$DB_URL" -c "REFRESH MATERIALIZED VIEW CONCURRENTLY mv_no_atendidos_por_motivo;"
echo "✓ Vistas materializadas actualizadas"

# Mostrar resumen de tablas
echo ""
echo "Resumen de la base de datos:"
psql "$DB_URL" -c "\dt"

echo ""
echo "Listo para usar! 🚀"
