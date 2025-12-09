# 📁 Índice de Archivos - Sistema PROVIAL

Guía rápida de todos los archivos importantes del proyecto y sus ubicaciones.

---

## 📚 DOCUMENTACIÓN (Raíz del Proyecto)

### Documentos Principales
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| **QUICK_START.md** | 🔴 EMPIEZA AQUÍ - Guía rápida para empezar | NUEVO |
| **RESUMEN_IMPLEMENTACION_COMPLETA.md** | Resumen ejecutivo de TODO lo implementado | NUEVO |
| **ESTADO_ACTUAL.md** | Estado del proyecto actualizado | EXISTENTE |
| **implementation_plan.md** | Plan de implementación original | EXISTENTE |
| **README.md** | README principal del proyecto | EXISTENTE |

### Documentación de Normalización
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| **NORMALIZACION_RESUMEN.md** | Resumen del sistema de normalización | NUEVO |
| **EJEMPLOS_USO_NORMALIZACION.md** | 12 ejemplos de código con normalización | NUEVO |
| **CHECKLIST_NORMALIZACION.md** | Checklist de verificación | NUEVO |

### Documentación Técnica
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| **ARCHITECTURE.md** | Arquitectura del sistema | EXISTENTE |
| **DATABASE_DESIGN.md** | Diseño de base de datos | EXISTENTE |
| **GETTING_STARTED.md** | Guía de inicio | EXISTENTE |
| **INSTALL_GUIDE.md** | Guía de instalación | EXISTENTE |

---

## 🔧 SCRIPTS DE SETUP

| Archivo | Descripción | Plataforma |
|---------|-------------|------------|
| **setup-completo.ps1** | Script de setup automático | Windows PowerShell |
| **setup-completo.sh** | Script de setup automático | Linux/Mac Bash |

---

## 🗄️ MIGRACIONES SQL

### Migraciones Principales
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `migrations/019_sistema_asignaciones_permanentes.sql` | Sistema de asignaciones permanentes | EJECUTADA |
| `migrations/020_sistema_sedes_ingresos.sql` | Sedes e ingresos múltiples | EJECUTADA |
| `migrations/021_fix_verificar_acceso_app.sql` | Gestión manual de grupos | EJECUTADA |

### Migraciones Nuevas (Pendientes)
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `migrations/024_normalize_incident_data.sql` | Normalización de datos (11 tablas) | ⏸ PENDIENTE |
| `migrations/024b_migrate_existing_data.sql` | Migración de datos existentes | ⏸ PENDIENTE |
| `migrations/025_intelligence_views.sql` | Sistema de inteligencia (vistas) | ⏸ PENDIENTE |

---

## 🖥️ BACKEND

### Controladores Nuevos/Actualizados
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `backend/src/controllers/ingreso.controller.ts` | Ingresos a sede | VERIFICADO |
| `backend/src/controllers/sede.controller.ts` | Gestión de sedes | ACTUALIZADO |
| `backend/src/controllers/reasignacion.controller.ts` | Reasignaciones | ⭐ NUEVO |
| `backend/src/controllers/intelligence.controller.ts` | Sistema de inteligencia | ACTUALIZADO |

### Rutas Nuevas/Actualizadas
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `backend/src/routes/ingreso.routes.ts` | Rutas de ingresos | VERIFICADO |
| `backend/src/routes/sede.routes.ts` | Rutas de sedes | ACTUALIZADO |
| `backend/src/routes/reasignacion.routes.ts` | Rutas de reasignaciones | ⭐ NUEVO |
| `backend/src/routes/intelligence.routes.ts` | Rutas de inteligencia | ACTUALIZADO |
| `backend/src/routes/index.ts` | Registro de todas las rutas | ACTUALIZADO |

### Modelos Nuevos/Actualizados
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `backend/src/models/salida.model.ts` | Modelo de salidas (verificado completo) | VERIFICADO |
| `backend/src/models/vehiculo.model.ts` | Modelo de vehículos (14 métodos) | ACTUALIZADO |
| `backend/src/models/piloto.model.ts` | Modelo de pilotos (11 métodos) | ACTUALIZADO |
| `backend/src/models/gruaMaster.model.ts` | Modelo de grúas (13 métodos) | ACTUALIZADO |
| `backend/src/models/aseguradora.model.ts` | Modelo de aseguradoras (9 métodos) | ACTUALIZADO |

---

## 📱 MOBILE (App React Native)

### Pantallas Nuevas
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `mobile/src/screens/brigada/RelevoScreen.tsx` | Pantalla de relevos | ⭐ NUEVO |
| `mobile/src/screens/brigada/VehiculoHistorialScreen.tsx` | Historial de vehículo | ⭐ NUEVO |

### Pantallas Actualizadas
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `mobile/src/screens/brigada/BrigadaHomeScreen.tsx` | Home (botón de relevo agregado) | ACTUALIZADO |
| `mobile/src/screens/brigada/SalidaSedeScreen.tsx` | Salida de sede (salida_unidad_id) | ACTUALIZADO |

### Pantallas Verificadas (Ya Correctas)
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `mobile/src/screens/brigada/IniciarSalidaScreen.tsx` | Iniciar salida | VERIFICADO |
| `mobile/src/screens/brigada/IngresoSedeScreen.tsx` | Ingreso a sede | VERIFICADO |
| `mobile/src/screens/brigada/FinalizarDiaScreen.tsx` | Finalizar día | VERIFICADO |
| `mobile/src/screens/brigada/SalidaDeSedeScreen.tsx` | Salir de sede después de ingreso | VERIFICADO |
| `mobile/src/screens/brigada/IncidenteScreen.tsx` | Crear incidente | VERIFICADO |
| `mobile/src/screens/brigada/AsistenciaScreen.tsx` | Asistencia | VERIFICADO |
| `mobile/src/screens/brigada/EmergenciaScreen.tsx` | Emergencia | VERIFICADO |
| `mobile/src/screens/brigada/NuevaSituacionScreen.tsx` | Nueva situación | VERIFICADO |

### Componentes Actualizados
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `mobile/src/components/PlacaInput.tsx` | Input de placa con validación e inteligencia | ACTUALIZADO |
| `mobile/src/components/VehiculoForm.tsx` | Formulario de vehículo (7 secciones) | VERIFICADO |
| `mobile/src/components/GruaForm.tsx` | Formulario de grúa (reorganizado) | ACTUALIZADO |
| `mobile/src/components/AjustadorForm.tsx` | Formulario de ajustador (reorganizado) | ACTUALIZADO |

### Store y Navegación
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `mobile/src/store/authStore.ts` | Store de autenticación (migrado) | VERIFICADO |
| `mobile/src/navigation/BrigadaNavigator.tsx` | Navegador de brigada (ruta de relevo) | ACTUALIZADO |

---

## 🌐 WEB (Dashboard)

### Páginas Nuevas
| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `web/src/pages/IntelligenceDashboard.tsx` | Dashboard de inteligencia completo | ⭐ NUEVO |

---

## 📊 ENDPOINTS API

### Ingresos (`/api/ingresos`)
```
POST   /api/ingresos/registrar              [BRIGADA]
POST   /api/ingresos/:id/salir               [BRIGADA]
GET    /api/ingresos/mi-ingreso-activo       [BRIGADA]
GET    /api/ingresos/historial/:salidaId     [ALL AUTH]
GET    /api/ingresos/:id                     [ALL AUTH]
```

### Sedes (`/api/sedes`)
```
GET    /api/sedes                            [ALL AUTH]
GET    /api/sedes/:id                        [ALL AUTH]
GET    /api/sedes/mi-sede                    [ALL AUTH]
GET    /api/sedes/:id/unidades               [ALL AUTH]
GET    /api/sedes/:id/personal               [ALL AUTH]
```

### Reasignaciones (`/api/reasignaciones`)
```
POST   /api/reasignaciones                   [OPERACIONES, ADMIN, COP]
GET    /api/reasignaciones/activas           [COP, OPERACIONES, ADMIN]
POST   /api/reasignaciones/:id/finalizar     [OPERACIONES, ADMIN, COP]
```

### Inteligencia (`/api/intelligence`)
```
GET    /api/intelligence/vehiculo/:placa        [ALL AUTH]
GET    /api/intelligence/piloto/:licencia       [ALL AUTH]
GET    /api/intelligence/stats                  [COP, OPS, MANDOS, ADMIN]
GET    /api/intelligence/top-reincidentes       [COP, OPS, MANDOS, ADMIN]
```

### Salidas (`/api/salidas`) - Ya Existentes
```
GET    /api/salidas/mi-unidad                   [BRIGADA]
GET    /api/salidas/mi-salida-activa            [BRIGADA]
POST   /api/salidas/iniciar                     [BRIGADA]
POST   /api/salidas/:id/finalizar               [BRIGADA, COP, OPS, ADMIN]
POST   /api/salidas/relevos                     [BRIGADA, COP, OPS]
GET    /api/salidas/admin/unidades-en-salida    [COP, OPS, ADMIN]
```

---

## 🗂️ ESTRUCTURA DE TABLAS

### Tablas Nuevas (Migración 024)
1. `vehiculo` - Master de vehículos
2. `piloto` - Master de pilotos
3. `grua` - Master de grúas
4. `aseguradora` - Master de aseguradoras
5. `tarjeta_circulacion` - Datos de TC
6. `contenedor` - Datos de contenedores
7. `bus` - Datos de buses
8. `articulo_sancion` - Catálogo de artículos
9. `sancion` - Sanciones aplicadas
10. `incidente_vehiculo` - Relación many-to-many
11. `incidente_grua` - Relación many-to-many

### Vistas Materializadas Nuevas (Migración 025)
1. `mv_vehiculo_historial` - Historial completo por vehículo
2. `mv_piloto_historial` - Historial completo por piloto
3. `mv_vehiculos_reincidentes` - Top reincidentes
4. `mv_pilotos_problematicos` - Top problemáticos
5. `mv_puntos_calientes` - Hotspots geográficos
6. `mv_tendencias_temporales` - Análisis temporal

---

## 🔍 VERIFICACIÓN RÁPIDA

### Verificar Documentación
```bash
ls -lh *.md
```

Deberías ver:
- QUICK_START.md
- RESUMEN_IMPLEMENTACION_COMPLETA.md
- NORMALIZACION_RESUMEN.md
- EJEMPLOS_USO_NORMALIZACION.md
- CHECKLIST_NORMALIZACION.md

### Verificar Scripts
```bash
ls -lh setup-completo.*
```

Deberías ver:
- setup-completo.ps1
- setup-completo.sh

### Verificar Migraciones
```bash
ls -lh migrations/024*.sql migrations/025*.sql
```

Deberías ver:
- 024_normalize_incident_data.sql
- 024b_migrate_existing_data.sql
- 025_intelligence_views.sql

### Verificar Backend Compila
```bash
cd backend && npm run build
```

Debe compilar sin errores.

---

## 📈 ESTADÍSTICAS

### Archivos Totales Afectados: 42
- **Creados**: 8
- **Modificados**: 10
- **Actualizados**: 4
- **Verificados**: 20

### Código Nuevo
- **Líneas de código**: ~3,500 líneas
- **Endpoints**: 22 nuevos/actualizados
- **Métodos de modelos**: 47 métodos totales
- **Tablas de BD**: 11 nuevas
- **Vistas materializadas**: 6 nuevas/actualizadas

---

## 🎯 NAVEGACIÓN RÁPIDA

### Para Empezar
1. Lee `QUICK_START.md`
2. Ejecuta `setup-completo.ps1` (o .sh)
3. Lee `RESUMEN_IMPLEMENTACION_COMPLETA.md`

### Para Entender el Sistema
1. `ESTADO_ACTUAL.md` - Estado del proyecto
2. `ARCHITECTURE.md` - Arquitectura
3. `DATABASE_DESIGN.md` - Diseño de BD

### Para Implementar
1. `EJEMPLOS_USO_NORMALIZACION.md` - Ejemplos de código
2. `backend/src/controllers/` - Ver controladores
3. `mobile/src/screens/brigada/` - Ver pantallas

### Para Verificar
1. `CHECKLIST_NORMALIZACION.md` - Checklist
2. `setup-completo.ps1` - Script de verificación
3. Backend: `npm run build`

---

**Última actualización**: 7 de Diciembre, 2025
