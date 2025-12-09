# 🔍 Verificación Técnica - Sistema PROVIAL

Comandos específicos para verificar cada componente del sistema.

---

## 1️⃣ VERIFICACIÓN DE BASE DE DATOS

### Verificar Conexión
```bash
docker exec provial_postgres pg_isready -U postgres
```
Esperado: `postgres:5432 - accepting connections`

### Verificar Tablas de Normalización
```bash
docker exec provial_postgres psql -U postgres -d provial_db -c "
SELECT table_name
FROM information_schema.tables
WHERE table_name IN (
    'vehiculo', 'piloto', 'grua', 'aseguradora',
    'tarjeta_circulacion', 'contenedor', 'bus',
    'articulo_sancion', 'sancion',
    'incidente_vehiculo', 'incidente_grua'
)
ORDER BY table_name;
"
```
Esperado: 11 tablas listadas

### Verificar Vistas Materializadas
```bash
docker exec provial_postgres psql -U postgres -d provial_db -c "
SELECT matviewname
FROM pg_matviews
WHERE matviewname LIKE 'mv_%'
ORDER BY matviewname;
"
```
Esperado: Mínimo 4 vistas (mv_vehiculo_historial, mv_piloto_historial, mv_vehiculos_reincidentes, mv_pilotos_problematicos)

### Verificar Índices en Tablas Nuevas
```bash
docker exec provial_postgres psql -U postgres -d provial_db -c "
SELECT tablename, indexname
FROM pg_indexes
WHERE tablename IN ('vehiculo', 'piloto', 'grua', 'aseguradora')
ORDER BY tablename, indexname;
"
```
Esperado: Múltiples índices por tabla

### Contar Registros en Tablas Maestras
```bash
docker exec provial_postgres psql -U postgres -d provial_db -c "
SELECT
    (SELECT COUNT(*) FROM vehiculo) as vehiculos,
    (SELECT COUNT(*) FROM piloto) as pilotos,
    (SELECT COUNT(*) FROM grua) as gruas,
    (SELECT COUNT(*) FROM aseguradora) as aseguradoras,
    (SELECT COUNT(*) FROM articulo_sancion) as articulos;
"
```
Esperado: Números >= 0 (depende de datos migrados)

---

## 2️⃣ VERIFICACIÓN DE BACKEND

### Compilación TypeScript
```bash
cd backend
npm run build
```
Esperado: Build exitoso sin errores

### Verificar Imports de Controladores
```bash
cd backend
grep -l "reasignacion.controller" src/routes/index.ts
grep -l "intelligence.controller" src/routes/index.ts
```
Esperado: Ambos archivos encontrados

### Verificar Exports de Rutas
```bash
cd backend
grep "reasignacionRoutes" src/routes/index.ts
grep "intelligenceRoutes" src/routes/index.ts
```
Esperado: Ambas rutas exportadas

### Listar Endpoints de Reasignaciones
```bash
cd backend
grep -E "router\.(get|post|put|delete|patch)" src/routes/reasignacion.routes.ts
```
Esperado: Mínimo 3 rutas (crear, listar activas, finalizar)

### Listar Endpoints de Inteligencia
```bash
cd backend
grep -E "router\.(get|post)" src/routes/intelligence.routes.ts
```
Esperado: Mínimo 4 rutas (vehiculo/:placa, piloto/:licencia, stats, top-reincidentes)

---

## 3️⃣ VERIFICACIÓN DE MOBILE

### Verificar Pantalla de Relevo Existe
```bash
cd mobile
ls -lh src/screens/brigada/RelevoScreen.tsx
```
Esperado: Archivo existe

### Verificar Pantalla de Historial de Vehículo Existe
```bash
cd mobile
ls -lh src/screens/brigada/VehiculoHistorialScreen.tsx
```
Esperado: Archivo existe

### Verificar PlacaInput Actualizado
```bash
cd mobile
grep "intelligence/vehiculo" src/components/PlacaInput.tsx
```
Esperado: Endpoint encontrado

### Verificar authStore Usa Nuevo Sistema
```bash
cd mobile
grep "salidas/mi-unidad" src/store/authStore.ts
grep "salidas/mi-salida-activa" src/store/authStore.ts
```
Esperado: Ambos endpoints encontrados

### Verificar Navegación de Relevo
```bash
cd mobile
grep "RelevoScreen" src/navigation/BrigadaNavigator.tsx
```
Esperado: Ruta registrada

### Verificar salida_unidad_id en Situaciones
```bash
cd mobile
grep "salida_unidad_id" src/screens/brigada/IncidenteScreen.tsx
grep "salida_unidad_id" src/screens/brigada/AsistenciaScreen.tsx
grep "salida_unidad_id" src/screens/brigada/EmergenciaScreen.tsx
```
Esperado: Campo encontrado en todas

---

## 4️⃣ VERIFICACIÓN DE WEB

### Verificar Dashboard de Inteligencia Existe
```bash
cd web
ls -lh src/pages/IntelligenceDashboard.tsx
```
Esperado: Archivo existe

### Verificar Imports de Recharts
```bash
cd web
grep "recharts" src/pages/IntelligenceDashboard.tsx
```
Esperado: Imports de Recharts encontrados

### Verificar Exports de Excel
```bash
cd web
grep "xlsx" src/pages/IntelligenceDashboard.tsx
```
Esperado: Librería XLSX importada

---

## 5️⃣ VERIFICACIÓN DE ENDPOINTS (Requiere Backend Corriendo)

### Iniciar Backend
```bash
cd backend
npm run dev
```

### En otra terminal, probar endpoints:

#### Salidas
```bash
curl http://localhost:3000/api/salidas/mi-unidad \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Sedes
```bash
curl http://localhost:3000/api/sedes
```

#### Reasignaciones
```bash
curl http://localhost:3000/api/reasignaciones/activas \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Inteligencia - Stats
```bash
curl http://localhost:3000/api/intelligence/stats \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Inteligencia - Top Reincidentes
```bash
curl http://localhost:3000/api/intelligence/top-reincidentes \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Inteligencia - Historial de Vehículo
```bash
curl http://localhost:3000/api/intelligence/vehiculo/P512KJF \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 6️⃣ VERIFICACIÓN DE MIGRACIONES

### Verificar Archivos de Migración Existen
```bash
cd migrations
ls -lh 024_normalize_incident_data.sql
ls -lh 024b_migrate_existing_data.sql
ls -lh 025_intelligence_views.sql
```
Esperado: 3 archivos encontrados

### Verificar Sintaxis SQL (Dry Run)
```bash
docker exec provial_postgres psql -U postgres -d provial_db --dry-run < migrations/024_normalize_incident_data.sql
```
Esperado: Sin errores de sintaxis (puede mostrar warnings)

### Verificar Tamaño de Migraciones
```bash
cd migrations
wc -l 024_normalize_incident_data.sql 024b_migrate_existing_data.sql 025_intelligence_views.sql
```
Esperado:
- 024: ~400-500 líneas
- 024b: ~200-300 líneas
- 025: ~300-400 líneas

---

## 7️⃣ VERIFICACIÓN DE DOCUMENTACIÓN

### Verificar Documentos Existen
```bash
ls -lh QUICK_START.md
ls -lh RESUMEN_IMPLEMENTACION_COMPLETA.md
ls -lh NORMALIZACION_RESUMEN.md
ls -lh EJEMPLOS_USO_NORMALIZACION.md
ls -lh CHECKLIST_NORMALIZACION.md
ls -lh INDICE_ARCHIVOS.md
```
Esperado: 6 archivos encontrados

### Verificar Scripts de Setup Existen
```bash
ls -lh setup-completo.ps1
ls -lh setup-completo.sh
```
Esperado: 2 archivos encontrados

---

## 8️⃣ VERIFICACIÓN DE FUNCIONALIDAD COMPLETA

### Test de Flujo Backend

#### 1. Obtener Token
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"brigada01","password":"password123"}' \
  | jq -r '.accessToken')

echo "Token: $TOKEN"
```

#### 2. Obtener Mi Unidad
```bash
curl http://localhost:3000/api/salidas/mi-unidad \
  -H "Authorization: Bearer $TOKEN" | jq
```

#### 3. Obtener Mi Salida Activa
```bash
curl http://localhost:3000/api/salidas/mi-salida-activa \
  -H "Authorization: Bearer $TOKEN" | jq
```

#### 4. Consultar Historial de Vehículo
```bash
curl http://localhost:3000/api/intelligence/vehiculo/P512KJF \
  -H "Authorization: Bearer $TOKEN" | jq
```

#### 5. Obtener Stats de Inteligencia
```bash
curl http://localhost:3000/api/intelligence/stats \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

## 9️⃣ VERIFICACIÓN DE PERFORMANCE

### Tiempo de Respuesta de Endpoints
```bash
# Endpoint de inteligencia (debe ser <500ms)
time curl -s http://localhost:3000/api/intelligence/vehiculo/P512KJF \
  -H "Authorization: Bearer $TOKEN" > /dev/null
```

### Tamaño de Vistas Materializadas
```bash
docker exec provial_postgres psql -U postgres -d provial_db -c "
SELECT
    schemaname,
    matviewname,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||matviewname)) AS size
FROM pg_matviews
WHERE matviewname LIKE 'mv_%'
ORDER BY pg_total_relation_size(schemaname||'.'||matviewname) DESC;
"
```

### Performance de Índices
```bash
docker exec provial_postgres psql -U postgres -d provial_db -c "
SELECT
    tablename,
    COUNT(*) as num_indices
FROM pg_indexes
WHERE tablename IN ('vehiculo', 'piloto', 'grua', 'aseguradora')
GROUP BY tablename;
"
```

---

## 🔟 CHECKLIST RÁPIDO

### Base de Datos
- [ ] PostgreSQL conecta correctamente
- [ ] 11 tablas nuevas creadas
- [ ] 4+ vistas materializadas creadas
- [ ] Índices creados en tablas clave
- [ ] Artículos de sanción precargados

### Backend
- [ ] `npm run build` exitoso
- [ ] Rutas de reasignaciones registradas
- [ ] Rutas de inteligencia registradas
- [ ] Controladores implementados
- [ ] Modelos actualizados (vehiculo, piloto, grua, aseguradora)

### Mobile
- [ ] RelevoScreen.tsx existe
- [ ] VehiculoHistorialScreen.tsx existe
- [ ] PlacaInput.tsx actualizado
- [ ] authStore usa /api/salidas/*
- [ ] Todas las situaciones usan salida_unidad_id
- [ ] Navegación actualizada

### Web
- [ ] IntelligenceDashboard.tsx existe
- [ ] Dependencias instaladas (recharts, xlsx, mui/x-date-pickers)

### Documentación
- [ ] QUICK_START.md
- [ ] RESUMEN_IMPLEMENTACION_COMPLETA.md
- [ ] NORMALIZACION_RESUMEN.md
- [ ] EJEMPLOS_USO_NORMALIZACION.md
- [ ] CHECKLIST_NORMALIZACION.md
- [ ] INDICE_ARCHIVOS.md

### Scripts
- [ ] setup-completo.ps1
- [ ] setup-completo.sh

---

## ⚡ VERIFICACIÓN RÁPIDA EN 1 COMANDO

### Windows PowerShell
```powershell
# Verificación completa
Write-Host "Backend:" -ForegroundColor Yellow
cd backend; npm run build 2>$null
Write-Host "Migraciones:" -ForegroundColor Yellow
ls migrations\024*.sql, migrations\025*.sql
Write-Host "Documentación:" -ForegroundColor Yellow
ls *RESUMEN*.md, QUICK_START.md, INDICE*.md
Write-Host "Scripts:" -ForegroundColor Yellow
ls setup-completo.*
```

### Linux/Mac Bash
```bash
echo "=== Backend ==="
cd backend && npm run build 2>/dev/null && cd ..
echo "=== Migraciones ==="
ls -lh migrations/024*.sql migrations/025*.sql
echo "=== Documentación ==="
ls -lh *RESUMEN*.md QUICK_START.md INDICE*.md
echo "=== Scripts ==="
ls -lh setup-completo.*
```

---

## 🎯 RESULTADO ESPERADO

Si todo está correcto, deberías ver:

✅ Backend compila sin errores
✅ 3 archivos de migración (024, 024b, 025)
✅ 6 archivos de documentación
✅ 2 scripts de setup
✅ 11 tablas nuevas en BD (después de ejecutar migraciones)
✅ 4+ vistas materializadas (después de ejecutar migraciones)
✅ Endpoints responden correctamente (con backend corriendo)

---

**Si alguna verificación falla, revisa los logs específicos y consulta la documentación correspondiente.**
