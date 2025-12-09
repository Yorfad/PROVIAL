# Resumen de Implementación: Normalización de Datos

## Estado: COMPLETADO ✓

Fecha: 7 de Diciembre, 2025

---

## 1. Archivos de Migración SQL Creados

### A. Migración 024: Normalización de Tablas
**Archivo**: `migrations/024_normalize_incident_data.sql`

**Tablas creadas**:

1. **`vehiculo`** - Tabla maestra de vehículos (un registro por placa única)
   - Campos: placa, es_extranjero, tipo_vehiculo_id, color, marca_id, cargado, tipo_carga
   - Estadísticas: total_incidentes, primer_incidente, ultimo_incidente
   - Índice: idx_vehiculo_master_placa

2. **`tarjeta_circulacion`** - Datos de TC vinculados a vehículo
   - Campos: vehiculo_id, numero, nit, direccion_propietario, nombre_propietario, modelo
   - Relación: CASCADE con vehiculo
   - Índices: vehiculo_id, numero, nit

3. **`piloto`** - Tabla maestra de pilotos (un registro por licencia única)
   - Campos: nombre, licencia_tipo (A|B|C|M|E), licencia_numero (UNIQUE), licencia_vencimiento
   - Datos: licencia_antiguedad, fecha_nacimiento, etnia
   - Estadísticas: total_incidentes, total_sanciones, primer_incidente, ultimo_incidente
   - Índice: idx_piloto_licencia

4. **`contenedor`** - Datos de contenedores vinculados a vehículo
   - Campos: vehiculo_id, numero_contenedor, linea_naviera, tipo_contenedor
   - Relación: CASCADE con vehiculo

5. **`bus`** - Datos de buses vinculados a vehículo
   - Campos: vehiculo_id, empresa, ruta_bus, numero_unidad, capacidad_pasajeros
   - Relación: CASCADE con vehiculo

6. **`articulo_sancion`** - Catálogo de artículos de ley de tránsito
   - Campos: numero (UNIQUE), descripcion, monto_multa, puntos_licencia, activo
   - Ejemplos: Art. 145-149 (conducir sin licencia, exceso velocidad, ebriedad, etc.)

7. **`sancion`** - Sanciones aplicadas en incidentes
   - Relaciones: incidente_id, vehiculo_id, piloto_id, articulo_sancion_id
   - Campos: descripcion, monto, pagada, fecha_pago, aplicada_por
   - Índices: incidente, vehiculo, piloto, articulo

8. **`grua`** - Tabla maestra de grúas (catálogo reutilizable)
   - Campos: nombre, placa, telefono, empresa, nit
   - Estadísticas: total_servicios, ultima_vez_usado
   - Estado: activa
   - Índices: nombre, empresa, placa

9. **`aseguradora`** - Tabla maestra de aseguradoras
   - Campos: nombre (UNIQUE), codigo, telefono, email
   - Estadísticas: total_incidentes
   - Estado: activa

10. **`incidente_vehiculo`** - Relación many-to-many incidentes-vehículos
    - Relaciones: incidente_id, vehiculo_id, piloto_id, aseguradora_id
    - Campos: estado_piloto, personas_asistidas, numero_poliza
    - Índices: incidente, vehiculo, piloto

11. **`incidente_grua`** - Relación many-to-many incidentes-grúas
    - Relaciones: incidente_id, grua_id
    - Campos: hora_llamada, hora_llegada, destino, costo
    - Índices: incidente, grua

**Triggers implementados**:
- `update_vehiculo_stats()` - Actualiza contadores en tabla vehiculo
- `update_piloto_stats()` - Actualiza contadores de incidentes en piloto
- `update_piloto_sancion_stats()` - Actualiza contadores de sanciones en piloto
- `update_grua_stats()` - Actualiza contadores de servicios en grua
- `update_aseguradora_stats()` - Actualiza contadores en aseguradora
- Triggers de updated_at para vehiculo, piloto, grua

---

### B. Migración 024b: Migración de Datos Existentes
**Archivo**: `migrations/024b_migrate_existing_data.sql`

**Script de migración que incluye**:

1. **Migración de vehículos** desde `vehiculo_incidente`
   - INSERT con DISTINCT ON (placa)
   - Actualización de contadores total_incidentes, primer_incidente, ultimo_incidente

2. **Migración de pilotos** desde `vehiculo_incidente`
   - INSERT con DISTINCT ON (licencia_numero)
   - Conversión de tipo BIGINT
   - Actualización de contadores

3. **Migración de tarjetas de circulación**
   - JOIN con vehiculo para obtener vehiculo_id
   - Validación de datos numéricos

4. **Migración de contenedores**
   - Extracción desde contenedor_detalle (JSONB)
   - Solo registros con contenedor = TRUE

5. **Migración de buses**
   - Extracción desde bus_detalle (JSONB)
   - Solo registros con bus_extraurbano = TRUE

6. **Migración de grúas** desde `grua_involucrada`
   - INSERT con DISTINCT ON (piloto, empresa, placa)
   - Actualización de contadores de servicios

7. **Migración de relaciones incidente-vehiculo**
   - Creación de vínculos many-to-many
   - LEFT JOIN con piloto

8. **Migración de relaciones incidente-grúa**
   - Solo cuando traslado = TRUE
   - LEFT JOIN con grua

9. **Consulta de verificación**
   - Resumen de totales migrados por tabla

**IMPORTANTE**: Las tablas antiguas NO se eliminan (se mantienen por seguridad)

---

## 2. Modelos Backend Actualizados/Creados

### A. `backend/src/models/vehiculo.model.ts` ✓ ACTUALIZADO

**Interfaces**:
- `Vehiculo` - Entidad completa con JOINs
- `CreateVehiculoDTO` - DTO para crear/actualizar
- `TarjetaCirculacion` - Datos de TC
- `Contenedor` - Datos de contenedor
- `Bus` - Datos de bus

**Métodos implementados**:

✓ `getOrCreate(data)` - Obtener vehículo existente o crear uno nuevo
- Busca por placa
- Si no existe, llama a upsert()
- Retorna: Promise<Vehiculo>

✓ `findByPlaca(placa)` - Buscar por placa
- Incluye JOINs con tipo_vehiculo y marca_vehiculo
- Retorna: Promise<Vehiculo | null>

✓ `findById(id)` - Buscar por ID
- Incluye JOINs con tipo_vehiculo y marca_vehiculo
- Retorna: Promise<Vehiculo | null>

✓ `upsert(data)` - Crear o actualizar vehículo
- ON CONFLICT (placa) DO UPDATE
- Actualiza todos los campos excepto placa
- Retorna: Promise<Vehiculo>

✓ `getHistorial(placa)` - Obtener historial de incidentes
- JOIN con incidente, incidente_vehiculo, piloto, tipo_hecho, ruta, usuario
- Campos: tipo_hecho_nombre, ruta_codigo, estado_piloto, piloto_nombre, reportado_por
- Ordenado por created_at DESC
- Retorna: Promise<any[]>

✓ `update(placa, data)` - Actualizar datos del vehículo
- Valida que exista
- Llama a upsert() con placa + nuevos datos
- Retorna: Promise<Vehiculo | null>

✓ `findTopByIncidentes(limit)` - Top vehículos reincidentes
- WHERE total_incidentes > 0
- ORDER BY total_incidentes DESC
- Retorna: Promise<Vehiculo[]>

**Métodos de relaciones**:
- `getTarjetaCirculacion(vehiculoId)` - Última TC registrada
- `createTarjetaCirculacion(data)` - Crear nueva TC
- `getContenedor(vehiculoId)` - Último contenedor registrado
- `createContenedor(data)` - Crear nuevo contenedor
- `getBus(vehiculoId)` - Último bus registrado
- `createBus(data)` - Crear nuevo bus

---

### B. `backend/src/models/piloto.model.ts` ✓ ACTUALIZADO

**Interfaces**:
- `Piloto` - Entidad completa
- `CreatePilotoDTO` - DTO para crear/actualizar

**Métodos implementados**:

✓ `getOrCreate(data)` - Obtener piloto existente o crear uno nuevo
- Busca por licencia_numero
- Si no existe, llama a upsert()
- Retorna: Promise<Piloto>

✓ `findByLicencia(licenciaNumero)` - Buscar por número de licencia
- Retorna: Promise<Piloto | null>

✓ `findById(id)` - Buscar por ID
- Retorna: Promise<Piloto | null>

✓ `upsert(data)` - Crear o actualizar piloto
- ON CONFLICT (licencia_numero) DO UPDATE
- Actualiza todos los campos excepto licencia_numero
- Retorna: Promise<Piloto>

✓ `getHistorial(licenciaNumero)` - Obtener historial de incidentes
- JOIN con incidente, incidente_vehiculo, vehiculo, tipo_hecho, ruta, usuario
- Campos: tipo_hecho_nombre, vehiculo_placa, vehiculo_color, vehiculo_tipo, reportado_por
- Ordenado por created_at DESC
- Retorna: Promise<any[]>

✓ `update(licenciaNumero, data)` - Actualizar datos del piloto
- Valida que exista
- Llama a upsert() con licencia_numero + nuevos datos
- Retorna: Promise<Piloto | null>

✓ `findTopByIncidentes(limit)` - Top pilotos reincidentes
✓ `findTopBySanciones(limit)` - Top pilotos con más sanciones
✓ `isLicenciaVencida(licenciaNumero)` - Verificar vencimiento de licencia
✓ `findLicenciasProximasVencer(dias)` - Licencias por vencer en N días

**Tipos de licencia validados**:
- A: Motocicletas
- B: Vehículos livianos
- C: Vehículos pesados
- M: Maquinaria
- E: Especial

---

### C. `backend/src/models/gruaMaster.model.ts` ✓ ACTUALIZADO

**Interfaces**:
- `GruaMaster` - Entidad completa
- `CreateGruaMasterDTO` - DTO para crear/actualizar
- `IncidenteGrua` - Relación con incidente

**Métodos implementados**:

✓ `getOrCreate(data)` - Obtener grúa existente o crear una nueva
- Busca por placa si existe
- Busca por nombre + empresa
- Si no existe, llama a upsert()
- Retorna: Promise<GruaMaster>

✓ `findById(id)` - Buscar por ID
✓ `findByNombreEmpresa(nombre, empresa)` - Buscar por nombre y empresa
✓ `findByPlaca(placa)` - Buscar por placa

✓ `upsert(data)` - Crear o actualizar grúa
- ON CONFLICT (nombre, empresa) DO UPDATE
- Retorna: Promise<GruaMaster>

✓ `getHistorial(gruaId)` - Obtener historial de servicios
- JOIN con incidente, incidente_grua, tipo_hecho, ruta, usuario
- Campos: tipo_hecho_nombre, hora_llamada, hora_llegada, destino, costo
- Ordenado por created_at DESC
- Retorna: Promise<any[]>

✓ `update(gruaId, data)` - Actualizar datos de la grúa
- Valida que exista
- Llama a upsert() con nombre + nuevos datos
- Retorna: Promise<GruaMaster | null>

✓ `findAllActive()` - Listar grúas activas
✓ `findTopByServicios(limit)` - Top grúas con más servicios
✓ `deactivate(id)` - Desactivar grúa
✓ `activate(id)` - Activar grúa

**Métodos de relaciones**:
- `createIncidenteGrua(data)` - Registrar servicio de grúa
- `getServicios(gruaId)` - Obtener servicios de una grúa
- `getByIncidente(incidenteId)` - Obtener grúas de un incidente

---

### D. `backend/src/models/aseguradora.model.ts` ✓ ACTUALIZADO

**Interfaces**:
- `Aseguradora` - Entidad completa
- `CreateAseguradoraDTO` - DTO para crear/actualizar

**Métodos implementados**:

✓ `getOrCreate(data)` - Obtener aseguradora existente o crear una nueva
- Busca por nombre
- Si no existe, llama a upsert()
- Retorna: Promise<Aseguradora>

✓ `findByNombre(nombre)` - Buscar por nombre
- Retorna: Promise<Aseguradora | null>

✓ `findById(id)` - Buscar por ID
- Retorna: Promise<Aseguradora | null>

✓ `upsert(data)` - Crear o actualizar aseguradora
- ON CONFLICT (nombre) DO UPDATE
- Retorna: Promise<Aseguradora>

✓ `getHistorial(aseguradoraId)` - Obtener historial de incidentes
- JOIN con incidente, incidente_vehiculo, vehiculo, tipo_hecho, ruta, usuario
- Campos: tipo_hecho_nombre, numero_poliza, vehiculo_placa, reportado_por
- Ordenado por created_at DESC
- Retorna: Promise<any[]>

✓ `update(aseguradoraId, data)` - Actualizar datos de la aseguradora
- Valida que exista
- Llama a upsert() con nombre + nuevos datos
- Retorna: Promise<Aseguradora | null>

✓ `findAllActive()` - Listar aseguradoras activas
✓ `findTopByIncidentes(limit)` - Top aseguradoras con más incidentes
✓ `deactivate(id)` - Desactivar aseguradora
✓ `activate(id)` - Activar aseguradora

---

### E. `backend/src/models/grua.model.ts` ✓ EXISTENTE (SIN CAMBIOS)

Este modelo maneja la tabla antigua `grua_involucrada` y permanece sin cambios para mantener compatibilidad.

---

## 3. Especificaciones Técnicas Confirmadas

### Formato de Placa Guatemalteca
- **Patrón**: L###LLL (1 letra, 3 números, 3 letras)
- **Regex**: `/^[A-Z]\d{3}[A-Z]{3}$/`
- **Ejemplos válidos**: P512KJF, C589SJY, O789ASD
- **Ejemplos inválidos**: ABC123, 123ABC, P-512-KJF
- **Excepción**: Placas extranjeras (campo `es_extranjero = TRUE`, sin validación)

### Tipos de Licencia (Enum)
```sql
CHECK (licencia_tipo IN ('A','B','C','M','E'))
```
- **A**: Motocicletas
- **B**: Vehículos livianos
- **C**: Vehículos pesados
- **M**: Maquinaria
- **E**: Especial

---

## 4. Características Implementadas

### Normalización de Datos
✓ Eliminación de duplicación de datos en vehículos y pilotos
✓ Relaciones many-to-many entre incidentes, vehículos, pilotos, grúas y aseguradoras
✓ Tablas maestras con registros únicos (vehiculo, piloto, grua, aseguradora)
✓ Separación de datos específicos (tarjeta_circulacion, contenedor, bus, sancion)

### Integridad Referencial
✓ Foreign keys con ON DELETE CASCADE para dependencias
✓ Foreign keys con ON DELETE SET NULL para referencias opcionales
✓ Constraints UNIQUE en campos clave (placa, licencia_numero, nombre aseguradora)
✓ Constraints CHECK en tipos de licencia

### Optimización
✓ Índices en todas las columnas de búsqueda frecuente
✓ Índices en foreign keys para JOINs eficientes
✓ Campos calculados (total_incidentes, total_sanciones) actualizados por triggers
✓ Triggers automáticos para estadísticas

### Compatibilidad
✓ Migración de datos existentes desde tablas antiguas
✓ Tablas antiguas mantenidas para rollback si es necesario
✓ Script de verificación incluido en migración

### API Models
✓ Métodos getOrCreate() para operaciones idempotentes
✓ Métodos getHistorial() para consultas completas con JOINs
✓ Métodos update() para actualizaciones parciales
✓ Métodos de búsqueda múltiples (por ID, placa, licencia, nombre)
✓ Métodos de estadísticas (top reincidentes, top servicios)

---

## 5. Próximos Pasos (Fase 3: Sistema de Inteligencia)

### Pendientes para completar el sistema:

1. **Vistas Materializadas** (migrations/025_intelligence_views.sql - YA EXISTE)
   - mv_vehiculo_historial
   - mv_piloto_historial
   - Función de refresh automático

2. **Endpoints de Inteligencia** (backend)
   - GET /api/intelligence/vehiculo/:placa
   - GET /api/intelligence/piloto/:licencia
   - GET /api/intelligence/top-reincidentes
   - GET /api/intelligence/dashboard

3. **Alertas en Tiempo Real** (mobile)
   - PlacaInput con detección automática
   - Banner de alerta si vehículo tiene historial
   - Modal con historial detallado

4. **Dashboard Web** (web)
   - Top 10 vehículos reincidentes
   - Top 10 pilotos reincidentes
   - Mapa de calor de incidentes
   - Filtros y exportación a Excel

---

## 6. Comandos para Ejecutar Migraciones

### IMPORTANTE: NO EJECUTAR AÚN - Solo cuando se autorice

```bash
# 1. Backup de la base de datos (OBLIGATORIO)
pg_dump -h localhost -U postgres -d provial > backup_pre_normalizacion.sql

# 2. Ejecutar migración de tablas
psql -h localhost -U postgres -d provial -f migrations/024_normalize_incident_data.sql

# 3. Ejecutar migración de datos
psql -h localhost -U postgres -d provial -f migrations/024b_migrate_existing_data.sql

# 4. Verificar resultados
psql -h localhost -U postgres -d provial -c "SELECT * FROM vehiculo LIMIT 5;"
psql -h localhost -U postgres -d provial -c "SELECT * FROM piloto LIMIT 5;"
```

---

## 7. Resumen de Archivos Modificados/Creados

### Archivos de Migración SQL
- ✓ `migrations/024_normalize_incident_data.sql` (EXISTENTE - verificado)
- ✓ `migrations/024b_migrate_existing_data.sql` (EXISTENTE - verificado)

### Modelos Backend (TypeScript)
- ✓ `backend/src/models/vehiculo.model.ts` (ACTUALIZADO)
  - Agregado: getOrCreate(), getHistorial(), update()

- ✓ `backend/src/models/piloto.model.ts` (ACTUALIZADO)
  - Agregado: getOrCreate(), getHistorial(), update()

- ✓ `backend/src/models/gruaMaster.model.ts` (ACTUALIZADO)
  - Agregado: getOrCreate(), getHistorial(), update()

- ✓ `backend/src/models/aseguradora.model.ts` (ACTUALIZADO)
  - Agregado: getOrCreate(), getHistorial(), update()

- ✓ `backend/src/models/grua.model.ts` (SIN CAMBIOS - mantiene compatibilidad)

---

## 8. Métricas de Éxito Esperadas

### Calidad de Datos
- 100% de placas válidas o marcadas como extranjeras
- 0% de datos duplicados en vehículos y pilotos
- Historial completo y trazable de cada vehículo/piloto

### Performance
- Consultas de historial: <500ms
- Operaciones getOrCreate(): <200ms
- Triggers automáticos: <10ms

### Capacidad Analítica
- Detección de reincidencias: 100%
- Estadísticas en tiempo real
- Trazabilidad completa de sanciones

---

## 9. Notas Importantes

1. **Migración es reversible**: Las tablas antiguas se mantienen intactas
2. **Triggers automáticos**: Los contadores se actualizan automáticamente
3. **Validación de datos**: CHECK constraints garantizan integridad
4. **Índices optimizados**: Búsquedas rápidas por todos los campos clave
5. **Compatibilidad**: Modelos antiguos siguen funcionando

---

**Estado Final**: IMPLEMENTACIÓN COMPLETA - LISTO PARA TESTING

**Próximo paso**: Ejecutar migraciones en ambiente de desarrollo para pruebas
