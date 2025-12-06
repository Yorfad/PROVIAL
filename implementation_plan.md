# Plan de Implementación - Correcciones de Formulario y Sistema de Inteligencia

## 📋 Resumen Ejecutivo

Este documento detalla la implementación de **correcciones críticas al formulario de incidentes** y un **sistema de inteligencia** para detectar reincidencias de vehículos y pilotos problemáticos. El trabajo se divide en 3 fases:

1. **Fase 1**: Correcciones urgentes al formulario (14 issues reportados)
2. **Fase 2**: Normalización de base de datos (8 tablas maestras)
3. **Fase 3**: Sistema de inteligencia con alertas en tiempo real

---

## 🔴 PROBLEMÁTICA ACTUAL
continua con la insercion

### Contexto General

El sistema actual de reportes de incidentes tiene **deficiencias críticas** que afectan:
- **Calidad de datos**: Información duplicada, inconsistente, sin validación
- **Experiencia de usuario**: Formularios confusos, flujos ilógicos, pérdida de datos
- **Capacidad analítica**: Imposible detectar patrones o reincidencias
- **Eficiencia operativa**: Brigadistas pierden tiempo en tareas manuales repetitivas

### Problema 1: Comportamiento Errático del Borrador (Issues #1-2)

**Situación actual**:
- Cuando un brigadista reporta un incidente, el sistema guarda un "borrador" automático
- Si el brigadista sale de la pantalla (por llamada, emergencia, etc.) y regresa, el sistema pregunta si quiere recuperar el borrador
- **PROBLEMA**: El borrador incluye las coordenadas GPS del momento anterior, que ya no son válidas
- **PROBLEMA**: La pregunta de confirmación es innecesaria y confunde al usuario

**Impacto**:
- ❌ Incidentes reportados con coordenadas GPS incorrectas (ubicación del brigadista cuando salió, no del incidente)
- ❌ Fricción en UX: el brigadista debe decidir si recuperar o no, cuando debería ser automático
- ❌ Pérdida de datos: si el brigadista rechaza el borrador, pierde todo el trabajo previo

**Solución requerida**:
1. Excluir `coordenadas` del borrador (siempre obtener GPS fresco al regresar)
2. Eliminar diálogo de confirmación (auto-restaurar siempre)

---

### Problema 2: Selección de Ruta Ilógica (Issue #3)

**Situación actual**:
- El formulario permite al brigadista **seleccionar manualmente** la ruta donde ocurrió el incidente
- Ejemplo absurdo: Un brigadista en CA-1 Occidente (Quetzaltenango) puede reportar un incidente en CA-9 Norte (Petén), a 400km de distancia

**Impacto**:
- ❌ Datos geográficos inconsistentes (ruta ≠ coordenadas GPS)
- ❌ Reportes inválidos que contaminan estadísticas
- ❌ Confusión en COP: ¿el incidente está donde dice la ruta o donde dice el GPS?

**Solución requerida**:
- Eliminar selector de ruta
- Auto-asignar la ruta desde `asignacion.ruta_asignada_id` (ruta actual de la unidad)
- Si el brigadista necesita cambiar de ruta, debe usar la función "Cambio de Ruta" ANTES de reportar

---

### Problema 3: Validación de Placas Inexistente (Issue #6)

**Situación actual**:
- El campo "placa" es un input de texto libre sin validación
- Se aceptan placas como: "ABC", "123456789", "no se", "N/A"

**Impacto**:
- ❌ Imposible buscar historial de vehículos (placas inconsistentes)
- ❌ Datos inútiles para análisis
- ❌ No se puede detectar reincidencias

**Formato correcto en Guatemala**:
- **Formato**: `L###LLL` (1 letra, 3 números, 3 letras)
- **Ejemplos válidos**: P512KJF, C589SJY, O789ASD
- **Excepción**: Placas extranjeras (sin validación)

**Solución requerida**:
- Componente `PlacaInput` con validación regex
- Checkbox "Extranjero" para desactivar validación
- Feedback visual inmediato (✅ válida / ❌ inválida)

---

### Problema 4: Estructura del Formulario Caótica (Issue #8)

**Situación actual**:
- Los campos del vehículo están desordenados sin lógica
- Mezcla datos del vehículo, piloto, carga, contenedor, bus, sanción sin secciones claras
- Campos condicionales (ej: datos de contenedor) aparecen siempre, ocupando espacio

**Impacto**:
- ❌ Brigadistas confundidos: "¿dónde pongo el NIT?"
- ❌ Formularios largos e intimidantes
- ❌ Errores de captura (datos en campos incorrectos)
- ❌ Tiempo excesivo para reportar

**Solución requerida**:
Reorganizar en **7 secciones colapsables**:
1. **Preliminares**: Datos básicos (tipo, color, marca, placa, estado piloto)
2. **Tarjeta Circulación**: TC, NIT, propietario
3. **Licencia**: Datos del piloto (nombre, tipo lic, vencimiento, etc.)
4. **Carga**: Solo visible si "cargado = Sí"
5. **Contenedor/Remolque**: Solo visible si "contenedor = Sí"
6. **Bus Extraurbano**: Solo visible si "bus = Sí"
7. **Sanción**: Solo visible si "sanción = Sí"

---

### Problema 5: Datos No Normalizados (Issue #11)

**Situación actual**:
- Cada incidente guarda datos completos del vehículo/piloto en `vehiculo_incidente`
- Si la placa P512KJF aparece en 5 incidentes, hay 5 registros duplicados con los mismos datos
- No hay tabla maestra de vehículos ni pilotos

**Ejemplo del problema**:
```
Incidente 1: placa=P512KJF, marca=Toyota, color=Rojo, piloto=Juan Pérez
Incidente 2: placa=P512KJF, marca=Toyota, color=Rojo, piloto=Juan Pérez  ← DUPLICADO
Incidente 3: placa=P512KJF, marca=Toyoya, color=rojo, piloto=Juan Perez  ← INCONSISTENTE
```

**Impacto**:
- ❌ **Imposible hacer análisis**: No se puede contar cuántos incidentes tiene P512KJF porque hay inconsistencias
- ❌ **Desperdicio de almacenamiento**: Datos duplicados miles de veces
- ❌ **No hay historial**: No existe el concepto de "vehículo" o "piloto" como entidad
- ❌ **Sistema de inteligencia inviable**: Sin normalización, no se pueden detectar reincidencias

**Solución requerida**:
Crear **8 tablas maestras**:
1. `vehiculo` - Un registro por placa única
2. `tarjeta_circulacion` - Datos de TC vinculados a vehículo
3. `piloto` - Un registro por licencia única
4. `contenedor` - Datos de contenedores vinculados a vehículo
5. `bus` - Datos de buses vinculados a vehículo
6. `sancion` - Sanciones vinculadas a incidente + vehículo
7. `grua` - Grúas como entidades reutilizables
8. `aseguradora` - Aseguradoras como entidades reutilizables

**Tablas de unión**:
- `incidente_vehiculo` - Relaciona incidentes con vehículos (many-to-many)
- `incidente_grua` - Relaciona incidentes con grúas
- `incidente_aseguradora` - Relaciona incidentes con aseguradoras

---

### Problema 6: Sin Sistema de Inteligencia

**Situación actual**:
- Cuando un brigadista ingresa una placa, **no sabe** si ese vehículo tiene historial
- No hay alertas de reincidencias
- No hay dashboard para operaciones

**Escenario real**:
1. Brigadista encuentra accidente con placa P512KJF
2. Reporta el incidente normalmente
3. **NO SABE** que P512KJF tiene 8 incidentes previos en los últimos 3 meses
4. **NO SABE** que el piloto tiene 3 sanciones por conducir ebrio
5. Oportunidad perdida de aplicar sanción más severa o retener vehículo

**Impacto**:
- ❌ Reincidentes no son detectados
- ❌ No se pueden aplicar políticas de sanción progresiva
- ❌ Gerencia no tiene visibilidad de "puntos calientes" (vehículos/pilotos problemáticos)
- ❌ Datos valiosos no se explotan

**Solución requerida**:
1. **Alertas en tiempo real**: Al ingresar placa, mostrar banner si tiene historial
2. **Dashboard de inteligencia**: Top 10 reincidentes, patrones, zonas calientes
3. **Endpoints de consulta**: `/api/intelligence/vehiculo/:placa`, `/api/intelligence/piloto/:licencia`

---

## 🎯 OBJETIVOS DE LA IMPLEMENTACIÓN

### Objetivos Funcionales
1. ✅ Eliminar errores de captura de datos (GPS, ruta, placas)
2. ✅ Mejorar UX del formulario (secciones, condicionales, validaciones)
3. ✅ Normalizar datos para habilitar análisis
4. ✅ Detectar reincidencias en tiempo real
5. ✅ Proveer inteligencia operativa a gerencia

### Objetivos No Funcionales
1. ✅ Mantener compatibilidad con datos existentes (migración)
2. ✅ Performance: Alertas en <500ms
3. ✅ UX: Formulario completable en <3 minutos
4. ✅ Escalabilidad: Soportar 10,000+ vehículos en historial

---

## 📐 ESPECIFICACIONES CONFIRMADAS

### Formato de Placa (Guatemala)
- **Patrón**: `L###LLL` (1 letra, 3 números, 3 letras)
- **Regex**: `/^[A-Z]\d{3}[A-Z]{3}$/`
- **Ejemplos válidos**: P512KJF, C589SJY, O789ASD
- **Ejemplos inválidos**: ABC123, 123ABC, P-512-KJF

### Tipos de Licencia (Enum)
```typescript
type TipoLicencia = 'A' | 'B' | 'C' | 'M' | 'E';
```
- **A**: Motocicletas
- **B**: Vehículos livianos
- **C**: Vehículos pesados
- **M**: Maquinaria
- **E**: Especial

### Artículos de Sanción (Ejemplos)
```sql
INSERT INTO articulo_sancion (numero, descripcion) VALUES
('Art. 145', 'Conducir sin licencia'),
('Art. 146', 'Exceso de velocidad'),
('Art. 147', 'Conducir en estado de ebriedad');
```
*Nota: Se agregarán más artículos posteriormente*

---

## 🚀 PLAN DE IMPLEMENTACIÓN

### FASE 1: Correcciones Críticas del Formulario (2-3 días)

#### 1.1 Draft y GPS (Issues #1-2)
**Archivos a modificar**:
- `mobile/src/screens/brigada/IncidenteScreen.tsx`

**Cambios**:
```typescript
// ANTES
const draftData = { ...formData, coordenadas };
const { loadDraft } = useDraftSave('draft_incidente', draftData);

// Mostrar diálogo de confirmación
Alert.alert('¿Recuperar borrador?', ...);

// DESPUÉS
const draftData = { ...formData }; // SIN coordenadas
const { loadDraft } = useDraftSave('draft_incidente', draftData);

// Auto-restaurar sin diálogo
useEffect(() => {
  const draft = await loadDraft();
  if (draft) reset(draft); // Auto-restore
}, []);
```

#### 1.2 Ruta Auto-asignada (Issue #3)
**Archivos a modificar**:
- `mobile/src/screens/brigada/IncidenteScreen.tsx`

**Cambios**:
```typescript
// ANTES
<RutaSelector value={rutaId} onChange={setRutaId} />

// DESPUÉS
// Eliminar RutaSelector completamente
const rutaId = asignacion?.ruta_asignada_id; // Auto-asignado
```

#### 1.3 Validación de Placas (Issue #6)
**Archivos a crear**:
- `mobile/src/components/PlacaInput.tsx`

**Implementación**:
```typescript
const PLACA_REGEX = /^[A-Z]\d{3}[A-Z]{3}$/;

export const PlacaInput = ({ value, onChange, esExtranjero, onExtranjeroChange }) => {
  const isValid = esExtranjero || PLACA_REGEX.test(value);
  
  return (
    <View>
      <TextInput 
        value={value} 
        onChangeText={onChange}
        autoCapitalize="characters"
        maxLength={7}
        style={isValid ? styles.valid : styles.invalid}
      />
      <Checkbox 
        label="Extranjero" 
        value={esExtranjero} 
        onChange={onExtranjeroChange} 
      />
      {!isValid && <Text style={styles.error}>Formato: L###LLL (Ej: P512KJF)</Text>}
    </View>
  );
};
```

#### 1.4 Reorganización de VehiculoForm (Issue #8)
**Archivos a modificar**:
- `mobile/src/components/VehiculoForm.tsx`

**Estructura nueva**:
```tsx
<Accordion>
  <AccordionItem title="Preliminares" defaultExpanded>
    <TipoVehiculoSelect />
    <TextInput label="Color" />
    <MarcaSelect />
    <PlacaInput />
    <EstadoPilotoSelect />
    <NumericInput label="Personas Asistidas" />
  </AccordionItem>
  
  <AccordionItem title="Tarjeta Circulación">
    <NumericInput label="No. TC" />
    <NumericInput label="NIT" />
    <TextInput label="Dirección Propietario" />
    <TextInput label="Nombre Propietario" />
    <NumericInput label="Modelo (Año)" />
  </AccordionItem>
  
  <AccordionItem title="Licencia">
    <TextInput label="Nombre Piloto" />
    <TipoLicenciaSelect options={['A','B','C','M','E']} />
    <NumericInput label="No. Licencia" />
    <DatePicker label="Vencimiento" />
    <NumericInput label="Antigüedad (años)" />
    <DatePicker label="Fecha Nacimiento" />
    <TextInput label="Etnia" />
  </AccordionItem>
  
  <AccordionItem title="Carga">
    <Switch label="¿Cargado?" value={cargado} />
    {cargado && <TipoCargaSelect />}
  </AccordionItem>
  
  {/* Similar para Contenedor, Bus, Sanción */}
</Accordion>
```

#### 1.5 Otras Correcciones Menores
- **Issue #4**: Mover `ObstruccionManager` a tab "General"
- **Issue #5**: Implementar `DepartamentoSelector` + `MunicipioSelector` cascading
- **Issue #9-10**: Reorganizar `GruaForm` y `AjustadorForm` con mismo patrón
- **Issue #12**: Cambiar input de hora a `HourSelect` (00:00-23:45 en intervalos de 15min)
- **Issue #13**: Eliminar "Asistencia Vehicular" de `OtraSituacionScreen`
- **Issue #14**: Agregar `paddingBottom: 80` a `BitacoraScreen`

---

### FASE 2: Normalización de Base de Datos (3-4 días)

#### 2.1 Crear Migración 024
**Archivo**: `migrations/024_normalize_incident_data.sql`

**Tablas a crear**:

```sql
-- 1. VEHICULO (Master)
CREATE TABLE vehiculo (
    id SERIAL PRIMARY KEY,
    placa VARCHAR(7) UNIQUE NOT NULL,
    es_extranjero BOOLEAN DEFAULT FALSE,
    tipo_vehiculo_id INTEGER REFERENCES tipo_vehiculo(id),
    color VARCHAR(100),
    marca_id INTEGER REFERENCES marca(id),
    cargado BOOLEAN DEFAULT FALSE,
    tipo_carga VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. TARJETA_CIRCULACION
CREATE TABLE tarjeta_circulacion (
    id SERIAL PRIMARY KEY,
    vehiculo_id INTEGER REFERENCES vehiculo(id) ON DELETE CASCADE,
    numero BIGINT NOT NULL,
    nit BIGINT,
    direccion_propietario TEXT,
    nombre_propietario VARCHAR(255),
    modelo INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. PILOTO (Master)
CREATE TABLE piloto (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    licencia_tipo VARCHAR(1) CHECK (licencia_tipo IN ('A','B','C','M','E')),
    licencia_numero BIGINT UNIQUE NOT NULL,
    licencia_vencimiento DATE,
    licencia_antiguedad INTEGER,
    fecha_nacimiento DATE,
    etnia VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4-8. CONTENEDOR, BUS, SANCION, GRUA, ASEGURADORA
-- (Ver implementation_plan.md para SQL completo)

-- Tablas de Unión
CREATE TABLE incidente_vehiculo (
    id SERIAL PRIMARY KEY,
    incidente_id INTEGER REFERENCES incidente(id) ON DELETE CASCADE,
    vehiculo_id INTEGER REFERENCES vehiculo(id),
    piloto_id INTEGER REFERENCES piloto(id),
    estado_piloto VARCHAR(50),
    personas_asistidas INTEGER DEFAULT 0
);

-- Índices
CREATE INDEX idx_vehiculo_placa ON vehiculo(placa);
CREATE INDEX idx_piloto_licencia ON piloto(licencia_numero);
```

#### 2.2 Migrar Datos Existentes
**Script de migración**:
```sql
-- Migrar vehículos de vehiculo_incidente a vehiculo
INSERT INTO vehiculo (placa, tipo_vehiculo_id, color, marca_id)
SELECT DISTINCT placa, tipo_vehiculo_id, color, marca_id
FROM vehiculo_incidente
WHERE placa IS NOT NULL
ON CONFLICT (placa) DO NOTHING;

-- Migrar pilotos
INSERT INTO piloto (nombre, licencia_numero, licencia_tipo)
SELECT DISTINCT nombre_piloto, licencia_numero, licencia_tipo
FROM vehiculo_incidente
WHERE licencia_numero IS NOT NULL
ON CONFLICT (licencia_numero) DO NOTHING;

-- Crear relaciones en incidente_vehiculo
INSERT INTO incidente_vehiculo (incidente_id, vehiculo_id, piloto_id, estado_piloto)
SELECT 
    vi.incidente_id,
    v.id,
    p.id,
    vi.estado_piloto
FROM vehiculo_incidente vi
LEFT JOIN vehiculo v ON vi.placa = v.placa
LEFT JOIN piloto p ON vi.licencia_numero = p.licencia_numero;
```

#### 2.3 Crear Modelos Backend
**Archivos a crear**:
- `backend/src/models/vehiculo.model.ts`
- `backend/src/models/piloto.model.ts`
- `backend/src/models/grua.model.ts`
- `backend/src/models/aseguradora.model.ts`

**Ejemplo VehiculoModel**:
```typescript
export const VehiculoModel = {
  async getOrCreate(data: { placa: string; ... }): Promise<Vehiculo> {
    const existing = await db.oneOrNone('SELECT * FROM vehiculo WHERE placa = $1', [data.placa]);
    if (existing) return existing;
    
    return db.one('INSERT INTO vehiculo (...) VALUES (...) RETURNING *', [...]);
  },
  
  async getHistorial(placa: string): Promise<Incidente[]> {
    return db.any(`
      SELECT i.* 
      FROM incidente i
      JOIN incidente_vehiculo iv ON i.id = iv.incidente_id
      JOIN vehiculo v ON iv.vehiculo_id = v.id
      WHERE v.placa = $1
      ORDER BY i.created_at DESC
    `, [placa]);
  }
};
```

---

### FASE 3: Sistema de Inteligencia (3-4 días)

#### 3.1 Vistas Materializadas
**Archivo**: `migrations/025_intelligence_views.sql`

```sql
CREATE MATERIALIZED VIEW mv_vehiculo_historial AS
SELECT 
    v.id,
    v.placa,
    COUNT(iv.id) as total_incidentes,
    COUNT(s.id) as total_sanciones,
    MAX(i.created_at) as ultimo_incidente,
    json_agg(json_build_object(
        'fecha', i.created_at,
        'tipo', th.nombre,
        'km', i.km,
        'ruta', r.codigo
    ) ORDER BY i.created_at DESC) as incidentes
FROM vehiculo v
LEFT JOIN incidente_vehiculo iv ON v.id = iv.vehiculo_id
LEFT JOIN incidente i ON iv.incidente_id = i.id
LEFT JOIN sancion s ON s.vehiculo_id = v.id
LEFT JOIN tipo_hecho th ON i.tipo_hecho_id = th.id
LEFT JOIN ruta r ON i.ruta_id = r.id
GROUP BY v.id;

-- Refresh automático cada hora
CREATE OR REPLACE FUNCTION refresh_intelligence_views()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_vehiculo_historial;
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_piloto_historial;
END;
$$ LANGUAGE plpgsql;
```

#### 3.2 Endpoints de Inteligencia
**Archivo**: `backend/src/controllers/intelligence.controller.ts`

```typescript
export async function getVehiculoHistorial(req: Request, res: Response) {
  const { placa } = req.params;
  
  const historial = await db.oneOrNone(`
    SELECT * FROM mv_vehiculo_historial WHERE placa = $1
  `, [placa]);
  
  if (!historial) {
    return res.json({ placa, total_incidentes: 0, incidentes: [] });
  }
  
  // Calcular nivel de alerta
  const nivel = historial.total_incidentes >= 5 ? 'ALTO' :
                historial.total_incidentes >= 2 ? 'MEDIO' : 'BAJO';
  
  return res.json({ ...historial, nivel_alerta: nivel });
}

export async function getTopReincidentes(req: Request, res: Response) {
  const vehiculos = await db.any(`
    SELECT * FROM mv_vehiculo_historial 
    WHERE total_incidentes > 0
    ORDER BY total_incidentes DESC 
    LIMIT 10
  `);
  
  return res.json({ vehiculos });
}
```

#### 3.3 Alertas en Tiempo Real (Mobile)
**Modificar**: `mobile/src/components/PlacaInput.tsx`

```typescript
const PlacaInput = ({ value, onChange }) => {
  const [historial, setHistorial] = useState(null);
  const [loading, setLoading] = useState(false);
  
  useEffect(() => {
    if (PLACA_REGEX.test(value)) {
      setLoading(true);
      api.get(`/intelligence/vehiculo/${value}`)
        .then(res => setHistorial(res.data))
        .finally(() => setLoading(false));
    }
  }, [value]);
  
  return (
    <View>
      <TextInput value={value} onChange={onChange} />
      
      {loading && <ActivityIndicator />}
      
      {historial?.total_incidentes > 0 && (
        <Alert severity={historial.nivel_alerta}>
          ⚠️ Este vehículo tiene {historial.total_incidentes} incidentes previos
          <br />
          Último: {formatDate(historial.ultimo_incidente)}
          <Button onPress={() => navigation.navigate('VehiculoHistorial', { placa: value })}>
            Ver Historial Completo
          </Button>
        </Alert>
      )}
    </View>
  );
};
```

#### 3.4 Dashboard Web
**Archivo**: `web/src/pages/IntelligenceDashboard.tsx`

**Componentes**:
1. **Top 10 Vehículos Reincidentes** (Bar Chart)
2. **Top 10 Pilotos Reincidentes** (Bar Chart)
3. **Mapa de Calor** (Incidentes por ruta)
4. **Filtros**: Fecha, Ruta, Tipo de Hecho
5. **Export a Excel**

---

## 📊 MÉTRICAS DE ÉXITO

### Calidad de Datos
- ✅ 100% de placas válidas (formato correcto o marcadas como extranjeras)
- ✅ 0% de incidentes con ruta ≠ GPS
- ✅ 0% de borradores con GPS obsoleto

### Experiencia de Usuario
- ✅ Tiempo promedio de reporte: <3 minutos (vs 5-7 actual)
- ✅ Tasa de abandono de formulario: <5%
- ✅ Satisfacción de brigadistas: >4/5

### Capacidad Analítica
- ✅ Detección de reincidencias: 100% (vs 0% actual)
- ✅ Tiempo de consulta de historial: <500ms
- ✅ Dashboard actualizado cada hora

---

## ⚠️ RIESGOS Y MITIGACIONES

### Riesgo 1: Migración de Datos
**Problema**: Datos existentes pueden tener inconsistencias
**Mitigación**: 
- Script de limpieza pre-migración
- Migración en ambiente de prueba primero
- Backup completo antes de migración

### Riesgo 2: Performance
**Problema**: Vistas materializadas pueden ser lentas con muchos datos
**Mitigación**:
- Índices en columnas clave
- Refresh incremental en lugar de completo
- Caché en Redis para consultas frecuentes

### Riesgo 3: Adopción de Usuarios
**Problema**: Brigadistas pueden resistirse al cambio
**Mitigación**:
- Capacitación previa al despliegue
- Documentación con videos
- Soporte dedicado primera semana

---

## 📅 CRONOGRAMA ESTIMADO

| Fase | Duración | Entregables |
|------|----------|-------------|
| **Fase 1** | 2-3 días | Formulario corregido, validaciones, UX mejorada |
| **Fase 2** | 3-4 días | BD normalizada, modelos backend, migración exitosa |
| **Fase 3** | 3-4 días | Alertas funcionando, dashboard operativo |
| **Testing** | 2 días | Pruebas E2E, corrección de bugs |
| **Despliegue** | 1 día | Deploy a producción, capacitación |
| **TOTAL** | **11-14 días** | Sistema completo operativo |

---

## 🎯 PRÓXIMOS PASOS

1. ✅ **Aprobación de este plan** por el usuario
2. 🚀 **Inicio Fase 1**: Correcciones de formulario
3. 🔄 **Revisión intermedia**: Después de Fase 1
4. 🚀 **Fase 2 y 3**: Normalización e inteligencia
5. ✅ **Entrega final**: Sistema completo con capacitación

---


---

## 🔄 NUEVO FLUJO: Salida de Sede (Propuesta)

### Problemática
- El flujo actual es rígido y no permite ver asignaciones futuras.
- No hay mecanismo para salidas de emergencia anticipadas.
- Falta validación de salida por parte de la tripulación o central.

### Requerimientos
1. **Visibilidad Anticipada**:
   - Permitir a brigadas ver detalles de asignación del día siguiente (ruta, compañeros, unidad).
   - Tarjeta "Próximo Turno" en dashboard si no hay turno activo hoy.

2. **Activación Temprana (Emergencias)**:
   - Botón "Solicitar Salida Anticipada" para activar unidad antes de hora programada.
   - Requiere justificación (log en bitácora).

3. **Validación de Salida**:
   - **Opción A (Consenso)**: Todos los tripulantes deben confirmar salida en su app.
   - **Opción B (Central)**: Solicitud de salida requiere aprobación de COP/Operaciones.

### Tareas de Implementación
- [ ] Backend: Endpoint para `GET /api/turnos/proximo`
- [ ] Backend: Endpoint para `POST /api/asignaciones/:id/solicitar-salida`
- [ ] Mobile: UI de "Próximo Turno"
- [ ] Mobile: Modal de confirmación de salida

---

**Última actualización**: 5 de Diciembre, 2025
