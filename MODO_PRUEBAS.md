# 🧪 Modo de Pruebas - App Móvil PROVIAL

## 📋 Resumen

Sistema de herramientas de desarrollo y testing integrado en la app móvil que permite realizar pruebas rápidas, demos y desarrollo sin afectar datos reales del backend.

---

## 🎯 Problema Resuelto

### Antes
- Difícil hacer pruebas rápidas de flujos completos
- No se podía volver atrás después de acciones
- Coordenadas GPS reales hacían difícil simular situaciones
- Necesitabas resetear base de datos para volver a probar

### Ahora
- ✅ **Modo de pruebas** con un solo toggle
- ✅ **Resetear estados** individualmente o todos a la vez
- ✅ **Coordenadas GPS manuales** para simular ubicaciones
- ✅ **Ubicaciones predefinidas** para pruebas rápidas
- ✅ **Skip validaciones** para testing avanzado
- ✅ **Estado local** - No afecta el backend

---

## 🔧 Características

### 1. Toggle Principal

**Ubicación**: Configuración → Modo de Pruebas

**Qué hace:**
- Activa/desactiva todas las herramientas de testing
- Se guarda en AsyncStorage (persiste entre sesiones)
- Muestra indicador visual cuando está activo

**Cómo activar:**
1. Abrir app móvil
2. Ir a Configuración (⚙️)
3. Activar switch "🧪 Modo de Pruebas"
4. Las herramientas aparecerán

### 2. Información de Debug

**Muestra:**
- Usuario actual (nombre, placa, rol)
- Estado de salida (activa/inactiva)
- Estado de ingreso (activo/inactivo)
- Coordenadas actuales (GPS o manuales)

**Uso:**
- Ver rápidamente el estado de la sesión
- Verificar que los estados sean correctos
- Confirmar cambios después de reset

### 3. Coordenadas GPS Manuales

**Para qué sirve:**
- Simular ubicación sin moverte físicamente
- Probar reportes de situaciones en ubicaciones específicas
- Demos con ubicaciones fijas y predecibles

**Cómo usar:**

```
1. Activar "Usar Coordenadas Manuales"
2. Ingresar latitud y longitud
3. Presionar "Guardar"
4. Ahora todas las pantallas usarán esas coordenadas
```

**Ubicaciones Predefinidas:**
- 🏛️ **Ciudad de Guatemala**: 14.6349, -90.5069
- 🛣️ **CA-9 Sur Km 30**: 14.5000, -90.4000
- 🏢 **Centro Histórico**: 14.5844, -90.5312

**Cómo agregar coordenadas personalizadas:**
```typescript
// Ejemplo: Agregar coordenadas de Antigua Guatemala
setLatitud('14.5609');
setLongitud('-90.7345');
handleGuardarCoordenadas();
```

### 4. Herramientas de Reset

🚨 **ADVERTENCIA IMPORTANTE**: Los resets eliminan datos **REALES del backend**, no solo AsyncStorage local. Úsalos solo para pruebas y demos.

#### 🚓 Resetear Salida
**Qué hace:**
- ⚠️ **Elimina la salida activa del BACKEND**
- Elimina registros de combustible asociados
- Limpia AsyncStorage local
- Vuelve al estado "sin salida"
- Permite iniciar una nueva salida limpia

**Cuándo usar:**
- Quieres probar el flujo de iniciar salida nuevamente
- Necesitas volver al estado inicial
- Después de finalizar una prueba o demo

**Efecto:**
```
Backend Antes:
- salida_activa: {id: 123, ...}
- registros_combustible: [...]

Backend Después:
- salida_activa: ELIMINADA ❌
- registros_combustible: ELIMINADOS ❌
- Puedes iniciar nueva salida desde cero
```

#### 🏢 Resetear Ingresos
**Qué hace:**
- ⚠️ **Elimina ingresos a sede activos del BACKEND**
- Elimina todos los ingresos sin salida registrada
- Limpia AsyncStorage local
- Permite reportar situaciones nuevamente

**Cuándo usar:**
- Estás "atrapado" en sede durante pruebas
- Quieres probar salir de sede de nuevo
- Necesitas volver a estar en calle sin ingreso

**Efecto:**
```
Backend Antes:
- ingresos_sede WHERE fecha_hora_salida IS NULL
- No puedes reportar situaciones

Backend Después:
- ingresos_sede: ELIMINADOS ❌
- Puedes reportar situaciones
- Vuelves a estar en calle
```

#### 🚨 Resetear Situaciones
**Qué hace:**
- ⚠️ **Elimina situaciones de HOY del BACKEND**
- Solo elimina situaciones del día actual (CURRENT_DATE)
- Limpia AsyncStorage local
- Situaciones de días anteriores permanecen intactas

**Cuándo usar:**
- Limpiar historial de prueba del día
- Empezar demo con bitácora limpia
- Probar crear situaciones desde cero

**Efecto:**
```
Backend Antes:
- 10 situaciones de hoy (CURRENT_DATE)
- 50 situaciones de días anteriores

Backend Después:
- situaciones de HOY: ELIMINADAS ❌
- situaciones anteriores: INTACTAS ✅
- Bitácora del día vacía
```

#### 💣 Resetear TODO
**Qué hace:**
- ⚠️ **Elimina TODO del BACKEND en una sola operación**
- Elimina: salida activa + ingresos + situaciones de hoy
- Limpia completamente AsyncStorage local
- Vuelve la app al estado completamente inicial
- Es como cerrar sesión y volver a empezar (pero sigues logueado)

**Cuándo usar:**
- Empezar una demo completamente limpia
- Volver al inicio después de muchas pruebas
- Resolver cualquier estado inconsistente

**Efecto:**
```
Backend Antes:
- salida_activa: {id: 123, ...}
- ingresos_sede: [...]
- situaciones (hoy): [...]

Backend Después:
- salida_activa: ELIMINADA ❌
- ingresos_sede: ELIMINADOS ❌
- situaciones (hoy): ELIMINADAS ❌
- Estado 100% limpio - Listo para nueva prueba
```

**🎯 Caso de uso típico:**
```
1. Haces pruebas → Reportas situaciones, ingresas a sede, etc.
2. Terminas las pruebas
3. Presionas "Resetear TODO"
4. Confirmas (diálogo de advertencia)
5. TODO eliminado del backend
6. Listo para empezar una nueva prueba limpia
```

#### 🔄 Refrescar desde Backend
**Qué hace:**
- Sincroniza el estado de la app con el servidor
- Llama a `refreshEstadoBrigada()` del authStore
- Obtiene: salida activa, ingreso activo, asignación, sede

**Cuándo usar:**
- Cuando el estado local no coincide con el backend
- Si la app se desincronizó del servidor
- Para verificar el estado actual después de cambios

**Nota**: Ya no es necesario después de resetear, ya que los resets ahora eliminan datos del backend directamente.

### 5. Opciones Avanzadas

#### Saltar Validaciones
**Qué hace:**
- Permite acciones sin validar estado
- Desactiva checks de seguridad
- PELIGROSO: Solo para testing avanzado

**Cuándo usar:**
- Probar flujos edge case
- Forzar acciones que normalmente fallarían
- Testing de errores

**⚠️ Advertencia:**
Puede causar estados inconsistentes. Usar solo si sabes lo que haces.

---

## 📱 Integración en Código

### Uso del Contexto

```typescript
import { useTestMode } from '../context/TestModeContext';

function MiComponente() {
  const { testModeEnabled, manualCoordinates, useManualCoordinates } = useTestMode();

  // Obtener coordenadas (manuales o GPS)
  const getCoordinates = async () => {
    if (testModeEnabled && useManualCoordinates && manualCoordinates) {
      return manualCoordinates; // Usar coordenadas manuales
    }

    // Obtener GPS real
    const location = await Location.getCurrentPositionAsync();
    return {
      latitud: location.coords.latitude,
      longitud: location.coords.longitude
    };
  };

  // Usar en reporte
  const handleReportarSituacion = async () => {
    const coords = await getCoordinates();

    await api.post('/situaciones', {
      latitud: coords.latitud,
      longitud: coords.longitud,
      // ... otros datos
    });
  };
}
```

### Hook para Coordenadas

```typescript
import { useCoordinates } from '../context/TestModeContext';

function SituacionScreen() {
  const coords = useCoordinates();

  useEffect(() => {
    if (coords) {
      console.log('Ubicación actual:', coords);
      // coords ya son manuales o GPS según configuración
    }
  }, [coords]);
}
```

### Verificar Modo de Pruebas

```typescript
import { useTestMode } from '../context/TestModeContext';

function AlgunComponente() {
  const { testModeEnabled, skipValidations } = useTestMode();

  const handleAccion = () => {
    if (!skipValidations) {
      // Validaciones normales
      if (!datosCompletos) {
        Alert.alert('Error', 'Completa todos los campos');
        return;
      }
    }

    // Continuar con acción...
  };

  return (
    <View>
      {testModeEnabled && (
        <Text style={{color: 'orange'}}>
          🧪 Modo de pruebas activo
        </Text>
      )}
    </View>
  );
}
```

---

## 🎬 Flujos de Uso Comunes

### Flujo 1: Demo Completa de Salida

```
1. Activar Modo de Pruebas
2. Resetear TODO (para empezar limpio)
3. 🔄 REFRESCAR DESDE BACKEND (recupera salida activa si existe)
4. Configurar coordenadas: CA-9 Sur Km 30
5. Activar "Usar Coordenadas Manuales"
6. Iniciar Salida de Unidad
   → km: 50000
   → combustible: 3/4
7. Reportar situación
   → Aparece en Km 30 (coordenadas manuales)
8. Ver Bitácora → Verificar salida + situaciones
9. Finalizar demo:
   → Resetear TODO nuevamente
   → Refrescar desde Backend (sincronizar)
```

### Flujo 2: Probar Ingreso a Sede

```
1. Activar Modo de Pruebas
2. Tener salida activa
3. Ingresar a Sede
4. Intentar reportar situación (debe fallar)
5. Resetear Ingresos
6. Ahora puedes reportar de nuevo
```

### Flujo 3: Probar Diferentes Ubicaciones

```
1. Activar Modo de Pruebas
2. Activar "Usar Coordenadas Manuales"
3. Seleccionar "Ciudad de Guatemala"
4. Reportar situación A
5. Cambiar a "CA-9 Sur Km 30"
6. Reportar situación B
7. Verificar que ambas tienen ubicaciones correctas
```

### Flujo 4: Testing de Edge Cases

```
1. Activar Modo de Pruebas
2. Activar "Saltar Validaciones"
3. Intentar acciones normalmente bloqueadas
4. Observar comportamiento
5. Desactivar "Saltar Validaciones"
6. Resetear estados si es necesario
```

---

## ⚠️ Advertencias y Limitaciones

### 🚨 LO QUE SÍ HACE (IMPORTANTE):
- ✅ **SÍ modifica el backend**: Los resets ELIMINAN datos reales del servidor
- ✅ **SÍ borra datos**: Salidas, ingresos y situaciones se eliminan permanentemente
- ✅ **Acción destructiva**: No se puede deshacer
- ⚠️ **Solo afecta TU usuario**: No elimina datos de otros usuarios

### ❌ NO hace:
- **NO afecta otros usuarios**: Solo elimina TUS datos
- **NO elimina situaciones antiguas**: Solo elimina situaciones de HOY
- **NO bypasea autenticación**: Debes estar logueado
- **NO elimina asignaciones permanentes**: Tu unidad sigue asignada

### ⚠️ Advertencias:
- **Modo de pruebas es obvio**: Hay indicadores visuales (header naranja)
- **Desactivar en producción**: NO usar en operaciones reales
- **Los resets son DESTRUCTIVOS**: Eliminan datos del backend permanentemente
- **Skip validaciones es peligroso**: Puede crear estados inconsistentes
- **Usar solo en ambiente de pruebas**: Nunca en producción con datos reales

### ✅ Buenas Prácticas:
- Siempre desactivar antes de operaciones reales
- Usar "Resetear TODO" antes de demos importantes
- Documentar coordenadas usadas en pruebas
- No commitear cambios hechos con skip validations

---

## 🔧 Configuración en App

### Agregar al Provider Principal

```typescript
// App.tsx
import { TestModeProvider } from './src/context/TestModeContext';

export default function App() {
  return (
    <TestModeProvider>
      <NavigationContainer>
        {/* Tu app */}
      </NavigationContainer>
    </TestModeProvider>
  );
}
```

### Agregar Ruta a Configuración

```typescript
// Navigator
import ConfiguracionPruebasScreen from './screens/brigada/ConfiguracionPruebasScreen';

<Stack.Screen
  name="ConfiguracionPruebas"
  component={ConfiguracionPruebasScreen}
  options={{ title: 'Modo de Pruebas' }}
/>
```

### Botón de Acceso en Menú

```typescript
// En tu menú principal o configuración
<TouchableOpacity onPress={() => navigation.navigate('ConfiguracionPruebas')}>
  <Text>🧪 Modo de Pruebas</Text>
</TouchableOpacity>
```

---

## 📊 Casos de Uso Reales

### Caso 1: Presentación a Clientes

**Escenario:**
Presentar la app a directivos de PROVIAL

**Preparación:**
1. Activar modo de pruebas
2. Resetear TODO
3. Configurar coordenadas en ubicación conocida
4. Preparar datos de prueba (km, combustible)

**Durante presentación:**
1. Mostrar inicio de salida
2. Reportar 2-3 situaciones en diferentes ubicaciones
3. Mostrar ingreso a sede
4. Finalizar jornada

**Después:**
1. Resetear TODO
2. Desactivar modo de pruebas

### Caso 2: Training de Brigadas

**Escenario:**
Enseñar a brigadas a usar la app

**Setup:**
1. Activar modo de pruebas
2. Usar coordenadas manuales
3. Cada brigada practica en su dispositivo

**Ventaja:**
- No generan datos basura en producción
- Pueden resetear y volver a intentar
- Aprenden sin consecuencias

### Caso 3: Testing de Nuevas Features

**Escenario:**
Desarrollador probando nueva funcionalidad

**Uso:**
1. Modo de pruebas + skip validations
2. Probar edge cases
3. Resetear estados entre pruebas
4. Verificar comportamiento

---

## 📚 Archivos Creados

### Context
- `mobile/src/context/TestModeContext.tsx` - Estado global y funciones

### Screens
- `mobile/src/screens/brigada/ConfiguracionPruebasScreen.tsx` - UI completa

### Documentación
- `MODO_PRUEBAS.md` - Este archivo

---

## 🎯 Próximos Pasos (Opcional)

- [ ] Agregar más ubicaciones predefinidas
- [ ] Permitir guardar ubicaciones personalizadas
- [ ] Historial de resets (cuando y qué se reseteó)
- [ ] Exportar/importar configuración de pruebas
- [ ] Mock de respuestas API (sin llamar backend)
- [ ] Grabación de flujos para replay

---

**Última actualización**: 7 de Diciembre, 2025
**Implementado por**: Claude Code
**Estado**: ✅ Completamente funcional
