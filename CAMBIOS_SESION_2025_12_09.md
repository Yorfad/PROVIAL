# Cambios Sesion 9 Diciembre 2025

## IMPORTANTE: Reiniciar Backend
Despues de sincronizar los cambios, reiniciar el backend:
```bash
cd backend
# Si esta corriendo con npm run dev, detenerlo (Ctrl+C) y volver a ejecutar:
npm run dev
```

---

## Resumen de Cambios Realizados

### 1. Sistema de Asignaciones Futuras
**Problema**: Las asignaciones se crean HOY para que la unidad salga MAÑANA (o dias futuros).
**Solucion**:
- Vista `v_mi_asignacion_hoy` modificada para mostrar asignaciones de HOY en adelante
- Campo `dias_para_salida` agregado: 0=HOY, 1=MAÑANA, N=EN N DIAS

**Archivos modificados**:
- `migrations/040_turnos_rango_fechas.sql` - Migracion principal

### 2. Soporte para Comisiones Largas (Rango de Fechas)
**Problema**: Algunas comisiones duran varios dias.
**Solucion**:
- Campo `fecha_fin` agregado a tabla `turno`
- Checkbox "Comision larga" en CrearAsignacionPage

**Archivos modificados**:
- `backend/src/models/turno.model.ts` - Tipo MiAsignacionHoy actualizado, metodo create con fecha_fin
- `backend/src/controllers/turno.controller.ts` - createTurno acepta fecha_fin
- `web/src/services/turnos.service.ts` - CreateTurnoDTO con fecha_fin
- `web/src/pages/CrearAsignacionPage.tsx` - UI para fecha_fin

### 3. Validacion de Unidad No Duplicada
**Regla**: No se puede asignar la misma unidad dos veces en el mismo dia.
**Solucion**:
- Funcion `validar_disponibilidad_unidad_fecha()` creada
- Trigger `trg_validar_asignacion_unidad` en INSERT/UPDATE

### 4. Iniciar Salida con Asignacion de Turno
**Problema**: El endpoint `/api/salidas/iniciar` solo buscaba asignaciones permanentes.
**Solucion**: Ahora busca PRIMERO en asignaciones de turno, luego en permanentes.

**Archivos modificados**:
- `backend/src/controllers/salida.controller.ts` - Import TurnoModel, logica unificada

### 5. Endpoint para Asignaciones Pendientes
**Nuevo endpoint**: `GET /api/turnos/pendientes`
- Devuelve todas las asignaciones de hoy y futuras
- Usado por OperacionesPage

**Archivos modificados**:
- `backend/src/controllers/turno.controller.ts` - Nuevo metodo getAsignacionesPendientes
- `backend/src/routes/turno.routes.ts` - Nueva ruta /pendientes

### 6. Tokens Extendidos a 12 Horas
**Archivo**: `backend/.env`
```
JWT_EXPIRES_IN=12h
```

### 7. Sistema de Diseño Web Estandarizado
**Archivo**: `web/src/index.css`
- Clases reutilizables: `.btn-primary`, `.input-field`, `.card`, `.table-header`, etc.
- Modo oscuro eliminado por defecto

### 8. Movil - Badge Dinamico
**Archivo**: `mobile/src/screens/brigada/BrigadaHomeScreen.tsx`
- Badge muestra "HOY" (verde), "MAÑANA" (azul), "EN N DIAS" (azul)
- Muestra fecha de salida cuando es futura

### 9. Fix: Import de Base de Datos en turno.controller.ts
**Error**: `Cannot find module '../db'`
**Causa**: Import incorrecto agregado
**Solucion**: Cambiar `import db from '../db'` a `import { db } from '../config/database'`

**Archivo corregido**: `backend/src/controllers/turno.controller.ts`

### 10. Modo Edicion en CrearAsignacionPage
**Problema**: Al editar una asignacion, el formulario aparecia vacio.
**Causa**: CrearAsignacionPage no leia el state de navegacion para pre-llenar el formulario.
**Solucion**:
- Agregado `useLocation()` para leer state de navegacion
- Agregada logica para pre-llenar campos con datos de asignacion existente
- Agregada mutation para actualizar asignacion existente
- Titulo y boton cambian segun modo (crear/editar)

**Archivo modificado**: `web/src/pages/CrearAsignacionPage.tsx`

### 11. Fix: ruta_id en vista v_mi_asignacion_hoy
**Problema**: El movil no podia iniciar salida porque faltaba `ruta_id` en la vista.
**Solucion**: Agregado `r.id AS ruta_id` a la vista.

**Archivo creado**: `migrations/041_fix_vista_mi_asignacion.sql`

### 12. Fix: Invalid Date en movil
**Problema**: La fecha de asignacion mostraba "Invalid Date".
**Causa**: El formato de fecha de PostgreSQL no era manejado correctamente.
**Solucion**: Funcion `formatFechaAsignacion()` con manejo seguro de fechas.

**Archivo modificado**: `mobile/src/screens/brigada/BrigadaHomeScreen.tsx`

### 13. Fix: Eliminar y Editar asignaciones
**Problema**: No se podia eliminar ni editar asignaciones.
**Causa**: La vista `v_asignaciones_pendientes` usa `asignacion_id` pero el frontend buscaba `id`.
**Solucion**:
- Corregido referencias para usar `asignacion_id || id`
- Agregado `ruta_id`, `km_inicio`, `km_final`, `sentido`, `hora_salida`, `hora_entrada_estimada` a la vista
- Agregado alias `id` en la vista para compatibilidad

**Archivos modificados**:
- `web/src/pages/OperacionesPage.tsx`
- `migrations/041_fix_vista_mi_asignacion.sql` (actualizada)

### 14. Fix: Movil no permite iniciar salida con asignacion de turno
**Problema**: El brigada tenia asignacion de turno pero IniciarSalidaScreen solo verificaba asignacion permanente.
**Solucion**:
- IniciarSalidaScreen ahora carga y verifica asignacion de turno (turnosAPI.getMiAsignacionHoy)
- Usa `asignacionEfectiva = asignacionTurno || asignacion`
- Muestra badge con tipo de turno (HOY, MANANA, EN N DIAS)
- Muestra loading mientras verifica asignacion

**Archivo modificado**: `mobile/src/screens/brigada/IniciarSalidaScreen.tsx`

### 15. Fix: Mensajes de ayuda en BrigadaHomeScreen
**Problema**: Mensaje "No tienes unidad asignada" aparecia aunque tuviera asignacion de turno.
**Solucion**: Los mensajes de ayuda ahora consideran tanto `asignacion` como `asignacionDia`.

**Archivo modificado**: `mobile/src/screens/brigada/BrigadaHomeScreen.tsx`

### 16. Fix: Vista v_mi_salida_activa no encontraba salidas de turno
**Problema CRITICO**: Despues de iniciar salida, el movil no desbloqueaba opciones de situaciones.
**Causa**: La vista `v_mi_salida_activa` SOLO buscaba en `brigada_unidad` (asignaciones permanentes).
**Solucion**: Vista modificada con UNION para considerar tambien `tripulacion_turno` (asignaciones de turno).
**Campos nuevos**: `tipo_asignacion` (PERMANENTE/TURNO), `mi_rol`, `tipo_unidad`

**Archivos modificados**:
- `migrations/042_fix_vista_mi_salida_activa.sql` (NUEVO)
- `backend/src/models/salida.model.ts` (interfaz MiSalidaActiva actualizada)

### 17. GPS automatico vs manual segun modo de pruebas
**Comportamiento**:
- **Modo Pruebas ACTIVADO**: Coordenadas se ingresan manualmente (campos editables)
- **Modo Pruebas DESACTIVADO**: Coordenadas se obtienen automaticamente del GPS del dispositivo

**Cambios en NuevaSituacionScreen.tsx**:
- Importa `useTestMode` del contexto
- Importa `expo-location` para obtener ubicacion GPS
- Si `testModeEnabled = true`: muestra inputs manuales de latitud/longitud
- Si `testModeEnabled = false`: obtiene ubicacion GPS automaticamente y muestra estado
- Campo `ubicacion_manual` ahora refleja el estado del modo de pruebas

**Archivo modificado**: `mobile/src/screens/brigada/NuevaSituacionScreen.tsx`

---

## Migraciones Pendientes de Aplicar
Si la otra PC no tiene las migraciones aplicadas:

```bash
# Conectar a la base de datos y aplicar migraciones
docker exec -i provial_postgres psql -U postgres -d provial_db < migrations/039_fix_validar_disponibilidad_brigada.sql
docker exec -i provial_postgres psql -U postgres -d provial_db < migrations/040_turnos_rango_fechas.sql
docker exec -i provial_postgres psql -U postgres -d provial_db < migrations/041_fix_vista_mi_asignacion.sql
docker exec -i provial_postgres psql -U postgres -d provial_db < migrations/042_fix_vista_mi_salida_activa.sql
```

O usando PowerShell:
```powershell
Get-Content migrations/039_fix_validar_disponibilidad_brigada.sql | docker exec -i provial_postgres psql -U postgres -d provial_db
Get-Content migrations/040_turnos_rango_fechas.sql | docker exec -i provial_postgres psql -U postgres -d provial_db
Get-Content migrations/041_fix_vista_mi_asignacion.sql | docker exec -i provial_postgres psql -U postgres -d provial_db
Get-Content migrations/042_fix_vista_mi_salida_activa.sql | docker exec -i provial_postgres psql -U postgres -d provial_db
```

---

## Vista v_mi_asignacion_hoy Actualizada
La vista ahora incluye:
- `ruta_id` - ID de la ruta
- `fecha_fin` - Para comisiones largas
- `hora_salida_real` - Si ya salio
- `dias_para_salida` - Dias hasta la salida
- `companeros` - JSON con info de companeros (usuario_id, nombre, chapa, rol, telefono)

SQL para recrear la vista (ejecutar si da problemas):
```sql
DROP VIEW IF EXISTS v_mi_asignacion_hoy;
CREATE VIEW v_mi_asignacion_hoy AS
SELECT
    usr.id AS usuario_id,
    usr.nombre_completo,
    t.id AS turno_id,
    t.fecha,
    t.fecha_fin,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    tc.rol_tripulacion AS mi_rol,
    r.id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
    CASE
        WHEN a.km_inicio IS NOT NULL AND a.km_final IS NOT NULL
            THEN 'Km ' || a.km_inicio || ' - Km ' || a.km_final
        WHEN a.km_inicio IS NOT NULL THEN 'Desde Km ' || a.km_inicio
        WHEN a.km_final IS NOT NULL THEN 'Hasta Km ' || a.km_final
        ELSE NULL
    END AS recorrido_permitido,
    a.hora_salida,
    a.hora_entrada_estimada,
    a.hora_salida_real,
    CASE
        WHEN t.fecha = CURRENT_DATE THEN 0
        ELSE t.fecha - CURRENT_DATE
    END AS dias_para_salida,
    (
        SELECT json_agg(
            json_build_object(
                'usuario_id', u2.id,
                'nombre', u2.nombre_completo,
                'chapa', u2.chapa,
                'rol', tc2.rol_tripulacion,
                'telefono', u2.telefono
            ) ORDER BY
                CASE tc2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPANANTE' THEN 3
                    ELSE 4
                END
        )
        FROM tripulacion_turno tc2
        JOIN usuario u2 ON tc2.usuario_id = u2.id
        WHERE tc2.asignacion_id = a.id
        AND tc2.usuario_id <> usr.id
    ) AS companeros
FROM usuario usr
JOIN tripulacion_turno tc ON usr.id = tc.usuario_id
JOIN asignacion_unidad a ON tc.asignacion_id = a.id
JOIN turno t ON a.turno_id = t.id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
WHERE
    (t.fecha >= CURRENT_DATE OR (t.fecha_fin IS NOT NULL AND t.fecha_fin >= CURRENT_DATE))
    AND t.estado IN ('PLANIFICADO', 'ACTIVO')
    AND a.hora_entrada_real IS NULL;
```

---

## Pruebas Recomendadas

1. **Crear asignacion para mañana**: Ir a /operaciones -> Crear Asignacion -> Fecha = mañana
2. **Ver asignacion en movil**: Login como brigada asignada -> Debe ver "MAÑANA" en badge azul
3. **Iniciar salida**: El brigada debe poder iniciar salida aunque la asignacion sea para mañana
4. **Editar/Eliminar**: En /operaciones debe poder editar o eliminar asignaciones que no han salido
5. **Validar duplicado**: Intentar asignar la misma unidad dos veces el mismo dia -> Debe fallar

---

## Archivos Clave Modificados (para git diff)
```
backend/src/controllers/salida.controller.ts
backend/src/controllers/turno.controller.ts
backend/src/models/turno.model.ts
backend/src/models/salida.model.ts
backend/src/routes/turno.routes.ts
backend/.env
web/src/index.css
web/src/pages/CrearAsignacionPage.tsx
web/src/pages/OperacionesPage.tsx
web/src/services/turnos.service.ts
mobile/src/screens/brigada/BrigadaHomeScreen.tsx
mobile/src/screens/brigada/IniciarSalidaScreen.tsx
mobile/src/screens/brigada/NuevaSituacionScreen.tsx
migrations/039_fix_validar_disponibilidad_brigada.sql
migrations/042_fix_vista_mi_salida_activa.sql
migrations/040_turnos_rango_fechas.sql
migrations/041_fix_vista_mi_asignacion.sql
```
