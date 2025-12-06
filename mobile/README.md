# 📱 PROVIAL - App Móvil para Brigadas

App móvil React Native + Expo para que las brigadas reporten incidentes en tiempo real.

## 🚀 Inicio Rápido

### 1. Configurar IP del Backend

**IMPORTANTE:** Antes de ejecutar, debes configurar la IP de tu computadora en el archivo de API.

1. Encuentra tu IP local:
   - Windows: `ipconfig` (busca "IPv4 Address")
   - Mac/Linux: `ifconfig` (busca "inet")

2. Edita `mobile/src/services/api.ts` línea 6:
   ```typescript
   const API_URL = 'http://TU_IP_AQUI:3000/api';
   ```
   Ejemplo: `http://192.168.1.100:3000/api`

### 2. Instalar Dependencias

```bash
cd mobile
npm install
```

### 3. Ejecutar la App

```bash
npm start
```

Esto abrirá Expo Dev Tools. Tienes 3 opciones:

#### Opción A: En tu Teléfono (Recomendado para Demo)

1. Instala **Expo Go** desde Play Store o App Store
2. Escanea el QR que aparece en la terminal con:
   - **Android:** La app Expo Go
   - **iOS:** La cámara del iPhone

3. **IMPORTANTE:** Tu teléfono y computadora deben estar en la misma red WiFi

#### Opción B: Emulador Android

```bash
npm run android
```

Requiere Android Studio instalado con un emulador configurado.

#### Opción C: Simulador iOS (Solo Mac)

```bash
npm run ios
```

Requiere Xcode instalado.

## 📋 Funcionalidad

### Login
- Usuario: `brigada01` / `brigada02`
- Password: `password123`

### Pantalla Principal
- Muestra información del usuario
- Muestra asignación de turno (si existe)
- Botón grande "REPORTAR INCIDENTE"

### Reportar Incidente
✅ **Captura GPS automática** - Se obtiene lat/lon del dispositivo
✅ Selección de tipo de incidente
✅ Selección de ruta y kilómetro
✅ Descripción del incidente
✅ Heridos y fallecidos (toggle + cantidad)
✅ Recursos requeridos (Bomberos, PNC, Ambulancia)
✅ Envío al backend

**El incidente aparece INMEDIATAMENTE en el mapa del COP Web** 🗺️

## 🎯 Demo Flow

Para la presentación de hoy:

1. **Inicia Backend:**
   ```bash
   cd backend
   npm run dev
   ```

2. **Inicia Web COP:**
   ```bash
   cd web
   npm run dev
   ```
   Abre http://localhost:5173 y haz login como `cop01`

3. **Inicia Mobile App:**
   ```bash
   cd mobile
   npm start
   ```
   Escanea QR con Expo Go en tu teléfono

4. **Demo:**
   - Login en móvil como `brigada01`
   - Tap "REPORTAR INCIDENTE"
   - GPS se captura automáticamente ✅
   - Llena formulario
   - Envía reporte
   - **Muestra el mapa del COP** → El incidente aparece en tiempo real 🎉

## 🔧 Troubleshooting

### No puedo conectar desde el teléfono

1. Verifica que teléfono y PC estén en la misma red WiFi
2. Verifica la IP en `src/services/api.ts`
3. Desactiva firewall de Windows temporalmente
4. En firewall, permite conexiones entrantes en puerto 3000

### Error de permisos GPS

La app solicitará permisos de ubicación al abrir "Reportar Incidente".
Debes aceptar para que funcione.

### Backend no responde

Verifica que el backend esté corriendo en puerto 3000:
```bash
curl http://localhost:3000/api/health
```

## 📦 Estructura

```
mobile/
├── App.tsx                          # Navegación principal
├── app.json                         # Configuración Expo
├── src/
│   ├── services/
│   │   └── api.ts                   # Cliente API + tipos
│   └── screens/
│       ├── LoginScreen.tsx          # Pantalla login
│       ├── HomeScreen.tsx           # Pantalla principal
│       └── ReportarIncidenteScreen.tsx # Formulario incidente
└── package.json
```

## 🎨 Características UI

- Diseño moderno con colores Provial (azul #1e40af)
- GPS Card mostrando coordenadas capturadas
- Botones de selección tipo "chips"
- Switches para heridos/fallecidos
- Checkboxes para recursos
- Validación de campos requeridos
- Loading states
- Alerts para errores/éxito

## 🔐 Seguridad

- Tokens JWT guardados en AsyncStorage
- Interceptor automático agrega Authorization header
- Logout limpia tokens locales
- Timeout de 10 segundos en requests

## 📱 Permisos Requeridos

- **Location (Foreground):** Para capturar GPS del incidente
- **Camera (Futuro):** Para fotos del incidente
- **ImagePicker (Futuro):** Para adjuntar imágenes

## 🚀 Próximos Pasos

- [ ] Agregar cámara para fotos de incidentes
- [ ] Offline support con cola de envío
- [ ] Notificaciones push para asignaciones
- [ ] Historial de incidentes reportados
- [ ] Tracking GPS en tiempo real durante turno
