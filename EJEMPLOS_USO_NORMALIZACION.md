# Ejemplos de Uso - Sistema de Normalización de Datos

## Casos de Uso Comunes

---

## 1. Registrar un Incidente con Vehículo y Piloto

```typescript
import { VehiculoModel } from './models/vehiculo.model';
import { PilotoModel } from './models/piloto.model';
import { db } from './config/database';

async function registrarIncidente(data: any) {
  try {
    // 1. Obtener o crear vehículo
    const vehiculo = await VehiculoModel.getOrCreate({
      placa: data.placa,
      es_extranjero: data.es_extranjero || false,
      tipo_vehiculo_id: data.tipo_vehiculo_id,
      color: data.color,
      marca_id: data.marca_id,
      cargado: data.cargado || false,
      tipo_carga: data.tipo_carga
    });

    // 2. Obtener o crear piloto
    const piloto = await PilotoModel.getOrCreate({
      nombre: data.nombre_piloto,
      licencia_tipo: data.licencia_tipo,
      licencia_numero: data.licencia_numero,
      licencia_vencimiento: data.licencia_vencimiento,
      licencia_antiguedad: data.licencia_antiguedad,
      fecha_nacimiento: data.fecha_nacimiento,
      etnia: data.etnia
    });

    // 3. Crear incidente (tabla existente)
    const incidente = await db.one(
      `INSERT INTO incidente (
        tipo_hecho_id, ruta_id, km, coordenadas, created_by
      ) VALUES ($1, $2, $3, $4, $5)
      RETURNING *`,
      [data.tipo_hecho_id, data.ruta_id, data.km, data.coordenadas, data.user_id]
    );

    // 4. Crear relación incidente-vehiculo-piloto
    await db.none(
      `INSERT INTO incidente_vehiculo (
        incidente_id, vehiculo_id, piloto_id, estado_piloto, personas_asistidas
      ) VALUES ($1, $2, $3, $4, $5)`,
      [incidente.id, vehiculo.id, piloto.id, data.estado_piloto, data.personas_asistidas]
    );

    // 5. Si hay tarjeta de circulación, registrarla
    if (data.tarjeta_circulacion) {
      await VehiculoModel.createTarjetaCirculacion({
        vehiculo_id: vehiculo.id,
        numero: data.tc_numero,
        nit: data.tc_nit,
        direccion_propietario: data.tc_direccion,
        nombre_propietario: data.tc_nombre,
        modelo: data.tc_modelo
      });
    }

    // 6. Si es contenedor, registrar datos
    if (data.es_contenedor) {
      await VehiculoModel.createContenedor({
        vehiculo_id: vehiculo.id,
        numero_contenedor: data.contenedor_numero,
        linea_naviera: data.contenedor_linea,
        tipo_contenedor: data.contenedor_tipo
      });
    }

    // 7. Si es bus, registrar datos
    if (data.es_bus) {
      await VehiculoModel.createBus({
        vehiculo_id: vehiculo.id,
        empresa: data.bus_empresa,
        ruta_bus: data.bus_ruta,
        numero_unidad: data.bus_numero,
        capacidad_pasajeros: data.bus_capacidad
      });
    }

    return {
      success: true,
      incidente_id: incidente.id,
      vehiculo_id: vehiculo.id,
      piloto_id: piloto.id
    };

  } catch (error) {
    console.error('Error al registrar incidente:', error);
    throw error;
  }
}
```

---

## 2. Consultar Historial de un Vehículo

```typescript
import { VehiculoModel } from './models/vehiculo.model';

async function consultarHistorialVehiculo(placa: string) {
  // Obtener datos del vehículo
  const vehiculo = await VehiculoModel.findByPlaca(placa);

  if (!vehiculo) {
    return { error: 'Vehículo no encontrado' };
  }

  // Obtener historial completo
  const historial = await VehiculoModel.getHistorial(placa);

  // Obtener última tarjeta de circulación
  const tarjeta = await VehiculoModel.getTarjetaCirculacion(vehiculo.id);

  return {
    vehiculo: {
      placa: vehiculo.placa,
      tipo: vehiculo.tipo_vehiculo_nombre,
      marca: vehiculo.marca_nombre,
      color: vehiculo.color,
      total_incidentes: vehiculo.total_incidentes,
      primer_incidente: vehiculo.primer_incidente,
      ultimo_incidente: vehiculo.ultimo_incidente
    },
    tarjeta_circulacion: tarjeta ? {
      numero: tarjeta.numero,
      propietario: tarjeta.nombre_propietario,
      nit: tarjeta.nit,
      direccion: tarjeta.direccion_propietario
    } : null,
    historial: historial.map(inc => ({
      fecha: inc.created_at,
      tipo_hecho: inc.tipo_hecho_nombre,
      ruta: inc.ruta_codigo,
      km: inc.km,
      piloto: inc.piloto_nombre,
      estado_piloto: inc.estado_piloto,
      reportado_por: inc.reportado_por
    }))
  };
}

// Ejemplo de uso
const resultado = await consultarHistorialVehiculo('P512KJF');
console.log(resultado);
```

---

## 3. Consultar Historial de un Piloto

```typescript
import { PilotoModel } from './models/piloto.model';

async function consultarHistorialPiloto(licenciaNumero: bigint) {
  // Obtener datos del piloto
  const piloto = await PilotoModel.findByLicencia(licenciaNumero);

  if (!piloto) {
    return { error: 'Piloto no encontrado' };
  }

  // Verificar si la licencia está vencida
  const licenciaVencida = await PilotoModel.isLicenciaVencida(licenciaNumero);

  // Obtener historial completo
  const historial = await PilotoModel.getHistorial(licenciaNumero);

  return {
    piloto: {
      nombre: piloto.nombre,
      licencia: {
        numero: piloto.licencia_numero,
        tipo: piloto.licencia_tipo,
        vencimiento: piloto.licencia_vencimiento,
        vencida: licenciaVencida,
        antiguedad_anios: piloto.licencia_antiguedad
      },
      estadisticas: {
        total_incidentes: piloto.total_incidentes,
        total_sanciones: piloto.total_sanciones,
        primer_incidente: piloto.primer_incidente,
        ultimo_incidente: piloto.ultimo_incidente
      }
    },
    historial: historial.map(inc => ({
      fecha: inc.created_at,
      tipo_hecho: inc.tipo_hecho_nombre,
      ruta: inc.ruta_codigo,
      km: inc.km,
      vehiculo: {
        placa: inc.vehiculo_placa,
        tipo: inc.vehiculo_tipo,
        color: inc.vehiculo_color
      },
      estado_piloto: inc.estado_piloto,
      reportado_por: inc.reportado_por
    }))
  };
}

// Ejemplo de uso
const resultado = await consultarHistorialPiloto(123456789n);
console.log(resultado);
```

---

## 4. Registrar Servicio de Grúa

```typescript
import { GruaMasterModel } from './models/gruaMaster.model';

async function registrarServicioGrua(incidenteId: number, data: any) {
  // 1. Obtener o crear grúa
  const grua = await GruaMasterModel.getOrCreate({
    nombre: data.nombre_grua,
    placa: data.placa_grua,
    telefono: data.telefono_grua,
    empresa: data.empresa_grua,
    nit: data.nit_grua
  });

  // 2. Registrar servicio
  const servicio = await GruaMasterModel.createIncidenteGrua({
    incidente_id: incidenteId,
    grua_id: grua.id,
    hora_llamada: data.hora_llamada,
    hora_llegada: data.hora_llegada,
    destino: data.destino,
    costo: data.costo
  });

  return {
    success: true,
    grua_id: grua.id,
    servicio_id: servicio.id
  };
}
```

---

## 5. Obtener Top 10 Vehículos Reincidentes

```typescript
import { VehiculoModel } from './models/vehiculo.model';

async function getTopReincidentes(limit: number = 10) {
  const vehiculos = await VehiculoModel.findTopByIncidentes(limit);

  return vehiculos.map((v, index) => ({
    ranking: index + 1,
    placa: v.placa,
    tipo: v.tipo_vehiculo_nombre,
    marca: v.marca_nombre,
    color: v.color,
    total_incidentes: v.total_incidentes,
    primer_incidente: v.primer_incidente,
    ultimo_incidente: v.ultimo_incidente,
    dias_desde_ultimo: Math.floor(
      (new Date().getTime() - new Date(v.ultimo_incidente).getTime()) / (1000 * 60 * 60 * 24)
    )
  }));
}

// Ejemplo de uso
const top10 = await getTopReincidentes(10);
console.table(top10);
```

---

## 6. Obtener Top 10 Pilotos Reincidentes

```typescript
import { PilotoModel } from './models/piloto.model';

async function getTopPilotosReincidentes(limit: number = 10) {
  const pilotos = await PilotoModel.findTopByIncidentes(limit);

  return pilotos.map((p, index) => ({
    ranking: index + 1,
    nombre: p.nombre,
    licencia: p.licencia_numero,
    tipo_licencia: p.licencia_tipo,
    total_incidentes: p.total_incidentes,
    total_sanciones: p.total_sanciones,
    primer_incidente: p.primer_incidente,
    ultimo_incidente: p.ultimo_incidente
  }));
}
```

---

## 7. Alertas en Tiempo Real (Mobile)

```typescript
// Componente PlacaInput con alertas
import { useState, useEffect } from 'react';
import { VehiculoModel } from '../models/vehiculo.model';

function PlacaInputConAlerta({ value, onChange }) {
  const [historial, setHistorial] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Validar formato de placa
    const PLACA_REGEX = /^[A-Z]\d{3}[A-Z]{3}$/;

    if (PLACA_REGEX.test(value)) {
      setLoading(true);

      // Consultar historial
      VehiculoModel.getHistorial(value)
        .then(data => {
          if (data.length > 0) {
            setHistorial({
              total_incidentes: data.length,
              ultimo_incidente: data[0].created_at,
              tipo_ultimo: data[0].tipo_hecho_nombre
            });
          }
        })
        .finally(() => setLoading(false));
    }
  }, [value]);

  const getNivelAlerta = () => {
    if (!historial) return 'NINGUNO';
    if (historial.total_incidentes >= 5) return 'ALTO';
    if (historial.total_incidentes >= 2) return 'MEDIO';
    return 'BAJO';
  };

  return (
    <View>
      <TextInput
        value={value}
        onChange={onChange}
        placeholder="P512KJF"
      />

      {loading && <ActivityIndicator />}

      {historial && (
        <Alert severity={getNivelAlerta()}>
          ⚠️ VEHÍCULO REINCIDENTE
          <br />
          Total de incidentes: {historial.total_incidentes}
          <br />
          Último: {formatDate(historial.ultimo_incidente)} - {historial.tipo_ultimo}
          <br />
          <Button onPress={() => navigate('VehiculoHistorial', { placa: value })}>
            Ver Historial Completo
          </Button>
        </Alert>
      )}
    </View>
  );
}
```

---

## 8. Validación de Licencias Próximas a Vencer

```typescript
import { PilotoModel } from './models/piloto.model';

async function verificarLicenciasPorVencer() {
  // Obtener licencias que vencen en los próximos 30 días
  const licencias = await PilotoModel.findLicenciasProximasVencer(30);

  console.log(`🚨 ${licencias.length} licencias próximas a vencer:`);

  licencias.forEach(piloto => {
    const diasRestantes = Math.floor(
      (new Date(piloto.licencia_vencimiento).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)
    );

    console.log(`- ${piloto.nombre} (Lic: ${piloto.licencia_numero}) - Vence en ${diasRestantes} días`);
  });

  return licencias;
}
```

---

## 9. Endpoint de API: Consultar Historial de Vehículo

```typescript
// backend/src/controllers/intelligence.controller.ts

import { Request, Response } from 'express';
import { VehiculoModel } from '../models/vehiculo.model';

export async function getVehiculoHistorial(req: Request, res: Response) {
  try {
    const { placa } = req.params;

    // Validar formato de placa
    const PLACA_REGEX = /^[A-Z]\d{3}[A-Z]{3}$/;
    if (!PLACA_REGEX.test(placa) && !req.query.extranjero) {
      return res.status(400).json({
        error: 'Formato de placa inválido. Debe ser L###LLL (ej: P512KJF)'
      });
    }

    // Obtener vehículo
    const vehiculo = await VehiculoModel.findByPlaca(placa);

    if (!vehiculo) {
      return res.json({
        placa,
        encontrado: false,
        total_incidentes: 0,
        incidentes: []
      });
    }

    // Obtener historial
    const historial = await VehiculoModel.getHistorial(placa);

    // Calcular nivel de alerta
    const nivel_alerta =
      vehiculo.total_incidentes >= 5 ? 'ALTO' :
      vehiculo.total_incidentes >= 2 ? 'MEDIO' : 'BAJO';

    return res.json({
      placa,
      encontrado: true,
      vehiculo: {
        tipo: vehiculo.tipo_vehiculo_nombre,
        marca: vehiculo.marca_nombre,
        color: vehiculo.color,
        es_extranjero: vehiculo.es_extranjero
      },
      estadisticas: {
        total_incidentes: vehiculo.total_incidentes,
        primer_incidente: vehiculo.primer_incidente,
        ultimo_incidente: vehiculo.ultimo_incidente,
        nivel_alerta
      },
      incidentes: historial.map(inc => ({
        fecha: inc.created_at,
        tipo_hecho: inc.tipo_hecho_nombre,
        ruta: `${inc.ruta_codigo} - ${inc.ruta_nombre}`,
        km: inc.km,
        piloto: inc.piloto_nombre,
        estado_piloto: inc.estado_piloto,
        reportado_por: inc.reportado_por
      }))
    });

  } catch (error) {
    console.error('Error al obtener historial:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// Ruta
// router.get('/intelligence/vehiculo/:placa', getVehiculoHistorial);
```

---

## 10. Actualizar Datos de un Vehículo

```typescript
import { VehiculoModel } from './models/vehiculo.model';

async function actualizarDatosVehiculo(placa: string, nuevosDatos: any) {
  const vehiculo = await VehiculoModel.update(placa, {
    color: nuevosDatos.color,
    tipo_vehiculo_id: nuevosDatos.tipo_vehiculo_id,
    marca_id: nuevosDatos.marca_id
  });

  if (!vehiculo) {
    return { error: 'Vehículo no encontrado' };
  }

  return {
    success: true,
    vehiculo
  };
}

// Ejemplo de uso
const resultado = await actualizarDatosVehiculo('P512KJF', {
  color: 'Azul',
  tipo_vehiculo_id: 5,
  marca_id: 12
});
```

---

## 11. Búsqueda de Grúas Activas

```typescript
import { GruaMasterModel } from './models/gruaMaster.model';

async function listarGruasDisponibles() {
  const gruas = await GruaMasterModel.findAllActive();

  return gruas.map(g => ({
    id: g.id,
    nombre: g.nombre,
    empresa: g.empresa,
    placa: g.placa,
    telefono: g.telefono,
    total_servicios: g.total_servicios,
    ultima_vez_usado: g.ultima_vez_usado
  }));
}
```

---

## 12. Búsqueda de Aseguradoras Activas

```typescript
import { AseguradoraModel } from './models/aseguradora.model';

async function listarAseguradorasActivas() {
  const aseguradoras = await AseguradoraModel.findAllActive();

  return aseguradoras.map(a => ({
    id: a.id,
    nombre: a.nombre,
    codigo: a.codigo,
    telefono: a.telefono,
    email: a.email,
    total_incidentes: a.total_incidentes
  }));
}
```

---

## Notas Importantes

1. **getOrCreate() es idempotente**: Puedes llamarlo múltiples veces con los mismos datos sin crear duplicados

2. **Triggers automáticos**: No necesitas actualizar manualmente los contadores (total_incidentes, total_sanciones, etc.)

3. **Validaciones**:
   - Placas: formato L###LLL o marcar como extranjero
   - Licencias: tipos A, B, C, M, E
   - Relaciones: validadas por foreign keys

4. **Performance**:
   - Usar índices para búsquedas por placa, licencia, etc.
   - Los JOINs están optimizados con índices
   - Las consultas de historial incluyen LIMIT si es necesario

5. **Transacciones**: Usa transacciones para operaciones que involucran múltiples tablas

```typescript
// Ejemplo con transacción
await db.tx(async t => {
  const vehiculo = await VehiculoModel.getOrCreate(data);
  const piloto = await PilotoModel.getOrCreate(data);
  const incidente = await t.one('INSERT INTO incidente...');
  await t.none('INSERT INTO incidente_vehiculo...');
});
```
