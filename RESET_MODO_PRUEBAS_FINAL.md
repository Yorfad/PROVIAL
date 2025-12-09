# 🔄 Modo de Pruebas - Reset Funcional

**Fecha**: 7 de Diciembre, 2025
**Estado**: ✅ Completado y Funcional

---

## 🎯 Problema Resuelto

**Problema original**:
Al resetear en modo de pruebas, solo se limpiaba AsyncStorage local pero la salida seguía activa en el backend. El usuario quedaba "atrapado" con salida activa y no podía iniciar una nueva salida para seguir probando.

**Solución implementada**:
Ahora el reset **FINALIZA** la salida activa en el backend (no la elimina), elimina ingresos activos y elimina situaciones del día. Esto devuelve el estado a:
- ✅ Brigada asignado a unidad (permanece)
- ✅ Sin salida activa (finalizada correctamente)
- ✅ Sin ingresos
- ✅ Sin situaciones del día
- ✅ **Listo para iniciar nueva salida**

---

## 🔧 Cómo Funciona

### Backend - Finalizar Salida

**Endpoint**: `DELETE /api/test-mode/salida`

**Lo que hace**:
```sql
UPDATE salidas
SET fecha_hora_finalizacion = NOW(),
    km_finalizacion = km_salida,
    combustible_finalizacion = combustible_salida,
    combustible_finalizacion_fraccion = combustible_salida_fraccion,
    observaciones_finalizacion = 'Finalizado automáticamente por Modo de Pruebas'
WHERE id = [salida_activa_id]
```

**Ventajas**:
- ✅ La salida se registra en el historial (no se pierde)
- ✅ El usuario queda sin salida activa
- ✅ Puede iniciar una nueva salida inmediatamente
- ✅ Los kilómetros y combustible quedan registrados

### Resetear Ingresos

**Endpoint**: `DELETE /api/test-mode/ingresos`

**Lo que hace**:
```sql
DELETE FROM ingresos_sede
WHERE unidad_id = [unidad_usuario]
  AND fecha_hora_salida IS NULL
```

- Elimina ingresos sin salida (activos)
- El usuario vuelve a estar "en calle"

### Resetear Situaciones

**Endpoint**: `DELETE /api/test-mode/situaciones`

**Lo que hace**:
```sql
DELETE FROM situaciones
WHERE unidad_id = [unidad_usuario]
  AND DATE(created_at) = CURRENT_DATE
```

- Elimina solo situaciones de HOY
- Situaciones de días anteriores permanecen

### Resetear TODO

**Endpoint**: `DELETE /api/test-mode/all`

**Lo que hace**:
- Ejecuta los 3 resets anteriores en secuencia
- Devuelve resultado completo

---

## 📱 Flujo de Usuario

### 1. Hacer Pruebas
```
1. Iniciar salida de unidad
   → Salida guardada en backend
2. Reportar situaciones
   → Situaciones guardadas en backend
3. Ingresar a sede (opcional)
   → Ingreso guardado en backend
```

### 2. Resetear Estado
```
1. Ir a 🧪 Modo de Pruebas
2. Presionar "💣 Resetear TODO"
3. Leer advertencia
4. Confirmar "Resetear"
5. Ver mensaje: "Estado reseteado correctamente"
```

### 3. Resultado
```
Estado después del reset:
✅ Salida finalizada (en historial)
✅ Sin salida activa
✅ Ingresos eliminados
✅ Situaciones del día eliminadas
✅ Asignación de unidad intacta
```

### 4. Continuar Probando
```
1. Volver a pantalla principal
2. Presionar "Iniciar Salida"
3. Ingresar km y combustible
4. Nueva salida activa ✅
5. Listo para seguir probando
```

---

## 🎬 Ejemplo Completo

### Demo Típica

```
[Inicio]
Estado: Brigada asignado a P-100, sin salida

[Paso 1: Activar Modo de Pruebas]
- Ir a Configuración → Modo de Pruebas
- Activar switch

[Paso 2: Iniciar Salida]
- Iniciar Salida
- km: 50000
- Combustible: ¾
- Salida activa ✅

[Paso 3: Hacer Pruebas]
- Reportar 3 situaciones
- Ingresar a sede
- Salir de sede

[Paso 4: Terminar Demo]
- Ir a Modo de Pruebas
- Resetear TODO
- Confirmar

[Resultado]
Estado: Brigada asignado a P-100, sin salida
(Igual que al inicio, listo para nueva demo)
```

---

## 📊 Comparación Antes vs Ahora

### ❌ Antes (No Funcionaba)

```
Resetear TODO:
- Limpia AsyncStorage local ✅
- Salida sigue activa en backend ❌
- No puedes iniciar nueva salida ❌
- Estado inconsistente ❌

Usuario reporta: "sigo con la unidad en salida"
```

### ✅ Ahora (Funcional)

```
Resetear TODO:
- Finaliza salida en backend ✅
- Elimina ingresos activos ✅
- Elimina situaciones de hoy ✅
- Limpia AsyncStorage local ✅
- Puedes iniciar nueva salida ✅
- Estado consistente ✅

Usuario puede: "iniciar salida de nuevo"
```

---

## 🔍 Verificación

### Para Verificar que Funciona

1. **Antes del reset**:
   ```sql
   SELECT * FROM salidas
   WHERE unidad_id = [tu_unidad]
   AND fecha_hora_finalizacion IS NULL;
   -- Debe mostrar 1 salida activa
   ```

2. **Ejecutar reset desde la app**:
   - Modo de Pruebas → Resetear TODO

3. **Después del reset**:
   ```sql
   SELECT * FROM salidas
   WHERE unidad_id = [tu_unidad]
   AND fecha_hora_finalizacion IS NULL;
   -- Debe mostrar 0 salidas activas

   SELECT * FROM salidas
   WHERE unidad_id = [tu_unidad]
   ORDER BY id DESC LIMIT 1;
   -- Debe mostrar la salida finalizada con observaciones "Modo de Pruebas"
   ```

4. **Intentar iniciar nueva salida**:
   - Volver a app → Iniciar Salida
   - ✅ Debe permitirte iniciar nueva salida sin errores

---

## ⚠️ Notas Importantes

### Lo que Resetear TODO hace:
- ✅ Finaliza salida activa (se guarda en historial)
- ✅ Elimina ingresos sin salida
- ✅ Elimina situaciones de HOY
- ✅ Te permite iniciar nueva salida

### Lo que NO hace:
- ❌ NO elimina la asignación de unidad
- ❌ NO elimina situaciones de días anteriores
- ❌ NO afecta otros usuarios
- ❌ NO elimina el historial de salidas

### Buenas Prácticas:
1. Usar solo en modo de pruebas/demos
2. Resetear al terminar cada sesión de pruebas
3. Verificar que puedes iniciar nueva salida después
4. Desactivar modo de pruebas en producción

---

## 🛠️ Archivos Modificados

### Backend
- ✅ `backend/src/controllers/testModeController.ts`
  - Cambiado: DELETE a UPDATE (finalizar salida)
  - Resultado mejorado con mensajes claros

### Frontend
- ✅ `mobile/src/context/TestModeContext.tsx`
  - Simplificado completamente
  - Eliminadas coordenadas manuales (ahora se ingresan por situación)
  - Eliminado "skip validations"
  - Solo mantiene: toggle de modo de prueba + funciones de reset

- ✅ `mobile/src/screens/brigada/ConfiguracionPruebasScreen.tsx`
  - Mensajes actualizados: "Finalizar" en lugar de "Eliminar"
  - Advertencia más clara sobre lo que hace

### Documentación
- ✅ `RESET_MODO_PRUEBAS_FINAL.md` (este archivo)

---

## 📝 Endpoints API

### Resetear Salida
```http
DELETE /api/test-mode/salida
Authorization: Bearer {token}

Response:
{
  "message": "Salida activa finalizada correctamente",
  "finalized": true,
  "salidaId": 123
}
```

### Resetear TODO
```http
DELETE /api/test-mode/all
Authorization: Bearer {token}

Response:
{
  "message": "Estado reseteado correctamente. Puedes iniciar una nueva salida.",
  "results": {
    "salida": "Finalizada ✅",
    "ingresos": "2 eliminados",
    "situaciones": "5 eliminadas"
  }
}
```

---

## ✅ Estado Final

**Backend**: ✅ Funcionando - Finaliza salidas correctamente
**Frontend**: ✅ Completamente simplificado y limpio
**API**: ✅ Puerto corregido (3001)
**Documentación**: ✅ Actualizada
**Probado**: ✅ Listo para usar

**Cambios finales completados**:
- ✅ TestModeContext simplificado (sin coordenadas manuales, sin skip validations)
- ✅ ConfiguracionPruebasScreen limpia (solo toggle + estado + resets)
- ✅ Reset finaliza salida (no la elimina)
- ✅ API apunta al puerto correcto (3001)

**Próximo paso**: Las coordenadas manuales se implementarán por situación cuando el usuario reporte incidentes.

---

**Última actualización**: 7 de Diciembre, 2025
**Implementado por**: Claude Code
**Estado**: ✅ Listo para usar
