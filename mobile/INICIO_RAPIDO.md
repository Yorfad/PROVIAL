# 🚀 INICIO RÁPIDO - App Móvil

## ⚠️ Problema Conocido con npm Workspaces

Expo 52 tiene un problema conocido con monorepos npm workspaces y el paquete `metro-cache`.

## ✅ SOLUCIÓN TEMPORAL (Para Demo de Hoy)

### Opción 1: Ejecutar con `npx expo` directamente

```bash
cd mobile
npx expo start --port 8082 --tunnel
```

El flag `--tunnel` usa el servicio Expo tunneling para evitar problemas de red local.

### Opción 2: Ejecutar fuera del monorepo (Recomendado para hoy)

1. **Copiar carpeta mobile a otro lugar:**
   ```bash
   # Desde la raíz del proyecto
   xcopy mobile C:\temp\provial-mobile /E /I
   # o
   cp -r mobile /tmp/provial-mobile
   ```

2. **Entrar a la carpeta copiada:**
   ```bash
   cd C:\temp\provial-mobile
   # o
   cd /tmp/provial-mobile
   ```

3. **Instalar dependencias:**
   ```bash
   npm install
   ```

4. **Configurar IP del backend:**
   - Editar `src/services/api.ts` línea 6
   - Cambiar a tu IP local (obtenida con `ipconfig`)

5. **Iniciar Expo:**
   ```bash
   npx expo start
   ```

6. **Escanear QR con Expo Go en tu teléfono**

---

## 📱 DEMO RÁPIDO (5 minutos)

### 1. Backend y Web (Deben estar corriendo):
```bash
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Web COP
cd web
npm run dev
```

### 2. Copiar y ejecutar mobile standalone:
```bash
# Copiar a carpeta temporal
xcopy mobile C:\temp\provial-mobile /E /I

# Entrar
cd C:\temp\provial-mobile

# Instalar
npm install

# ⚠️ IMPORTANTE: Editar src/services/api.ts con tu IP

# Ejecutar
npx expo start
```

### 3. En tu teléfono:
- Instalar **Expo Go** desde Play Store
- Escanear QR code
- Login: `brigada01` / `password123`
- Tap "REPORTAR INCIDENTE"
- ¡GPS se captura automáticamente!
- Llenar formulario y enviar
- Ver en el mapa del COP ✨

---

## 🔧 Troubleshooting

### Error: "metro-cache FileStore"
→ Estás ejecutando desde dentro del workspace. Usa la solución de copiar mobile a otra carpeta.

### Error: "Cannot connect to Metro"
→ Usa `--tunnel`: `npx expo start --tunnel`

### No aparece QR
→ Presiona `w` para abrir en web browser y ver el QR

### Teléfono no conecta
→ Verifica que teléfono y PC estén en la misma WiFi
→ O usa `--tunnel` para evitar problema de red

---

## 🎯 Después de la demo

Vamos a solucionar el problema del workspace con una de estas opciones:

1. **Downgrade a Expo 51** (más estable con monorepos)
2. **Usar yarn workspaces** en vez de npm workspaces
3. **Usar turborepo** o **nx** para manejar el monorepo
4. **Mantener mobile como proyecto standalone**

Por ahora, para tu presentación de HOY, usa la solución de copiar mobile a C:\\temp\provial-mobile.

---

**¡ÉXITO EN TU DEMO!** 🚀
