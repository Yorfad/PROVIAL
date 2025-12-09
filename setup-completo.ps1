# Script de Setup Completo - Sistema PROVIAL
# Ejecuta todas las migraciones y verificaciones necesarias
# Autor: Claude Code
# Fecha: 7 de Diciembre, 2025

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETO - SISTEMA PROVIAL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker esté corriendo
Write-Host "[1/8] Verificando Docker..." -ForegroundColor Yellow
docker ps > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker no está corriendo. Por favor inicia Docker Desktop." -ForegroundColor Red
    exit 1
}
Write-Host "  Docker OK" -ForegroundColor Green
Write-Host ""

# Verificar que PostgreSQL esté corriendo
Write-Host "[2/8] Verificando PostgreSQL..." -ForegroundColor Yellow
docker exec provial_postgres pg_isready -U postgres > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: PostgreSQL no está corriendo. Ejecuta: docker-compose up -d" -ForegroundColor Red
    exit 1
}
Write-Host "  PostgreSQL OK" -ForegroundColor Green
Write-Host ""

# Crear backup de la base de datos
Write-Host "[3/8] Creando backup de la base de datos..." -ForegroundColor Yellow
$backupFile = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
docker exec provial_postgres pg_dump -U postgres provial_db > $backupFile
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Backup creado: $backupFile" -ForegroundColor Green
} else {
    Write-Host "  WARNING: No se pudo crear backup (puede ser normal si la BD está vacía)" -ForegroundColor Yellow
}
Write-Host ""

# Ejecutar migración 024 (normalización)
Write-Host "[4/8] Ejecutando migración 024 (normalización de datos)..." -ForegroundColor Yellow
Get-Content migrations\024_normalize_incident_data.sql | docker exec -i provial_postgres psql -U postgres -d provial_db
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Migración 024 completada" -ForegroundColor Green
} else {
    Write-Host "  ERROR en migración 024" -ForegroundColor Red
    Write-Host "  Revisa los logs arriba para ver el error" -ForegroundColor Yellow
    $continue = Read-Host "¿Continuar con las siguientes migraciones? (s/n)"
    if ($continue -ne "s") {
        exit 1
    }
}
Write-Host ""

# Ejecutar migración 024b (migrar datos existentes)
Write-Host "[5/8] Ejecutando migración 024b (migrar datos existentes)..." -ForegroundColor Yellow
Get-Content migrations\024b_migrate_existing_data.sql | docker exec -i provial_postgres psql -U postgres -d provial_db
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Migración 024b completada" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Migración 024b con errores (puede ser normal si no hay datos previos)" -ForegroundColor Yellow
}
Write-Host ""

# Ejecutar migración 025 (sistema de inteligencia)
Write-Host "[6/8] Ejecutando migración 025 (sistema de inteligencia)..." -ForegroundColor Yellow
Get-Content migrations\025_intelligence_views.sql | docker exec -i provial_postgres psql -U postgres -d provial_db
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Migración 025 completada" -ForegroundColor Green
} else {
    Write-Host "  ERROR en migración 025" -ForegroundColor Red
    Write-Host "  Revisa los logs arriba para ver el error" -ForegroundColor Yellow
}
Write-Host ""

# Verificar tablas creadas
Write-Host "[7/8] Verificando tablas creadas..." -ForegroundColor Yellow
$tablas = @(
    "vehiculo",
    "piloto",
    "grua",
    "aseguradora",
    "tarjeta_circulacion",
    "contenedor",
    "bus",
    "articulo_sancion",
    "sancion",
    "incidente_vehiculo",
    "incidente_grua"
)

$errores = 0
foreach ($tabla in $tablas) {
    $existe = docker exec provial_postgres psql -U postgres -d provial_db -t -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '$tabla');" 2>$null
    if ($existe -match "t") {
        Write-Host "    $tabla" -ForegroundColor Green -NoNewline
        Write-Host " OK" -ForegroundColor White
    } else {
        Write-Host "    $tabla" -ForegroundColor Red -NoNewline
        Write-Host " FALTA" -ForegroundColor White
        $errores++
    }
}

if ($errores -eq 0) {
    Write-Host "  Todas las tablas creadas correctamente" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Faltan $errores tablas" -ForegroundColor Yellow
}
Write-Host ""

# Verificar vistas materializadas
Write-Host "[8/8] Verificando vistas materializadas..." -ForegroundColor Yellow
$vistas = @(
    "mv_vehiculo_historial",
    "mv_piloto_historial",
    "mv_vehiculos_reincidentes",
    "mv_pilotos_problematicos"
)

$errores = 0
foreach ($vista in $vistas) {
    $existe = docker exec provial_postgres psql -U postgres -d provial_db -t -c "SELECT EXISTS (SELECT FROM pg_matviews WHERE matviewname = '$vista');" 2>$null
    if ($existe -match "t") {
        Write-Host "    $vista" -ForegroundColor Green -NoNewline
        Write-Host " OK" -ForegroundColor White
    } else {
        Write-Host "    $vista" -ForegroundColor Red -NoNewline
        Write-Host " FALTA" -ForegroundColor White
        $errores++
    }
}

if ($errores -eq 0) {
    Write-Host "  Todas las vistas materializadas creadas correctamente" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Faltan $errores vistas" -ForegroundColor Yellow
}
Write-Host ""

# Resumen final
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Iniciar backend: cd backend && npm run dev" -ForegroundColor White
Write-Host "2. Iniciar web: cd web && npm run dev" -ForegroundColor White
Write-Host "3. Iniciar mobile: cd mobile && npm run start" -ForegroundColor White
Write-Host ""
Write-Host "Documentación:" -ForegroundColor Yellow
Write-Host "- RESUMEN_IMPLEMENTACION_COMPLETA.md" -ForegroundColor White
Write-Host "- NORMALIZACION_RESUMEN.md" -ForegroundColor White
Write-Host "- EJEMPLOS_USO_NORMALIZACION.md" -ForegroundColor White
Write-Host "- CHECKLIST_NORMALIZACION.md" -ForegroundColor White
Write-Host ""
Write-Host "Backup creado en: $backupFile" -ForegroundColor Green
Write-Host ""
