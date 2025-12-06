# Estado Actual del Proyecto PROVIAL - 2025-11-30

## 🎯 Resumen Ejecutivo
Proyecto de app móvil React Native + backend Node.js/PostgreSQL para sistema de patrullaje vial PROVIAL. Se está replicando funcionalidad de `provialSinExcel.py` (app de escritorio).

## ✅ ACTUALIZACIÓN CRÍTICA - Sistema Rediseñado (2025-11-30)

### 🔥 **CAMBIO ARQUITECTÓNICO MAYOR: Opción B Implementada**

Se eliminó el concepto de **turnos diarios** y se implementó un sistema de **asignaciones permanentes + salidas sin límite de tiempo**.

#### **Razón del cambio:**
- Los turnos no tienen horarios fijos
- Una salida puede durar 1 hora o 48+ horas
- Los brigadistas pueden estar en emergencias durante la noche
- El sistema anterior (turnos por día) causaba que no pudieran ingresar datos después de medianoche

---

## 🏗️ Nuevo Sistema Implementado

### **1. Migración 019 - Sistema de Asignaciones Permanentes**
**Archivo**: `migrations/019_sistema_asignaciones_permanentes.sql`

#### Tablas Creadas:

**`brigada_unidad`** - Asignaciones permanentes
- Brigadistas asignados a unidades de forma permanente
- Roles: PILOTO, COPILOTO, ACOMPAÑANTE
- Campo `chapa` agregado a tabla `usuario` (identificación de brigadista)
- Un brigadista = una unidad activa a la vez

**`salida_unidad`** - Salidas sin límite de tiempo
- Reemplaza el concepto de "turno del día"
- Estado: EN_SALIDA, FINALIZADA, CANCELADA
- Puede durar horas o días sin restricción
- Solo una salida activa por unidad a la vez
- Snapshot de tripulación al momento de salir (JSONB)

**`relevo`** - Intercambios de unidades/tripulaciones
- Tipo: UNIDAD_COMPLETA (unidad sale, otra entra)
- Tipo: CRUZADO (tripulación se queda con otra unidad)
- Registra brigadistas salientes y entrantes

**Modificaciones a tablas existentes:**
- `situacion.salida_unidad_id` - Vincula situaciones a salidas
- `usuario.chapa` - Número de chapa del brigadista

#### Vistas Creadas:

**`v_mi_unidad_asignada`**
- Para app móvil: muestra unidad asignada permanentemente
- Incluye compañeros de tripulación

**`v_mi_salida_activa`**
- Para app móvil: muestra si tengo salida activa
- Duración en horas, primera situación, tripulación

**`v_unidades_en_salida`**
- Para COP/Operaciones: todas las unidades actualmente en salida
- Última situación, total de situaciones, horas en salida

#### Funciones PostgreSQL:

**`iniciar_salida_unidad()`**
- Crea snapshot de tripulación actual
- Valida que no haya salida activa previa
- Retorna ID de salida creada

**`finalizar_salida_unidad()`**
- Marca regreso, calcula km recorridos
- Puede ser ejecutada por: Brigadista, COP, Operaciones, Admin

**`verificar_primera_situacion_es_salida()`** **[TRIGGER ACTIVO]**
- **FUERZA** que la primera situación de una salida sea `SALIDA_SEDE`
- Si intentas crear otra situación primero → ERROR
- Esto hace obligatoria la Salida de Sede

#### Scripts ejecutados:
1. ✅ `fix-017.js` - Creó tablas y triggers
2. ✅ `create-vistas-funciones-019.js` - Creó vistas y funciones
3. ✅ `asignar-brigada01-permanente.js` - Configuración de prueba

---

### **2. Backend - Nuevos Modelos y Controladores**

#### Archivos Creados:

**`backend/src/models/salida.model.ts`**
- `SalidaModel.getMiUnidadAsignada()` - Unidad permanente del brigadista
- `SalidaModel.getMiSalidaActiva()` - Salida activa si existe
- `SalidaModel.iniciarSalida()` - Inicia salida llamando función PG
- `SalidaModel.finalizarSalida()` - Finaliza salida
- `SalidaModel.asignarBrigadaAUnidad()` - Asignación permanente
- `SalidaModel.registrarRelevo()` - Relevos de unidades
- `SalidaModel.getTripulacionUnidad()` - Tripulación de unidad
- `SalidaModel.getUnidadesEnSalida()` - Para COP/Ops

**`backend/src/controllers/salida.controller.ts`**
- `GET /api/salidas/mi-unidad` - Mi unidad asignada (Brigada)
- `GET /api/salidas/mi-salida-activa` - Mi salida activa (Brigada)
- `POST /api/salidas/iniciar` - Iniciar salida (Brigada)
- `POST /api/salidas/:id/finalizar` - Finalizar salida (Brigada/COP/Ops/Admin)
- `POST /api/salidas/asignar-brigada` - Asignar permanentemente (Ops/Admin)
- `GET /api/salidas/tripulacion/:unidadId` - Ver tripulación
- `GET /api/salidas/admin/unidades-en-salida` - Monitoreo (COP/Ops/Admin)
- `POST /api/salidas/relevos` - Registrar relevo
- `GET /api/salidas/:id` - Info de salida
- `GET /api/salidas/historial/:unidadId` - Historial de salidas

**`backend/src/routes/salida.routes.ts`**
- Rutas registradas con autenticación y autorización por rol

**`backend/src/routes/index.ts`**
- ✅ Rutas `/api/salidas/*` registradas

---

### **3. Configuración de Prueba Completada**

#### brigada01 configurado:
- ✅ Asignado permanentemente a `PROV-001` como `PILOTO`
- ✅ Chapa asignada: `brigada01`
- ✅ Salida de prueba iniciada (ID: 1)
- ✅ Estado: EN_SALIDA
- ✅ Ruta inicial: CA-1
- ✅ KM inicial: 0.00
- ✅ Combustible inicial: 30.00 litros

---

### **4. Migración 020 - Sistema de Sedes e Ingresos Múltiples**
**Archivo**: `migrations/020_sistema_sedes_ingresos.sql`
**Documentación completa**: `DOCUMENTACION_SEDES_INGRESOS.md`

#### Tablas Creadas:

**`sede`** - Sedes de PROVIAL por el país
- Organización territorial con permisos jurisdiccionales
- Solo una sede puede ser central (`es_sede_central = TRUE`)
- Sedes iniciales: CENTRAL (Guatemala), SANCRISTO (San Cristóbal)

**`reasignacion_sede`** - Reasignaciones entre sedes
- Temporal o permanente
- Para usuarios (brigadistas) o unidades (vehículos)
- Motivo: apoyo en emergencias, cobertura de eventos, etc.

**`ingreso_sede`** - Ingresos múltiples durante salida
- Una salida puede tener MUCHOS ingresos
- Tipos: COMBUSTIBLE, COMISION, APOYO, ALMUERZO, MANTENIMIENTO, FINALIZACION
- Solo un ingreso activo (sin fecha_hora_salida) a la vez
- `es_ingreso_final = TRUE` → Finaliza la salida

**Modificaciones a tablas existentes:**
- `usuario.sede_id` - A qué sede pertenece (NULL = COP universal)
- `unidad.sede_id` - A qué sede pertenece la unidad
- `salida_unidad.sede_origen_id` - Desde qué sede salió

#### Funciones PostgreSQL:

**`obtener_sede_efectiva_usuario(usuario_id)`**
- Retorna sede efectiva considerando reasignaciones temporales

**`obtener_sede_efectiva_unidad(unidad_id)`**
- Retorna sede efectiva de unidad considerando reasignaciones

**`tiene_permiso_sede(usuario_id, sede_id)`**
- Verifica permisos jurisdiccionales
- COP = acceso universal a todas las sedes
- Otros roles = solo su sede

**`registrar_ingreso_sede()`**
- Registra ingreso a sede durante salida
- Si `es_ingreso_final = TRUE` → Marca salida como FINALIZADA

**`registrar_salida_de_sede()`**
- Marca que unidad volvió a salir después de ingreso temporal

#### Conceptos Clave:

**Permisos Jurisdiccionales:**
- **COP**: Acceso a TODAS las sedes (universal)
- **Operaciones/Admin**: Solo su sede
- Operaciones de CENTRAL NO puede crear salidas para SANCRISTO

**Ingresos Múltiples:**
- Unidad puede ingresar/salir varias veces: combustible, almuerzo, comisión
- Cada ingreso registra: tipo, km, combustible, observaciones
- Al salir de nuevo: registra km_salida_nueva, combustible_salida_nueva

**Finalización de Día:**
- Ingreso con `es_ingreso_final = TRUE`
- Automáticamente finaliza la salida
- Calcula km_recorridos, combustible_usado
- Libera unidad y tripulación

**Reasignaciones:**
- Brigadista de CENTRAL → SANCRISTO por 15 días (apoyo en puente caído)
- Unidad temporal para carrera de ciclismo
- Función `obtener_sede_efectiva_*` considera reasignaciones

#### Scripts ejecutados:
1. ✅ `patch-020-sedes.js` - Creó tablas
2. ✅ `create-funciones-vistas-020.js` - Creó funciones

---

### **5. Migración 021 - Gestión Manual de Grupos**
**Archivo**: `migrations/021_fix_verificar_acceso_app.sql`

#### Cambio de Paradigma:
- **ANTES**: Calendario generado automáticamente (rígido)
- **AHORA**: Gestión manual por Operaciones + Prioridad a Asignaciones

#### Lógica de Acceso (Orden de Prioridad):
1. **Asignación Activa**: Si brigadista tiene asignación en `brigada_unidad`, **SIEMPRE TIENE ACCESO** (incluso si su grupo está en descanso).
2. **Calendario Manual**: Si no tiene asignación, se verifica el estado manual del grupo en `calendario_grupo`.
   - `TRABAJO` → Acceso permitido
   - `DESCANSO` → Acceso denegado
3. **Default**: Si no hay entrada en calendario, se asume `TRABAJO`.

#### Nuevos Endpoints:
- `POST /api/grupos/:grupo/estado` - Establecer estado (TRABAJO/DESCANSO) para rango de fechas.
- `GET /api/grupos/acceso/verificar/:usuario_id` - Verificar si usuario tiene acceso y por qué.

#### Correcciones Realizadas:
- Se eliminó la dependencia estricta del calendario automático.
- Se limpiaron entradas futuras del calendario automático para evitar conflictos.
- Se corrigió error donde brigadistas asignados eran bloqueados por estar en "descanso".

#### Scripts ejecutados:
1. ✅ `migrations/021_fix_verificar_acceso_app.sql` - Actualizó función de acceso y vistas.

---

## 📋 Tareas Pendientes CRÍTICAS

### **ALTA PRIORIDAD - App Móvil**

#### 1. **Actualizar authStore.ts**
La app móvil actualmente llama:
```typescript
GET /api/turnos/mi-asignacion-hoy  // ❌ SISTEMA VIEJO
```

Debe cambiar a:
```typescript
GET /api/salidas/mi-unidad          // ✅ SISTEMA NUEVO (asignación permanente)
GET /api/salidas/mi-salida-activa   // ✅ SISTEMA NUEVO (salida activa)
```

**Archivo a modificar**: `mobile/src/store/authStore.ts`

**Cambios necesarios:**
- Reemplazar `refreshAsignacion()` por `refreshMiUnidad()` y `refreshMiSalidaActiva()`
- Actualizar interface de `asignacion` a nuevas estructuras
- Manejar caso de "tengo unidad pero NO tengo salida activa" → Mostrar pantalla de Iniciar Salida

#### 2. **Implementar Pantalla "Iniciar Salida"**
**Nueva pantalla**: `mobile/src/screens/brigada/IniciarSalidaScreen.tsx`

**Función:**
- Se muestra cuando el brigadista tiene unidad asignada pero NO salida activa
- Solicita:
  - Ruta inicial (opcional)
  - KM inicial del hodómetro
  - Combustible inicial (litros)
  - Observaciones
- Llama a `POST /api/salidas/iniciar`
- Al crear la salida, automáticamente redirige a `SalidaSedeScreen`

#### 3. **Hacer SalidaSedeScreen Obligatoria**
**Archivo**: `mobile/src/screens/brigada/SalidaSedeScreen.tsx`

**Flujo actual que debe implementarse:**
1. Login → Verificar acceso
2. Obtener mi unidad asignada
3. Obtener mi salida activa
4. **SI NO HAY SALIDA ACTIVA** → Mostrar IniciarSalidaScreen
5. **SI HAY SALIDA ACTIVA pero NO tiene SALIDA_SEDE** → Forzar SalidaSedeScreen
6. **SI tiene SALIDA_SEDE** → Permitir acceso a BrigadaHomeScreen

**Implementación:**
- Agregar flag en `authStore`: `necesita_salida_sede: boolean`
- Modificar `BrigadaNavigator` para verificar este flag
- Si está en true → Solo permitir acceso a SalidaSedeScreen
- Al completar SALIDA_SEDE → Cambiar flag a false

#### 4. **Actualizar Creación de Situaciones**
**Archivos:**
- `mobile/src/screens/brigada/IncidenteScreen.tsx`
- `mobile/src/screens/brigada/AsistenciaScreen.tsx`
- `mobile/src/screens/brigada/EmergenciaScreen.tsx`
- `mobile/src/screens/brigada/NuevaSituacionScreen.tsx`

**Cambio necesario:**
Todas las situaciones deben incluir:
```typescript
{
  ...datosSituacion,
  salida_unidad_id: miSalidaActiva.salida_id,  // ✅ NUEVO CAMPO REQUERIDO
  // Los campos turno_id, asignacion_id quedan DEPRECATED
}
```

---

### **MEDIA PRIORIDAD**

#### 5. **Implementar Pantalla "Ingreso a Sede"**
**Nueva pantalla**: `mobile/src/screens/brigada/IngresoSedeScreen.tsx`

**Función:**
- Permite registrar ingresos temporales a sede durante la salida
- Tipos de ingreso:
  - COMBUSTIBLE - Carga de combustible
  - ALMUERZO - Break de almuerzo
  - COMISION - Comisión administrativa
  - APOYO - Hotel/pernocta en eventos largos
  - MANTENIMIENTO - Reparación de unidad
- Solicita: KM ingreso, combustible ingreso, observaciones
- Llama a `POST /api/ingresos/registrar`
- Después puede "Salir de Sede" para volver a patrullar

#### 6. **Implementar Pantalla "Finalizar Día Laboral"**
**Nueva pantalla**: `mobile/src/screens/brigada/FinalizarDiaScreen.tsx`

**Función:**
- Registra ingreso FINAL que termina la jornada laboral
- Solicita:
  - Sede de ingreso final
  - KM final del hodómetro
  - Combustible final (litros)
  - Observaciones del día
- Llama a `POST /api/ingresos/registrar` con `es_ingreso_final = TRUE`
- Automáticamente finaliza la salida
- Muestra resumen:
  - KM recorridos totales
  - Combustible usado
  - Duración de la salida (horas)
  - Cantidad de ingresos durante el día
- Libera unidad y tripulación

#### 7. **Implementar Pantalla de Relevos**
**Nueva pantalla**: `mobile/src/screens/brigada/RelevoScreen.tsx`

**Función:**
- Permite registrar relevos entre unidades
- Tipos:
  - **UNIDAD_COMPLETA**: Mi unidad se retira, otra llega
  - **CRUZADO**: Mi tripulación se queda con otra unidad
- Llama a `POST /api/salidas/relevos`

#### 7. **Deprecar Sistema Viejo (Turnos)**
- Marcar `turno.routes.ts` como DEPRECATED
- Marcar `turno.model.ts` como DEPRECATED
- Agregar warning en endpoints viejos
- Mantener compatibilidad temporal para transición

---

## 📁 Estructura de Archivos Actualizada

```
proyectoProvialMovilWeb/
├── migrations/
│   └── 019_sistema_asignaciones_permanentes.sql  ✅ NUEVA
│
├── backend/src/
│   ├── models/
│   │   ├── salida.model.ts                       ✅ NUEVO
│   │   └── turno.model.ts                        ⚠ DEPRECATED
│   ├── controllers/
│   │   ├── salida.controller.ts                  ✅ NUEVO
│   │   └── turno.controller.ts                   ⚠ DEPRECATED
│   └── routes/
│       ├── salida.routes.ts                      ✅ NUEVO
│       ├── turno.routes.ts                       ⚠ DEPRECATED
│       └── index.ts                              ✅ MODIFICADO (registra /salidas)
│
├── mobile/src/
│   ├── store/
│   │   └── authStore.ts                          🔴 PENDIENTE ACTUALIZAR
│   └── screens/brigada/
│       ├── IniciarSalidaScreen.tsx               🔴 PENDIENTE CREAR
│       ├── SalidaSedeScreen.tsx                  ✅ EXISTE (enforcar)
│       ├── FinalizarSalidaScreen.tsx             🔴 PENDIENTE CREAR
│       ├── RelevoScreen.tsx                      🔴 PENDIENTE CREAR
│       ├── IncidenteScreen.tsx                   🔴 PENDIENTE ACTUALIZAR
│       ├── AsistenciaScreen.tsx                  🔴 PENDIENTE ACTUALIZAR
│       └── EmergenciaScreen.tsx                  🔴 PENDIENTE ACTUALIZAR
│
├── fix-017.js                                    ✅ EJECUTADO
├── create-vistas-funciones-019.js                ✅ EJECUTADO
├── asignar-brigada01-permanente.js               ✅ EJECUTADO
└── ESTADO_ACTUAL.md                              ✅ ESTE ARCHIVO
```

---

## 🔑 Conceptos Clave del Nuevo Sistema

### **Asignación Permanente**
- Un brigadista está asignado a UNA unidad
- La asignación es vigente hasta que se finalice manualmente
- Tiene un rol: PILOTO, COPILOTO, ACOMPAÑANTE

### **Salida**
- Es el equivalente a "turno" pero sin restricción de tiempo
- Se inicia cuando la unidad sale de sede
- Se finaliza cuando regresa a sede
- Estado: EN_SALIDA, FINALIZADA, CANCELADA
- Solo puede haber UNA salida activa por unidad

### **Primera Situación Obligatoria**
- La primera situación de una salida DEBE ser `SALIDA_SEDE`
- Esto se valida con un TRIGGER en PostgreSQL
- Si intentas crear otra situación primero → ERROR
- Esto garantiza que se registre la salida de sede

### **Relevo**
- Intercambio de unidades o tripulaciones en un punto
- UNIDAD_COMPLETA: Unidad A se retira, Unidad B llega
- CRUZADO: Tripulación de A se queda con unidad B, B se retira con A

### **Chapa**
- Identificación de brigadista (ej: 19109, 15056)
- Usado como username
- Facilita identificación rápida

---

## 🗄️ Endpoints API Nuevos

### **Asignaciones Permanentes**
```
GET    /api/salidas/mi-unidad                      [BRIGADA]
POST   /api/salidas/asignar-brigada                [OPERACIONES, ADMIN]
GET    /api/salidas/tripulacion/:unidadId          [ALL AUTH]
```

### **Salidas**
```
GET    /api/salidas/mi-salida-activa               [BRIGADA]
POST   /api/salidas/iniciar                        [BRIGADA]
POST   /api/salidas/:id/finalizar                  [BRIGADA, COP, OPERACIONES, ADMIN]
GET    /api/salidas/:id                            [ALL AUTH]
GET    /api/salidas/admin/unidades-en-salida       [COP, OPERACIONES, ADMIN]
GET    /api/salidas/historial/:unidadId            [ALL AUTH]
```

### **Relevos**
```
POST   /api/salidas/relevos                        [BRIGADA, COP, OPERACIONES]
GET    /api/salidas/relevos/:situacionId           [ALL AUTH]
```

### **Ingresos (PENDIENTE CREAR)**
```
POST   /api/ingresos/registrar                     [BRIGADA]
POST   /api/ingresos/:id/salir                     [BRIGADA]
GET    /api/ingresos/mi-ingreso-activo             [BRIGADA]
GET    /api/ingresos/historial/:salidaId           [ALL AUTH]
```

### **Sedes (PENDIENTE CREAR)**
```
GET    /api/sedes                                  [ALL AUTH]
GET    /api/sedes/:id                              [ALL AUTH]
POST   /api/sedes                                  [ADMIN]
GET    /api/sedes/:id/unidades                     [ALL AUTH]
GET    /api/sedes/:id/personal                     [ALL AUTH]
```

### **Reasignaciones (PENDIENTE CREAR)**
```
POST   /api/reasignaciones                         [OPERACIONES, ADMIN]
GET    /api/reasignaciones/activas                 [OPERACIONES, ADMIN, COP]
POST   /api/reasignaciones/:id/finalizar           [OPERACIONES, ADMIN]
```

---

## 🧪 Verificación del Sistema

### **Verificar asignación de brigada01:**
```sql
SELECT * FROM v_mi_unidad_asignada WHERE brigada_id = 4;
```

### **Verificar salida activa:**
```sql
SELECT * FROM v_mi_salida_activa WHERE brigada_id = 4;
```

### **Verificar unidades en salida:**
```sql
SELECT * FROM v_unidades_en_salida;
```

### **Iniciar nueva salida manualmente:**
```sql
SELECT iniciar_salida_unidad(
  1,           -- unidad_id (PROV-001)
  1,           -- ruta_inicial_id (CA-1)
  0.0,         -- km_inicial
  30.0,        -- combustible_inicial
  'Salida de prueba'
);
```

### **Finalizar salida manualmente:**
```sql
SELECT finalizar_salida_unidad(
  1,           -- salida_id
  120.5,       -- km_final
  15.0,        -- combustible_final
  'Regreso sin novedad',
  4            -- finalizada_por (usuario_id)
);
```

---

## 📝 Tareas Completadas Anteriormente

### **Sistema de Auto-guardado de Borradores**
- Hook: `mobile/src/hooks/useDraftSave.ts`
- Implementado en: IncidenteScreen, AsistenciaScreen, EmergenciaScreen
- Auto-guarda cada 1 segundo
- Recuperación al abrir pantalla

### **JWT Extendidos**
- Archivo: `backend/src/config/env.ts:34`
- Duración: 24 horas
- Razón: Turnos largos, emergencias nocturnas

### **Componentes Creados**
- `AutoridadSocorroManager.tsx` - Formularios de autoridades/socorro
- `GruaManager.tsx` - Gestión de grúas
- `AjustadorManager.tsx` - Gestión de ajustadores
- `ObstruccionManager.tsx` - Obstrucciones viales
- `VehiculoManager.tsx` - Vehículos involucrados
- `RutaSelector.tsx` - Selector de rutas

---

## 🔥 Instrucciones para Continuar

### **Paso 1: Actualizar App Móvil**
1. Modificar `authStore.ts` para usar nuevos endpoints
2. Crear `IniciarSalidaScreen.tsx`
3. Enforcar `SalidaSedeScreen.tsx` como primera acción
4. Actualizar creación de situaciones (agregar `salida_unidad_id`)

### **Paso 2: Implementar Endpoints de Ingresos y Sedes**
1. Crear controladores para ingresos a sede
2. Crear controladores para sedes
3. Crear controladores para reasignaciones
4. Actualizar modelo `salida.model.ts` con funciones de ingresos

### **Paso 3: Probar Flujo Completo**
1. Login con brigada01
2. Ver mi unidad asignada (PROV-001, Sede CENTRAL)
3. Iniciar salida desde sede
4. Registrar SALIDA_SEDE (primera situación obligatoria)
5. Trabajar en carretera (situaciones normales)
6. Ingreso temporal a sede (combustible/almuerzo)
7. Salir de sede nuevamente
8. Finalizar día laboral (ingreso final)

### **Paso 3: Deprecar Sistema Viejo**
1. Marcar endpoints `/api/turnos/*` como DEPRECATED
2. Agregar warnings en respuestas
3. Documentar migración para otros desarrolladores

---

### **Paso 4: Deprecar Sistema Viejo**
1. Marcar endpoints `/api/turnos/*` como DEPRECATED
2. Agregar warnings en respuestas
3. Documentar migración para otros desarrolladores

---

## 🎬 Para Claude al Reiniciar:

**Usuario dirá:** "continúa" o "sigue" o "revisa esto" o "documenta y continúa"

**Claude debe:**
1. Leer `ESTADO_ACTUAL.md` (este archivo)
2. Leer `DOCUMENTACION_SEDES_INGRESOS.md` (documentación completa de migración 020)
3. Entender que el sistema fue REDISEÑADO DOS veces:
   - **Migración 019**: Asignaciones permanentes + salidas sin límite de tiempo
   - **Migración 020**: Sedes + ingresos múltiples + reasignaciones
4. Enfocarse en pendientes CRÍTICOS de App Móvil
5. NO preguntar sobre el diseño, ya está implementado
6. Continuar con la implementación en orden:
   - Primero: Controladores backend de ingresos/sedes
   - Segundo: App móvil (authStore, pantallas)

**Estado actual:**
- ✅ Migración 019 completada (asignaciones permanentes)
- ✅ Migración 020 completada (sedes e ingresos)
- ✅ Funciones PostgreSQL creadas
- ✅ Documentación completa
- 🔴 Pendiente: Controladores backend de ingresos/sedes/reasignaciones
- 🔴 Pendiente: Actualizar app móvil para usar nuevo sistema

**Archivos clave para revisar:**
- `ESTADO_ACTUAL.md` - Resumen ejecutivo
- `DOCUMENTACION_SEDES_INGRESOS.md` - Documentación completa de migración 020
- `migrations/019_sistema_asignaciones_permanentes.sql` - Migración 019
- `migrations/020_sistema_sedes_ingresos.sql` - Migración 020
- `backend/src/models/salida.model.ts` - Modelo de salidas (pendiente actualizar con ingresos)

---

_Última actualización: 2025-11-30 01:30 GMT-6_
_Por: Claude (Claude Code)_
