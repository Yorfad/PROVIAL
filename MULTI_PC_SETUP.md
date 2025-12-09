# 🖥️ Configuración Multi-PC - Sistema PROVIAL

## 📋 Resumen

Este sistema permite trabajar en **2 PCs diferentes** sin tener que modificar manualmente la configuración cada vez que cambias de una a otra.

---

## 🔍 Problema Resuelto

### Antes
- Cambiar de PC requería editar manualmente:
  - `backend/.env` (cambiar IPs)
  - `mobile/src/constants/config.ts` (cambiar URL del API)
- Riesgo de commitear configuraciones incorrectas a Git
- Tiempo perdido buscando y cambiando IPs

### Ahora
- **Un solo comando**: `.\switch-pc.ps1 2`
- Cambio automático de todas las configuraciones
- Archivos de configuración específicos por PC
- Git ignora los archivos activos, mantiene los templates

---

## 📁 Archivos de Configuración

### Backend

| Archivo | Descripción | Git |
|---------|-------------|-----|
| `backend/.env.pc1` | Configuración PC 1 (172.20.10.4) | ✅ Tracked |
| `backend/.env.pc2` | Configuración PC 2 (192.168.10.105) | ✅ Tracked |
| `backend/.env` | **Archivo activo** (generado) | ❌ Ignored |

### Mobile

| Archivo | Descripción | Git |
|---------|-------------|-----|
| `mobile/src/constants/config.pc1.ts` | Configuración PC 1 | ✅ Tracked |
| `mobile/src/constants/config.pc2.ts` | Configuración PC 2 | ✅ Tracked |
| `mobile/src/constants/config.ts` | **Archivo activo** (generado) | ❌ Ignored |

---

## 🚀 Uso del Sistema

### Cambiar a PC 1

```powershell
.\switch-pc.ps1 1
```

Esto hace:
1. Copia `backend/.env.pc1` → `backend/.env`
2. Copia `mobile/src/constants/config.pc1.ts` → `mobile/src/constants/config.ts`
3. Guarda "1" en `.pc-config`

### Cambiar a PC 2

```powershell
.\switch-pc.ps1 2
```

Esto hace:
1. Copia `backend/.env.pc2` → `backend/.env`
2. Copia `mobile/src/constants/config.pc2.ts` → `mobile/src/constants/config.ts`
3. Guarda "2" en `.pc-config`

### Sin argumentos (interactivo)

```powershell
.\switch-pc.ps1
```

Te preguntará qué PC usar.

---

## 🔧 Configuraciones por PC

### PC 1 - Red Original
- **IP**: 172.20.10.4
- **Red**: 172.20.10.0/24
- **Backend**: http://172.20.10.4:3001
- **API URL**: http://172.20.10.4:3001/api
- **PostgreSQL**: localhost:5433 (Docker)
- **Redis**: localhost:6379 (Docker)

### PC 2 - Red Nueva
- **IP**: 192.168.10.105
- **Red**: 192.168.10.0/24
- **Backend**: http://192.168.10.105:3001
- **API URL**: http://192.168.10.105:3001/api
- **PostgreSQL**: localhost:5433 (Docker)
- **Redis**: localhost:6379 (Docker)

### Servicios Docker

**Son iguales en ambas PCs** porque Docker usa `localhost`:
- PostgreSQL: `127.0.0.1:5433`
- Redis: `127.0.0.1:6379`
- pgAdmin: `localhost:5050`

---

## 📱 Cómo Funciona la App Móvil

La app móvil necesita conectarse al backend usando la **IP de la red local** de la PC donde corre el backend.

### PC 1
```typescript
// mobile/src/constants/config.pc1.ts
export const API_URL = 'http://172.20.10.4:3001/api';
```

### PC 2
```typescript
// mobile/src/constants/config.pc2.ts
export const API_URL = 'http://192.168.10.105:3001/api';
```

Cuando ejecutas `switch-pc.ps1 2`, se copia el archivo correcto a `config.ts` que es el que usa la app.

---

## ⚠️ Importante

### Después de Cambiar de PC

**Siempre debes**:
1. Reiniciar el backend
2. Reiniciar la app móvil con cache limpio

```powershell
# Backend
cd backend
npm run dev

# Mobile (en otra terminal)
cd mobile
npx expo start --clear
```

El flag `--clear` limpia el cache de Metro bundler para que use el nuevo `config.ts`.

### No Commits Accidentales

El `.gitignore` está configurado para:
- ✅ **Trackear** templates (`.env.pc1`, `.env.pc2`, `config.pc1.ts`, `config.pc2.ts`)
- ❌ **Ignorar** archivos activos (`.env`, `config.ts`, `.pc-config`)

Esto significa que:
- Los templates se suben a Git (otros desarrolladores los tienen)
- Tu configuración local NO se sube (no contaminas otros entornos)

---

## 🔍 Verificar Configuración Actual

### Ver qué PC está activa

```powershell
cat .pc-config
```

Muestra `1` o `2`.

### Ver configuración de backend

```powershell
cat backend/.env | findstr PC_IP
```

Muestra la IP actual.

### Ver configuración de mobile

```powershell
cat mobile/src/constants/config.ts | findstr API_URL
```

Muestra la URL del API.

---

## 🆕 Agregar Nueva PC

Si necesitas trabajar en una **tercera PC**:

### 1. Obtener IP de la nueva PC

```powershell
ipconfig
```

Busca tu adaptador de red y anota la IPv4 (ej: `192.168.1.50`).

### 2. Crear archivos de configuración

```powershell
# Backend
copy backend\.env.pc1 backend\.env.pc3
# Editar y cambiar PC_IP a tu nueva IP

# Mobile
copy mobile\src\constants\config.pc1.ts mobile\src\constants\config.pc3.ts
# Editar y cambiar API_URL a http://TU_NUEVA_IP:3001/api
```

### 3. Actualizar script

Editar `switch-pc.ps1` y agregar validación para `'3'`.

### 4. Actualizar .gitignore

Agregar:
```
!backend/.env.pc3
!mobile/src/constants/config.pc3.ts
```

---

## 🐛 Troubleshooting

### "No se puede conectar a la API"

1. Verifica que el backend esté corriendo:
   ```powershell
   curl http://localhost:3001/health
   ```

2. Verifica la IP correcta:
   ```powershell
   ipconfig
   ```

3. Verifica que usaste el script:
   ```powershell
   cat .pc-config
   ```

4. Verifica el firewall de Windows (permitir puerto 3001)

### "La app móvil no carga datos"

1. Verifica que el backend esté accesible desde la red:
   ```powershell
   # Desde el celular, abre navegador
   # http://192.168.10.105:3001/health
   ```

2. Reinicia la app con cache limpio:
   ```powershell
   cd mobile
   npx expo start --clear
   ```

3. Verifica que el celular esté en la **misma red WiFi**

### "Script da error al ejecutar"

```powershell
# Dar permisos de ejecución
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ejecutar con bypass
powershell -ExecutionPolicy Bypass -File switch-pc.ps1 2
```

---

## 📊 Flujo de Trabajo Típico

### Al llegar a PC 1

```powershell
cd C:\ruta\al\proyecto\PROVIAL
.\switch-pc.ps1 1
cd backend
npm run dev
```

### Al cambiar a PC 2

```powershell
cd C:\ruta\al\proyecto\PROVIAL
.\switch-pc.ps1 2
cd backend
npm run dev
```

### Al hacer commit

```powershell
git status
# Verifica que NO aparezcan:
# - backend/.env
# - mobile/src/constants/config.ts
# - .pc-config

git add .
git commit -m "feat: nueva funcionalidad"
git push
```

---

## ✅ Checklist de Verificación

Antes de empezar a trabajar en una PC:

- [ ] Ejecuté `switch-pc.ps1 [numero]`
- [ ] Reinicié el backend
- [ ] Reinicié la app móvil con `--clear`
- [ ] Verifiqué que `.pc-config` tenga el número correcto
- [ ] El backend responde en `http://localhost:3001/health`
- [ ] La app móvil se conecta correctamente

---

**Última actualización**: 7 de Diciembre, 2025
**Sistema creado por**: Claude Code
