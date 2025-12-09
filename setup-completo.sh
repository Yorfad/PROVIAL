#!/bin/bash
# Script de Setup Completo - Sistema PROVIAL
# Ejecuta todas las migraciones y verificaciones necesarias
# Autor: Claude Code
# Fecha: 7 de Diciembre, 2025

echo "========================================"
echo "  SETUP COMPLETO - SISTEMA PROVIAL"
echo "========================================"
echo ""

# Verificar que Docker esté corriendo
echo "[1/8] Verificando Docker..."
if ! docker ps > /dev/null 2>&1; then
    echo "ERROR: Docker no está corriendo. Por favor inicia Docker."
    exit 1
fi
echo "  ✓ Docker OK"
echo ""

# Verificar que PostgreSQL esté corriendo
echo "[2/8] Verificando PostgreSQL..."
if ! docker exec provial_postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "ERROR: PostgreSQL no está corriendo. Ejecuta: docker-compose up -d"
    exit 1
fi
echo "  ✓ PostgreSQL OK"
echo ""

# Crear backup de la base de datos
echo "[3/8] Creando backup de la base de datos..."
backupFile="backup_$(date +%Y%m%d_%H%M%S).sql"
docker exec provial_postgres pg_dump -U postgres provial_db > "$backupFile" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Backup creado: $backupFile"
else
    echo "  ⚠ WARNING: No se pudo crear backup (puede ser normal si la BD está vacía)"
fi
echo ""

# Ejecutar migración 024 (normalización)
echo "[4/8] Ejecutando migración 024 (normalización de datos)..."
docker exec -i provial_postgres psql -U postgres -d provial_db < migrations/024_normalize_incident_data.sql
if [ $? -eq 0 ]; then
    echo "  ✓ Migración 024 completada"
else
    echo "  ✗ ERROR en migración 024"
    echo "  Revisa los logs arriba para ver el error"
    read -p "¿Continuar con las siguientes migraciones? (s/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi
echo ""

# Ejecutar migración 024b (migrar datos existentes)
echo "[5/8] Ejecutando migración 024b (migrar datos existentes)..."
docker exec -i provial_postgres psql -U postgres -d provial_db < migrations/024b_migrate_existing_data.sql
if [ $? -eq 0 ]; then
    echo "  ✓ Migración 024b completada"
else
    echo "  ⚠ WARNING: Migración 024b con errores (puede ser normal si no hay datos previos)"
fi
echo ""

# Ejecutar migración 025 (sistema de inteligencia)
echo "[6/8] Ejecutando migración 025 (sistema de inteligencia)..."
docker exec -i provial_postgres psql -U postgres -d provial_db < migrations/025_intelligence_views.sql
if [ $? -eq 0 ]; then
    echo "  ✓ Migración 025 completada"
else
    echo "  ✗ ERROR en migración 025"
    echo "  Revisa los logs arriba para ver el error"
fi
echo ""

# Verificar tablas creadas
echo "[7/8] Verificando tablas creadas..."
tablas=(
    "vehiculo"
    "piloto"
    "grua"
    "aseguradora"
    "tarjeta_circulacion"
    "contenedor"
    "bus"
    "articulo_sancion"
    "sancion"
    "incidente_vehiculo"
    "incidente_grua"
)

errores=0
for tabla in "${tablas[@]}"; do
    existe=$(docker exec provial_postgres psql -U postgres -d provial_db -t -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '$tabla');" 2>/dev/null)
    if [[ $existe == *"t"* ]]; then
        echo "    ✓ $tabla OK"
    else
        echo "    ✗ $tabla FALTA"
        ((errores++))
    fi
done

if [ $errores -eq 0 ]; then
    echo "  ✓ Todas las tablas creadas correctamente"
else
    echo "  ⚠ WARNING: Faltan $errores tablas"
fi
echo ""

# Verificar vistas materializadas
echo "[8/8] Verificando vistas materializadas..."
vistas=(
    "mv_vehiculo_historial"
    "mv_piloto_historial"
    "mv_vehiculos_reincidentes"
    "mv_pilotos_problematicos"
)

errores=0
for vista in "${vistas[@]}"; do
    existe=$(docker exec provial_postgres psql -U postgres -d provial_db -t -c "SELECT EXISTS (SELECT FROM pg_matviews WHERE matviewname = '$vista');" 2>/dev/null)
    if [[ $existe == *"t"* ]]; then
        echo "    ✓ $vista OK"
    else
        echo "    ✗ $vista FALTA"
        ((errores++))
    fi
done

if [ $errores -eq 0 ]; then
    echo "  ✓ Todas las vistas materializadas creadas correctamente"
else
    echo "  ⚠ WARNING: Faltan $errores vistas"
fi
echo ""

# Resumen final
echo "========================================"
echo "  SETUP COMPLETADO"
echo "========================================"
echo ""
echo "Próximos pasos:"
echo "1. Iniciar backend: cd backend && npm run dev"
echo "2. Iniciar web: cd web && npm run dev"
echo "3. Iniciar mobile: cd mobile && npm run start"
echo ""
echo "Documentación:"
echo "- RESUMEN_IMPLEMENTACION_COMPLETA.md"
echo "- NORMALIZACION_RESUMEN.md"
echo "- EJEMPLOS_USO_NORMALIZACION.md"
echo "- CHECKLIST_NORMALIZACION.md"
echo ""
echo "Backup creado en: $backupFile"
echo ""
