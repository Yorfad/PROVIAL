# 📦 Guía de Instalación de Dependencias

## Problema Común: Workspaces

El proyecto usa **npm workspaces** (monorepo), lo que puede causar problemas al instalar dependencias de un solo paquete.

---

## ✅ Solución 1: Instalar Todo el Monorepo (Recomendado)

```bash
# Desde la raíz del proyecto
cd C:\Users\chris\OneDrive\Escritorio\proyectoProvialMovilWeb

# Instalar TODAS las dependencias de todos los workspaces
npm install
```

Esto instalará:
- ✅ Backend
- ✅ Web
- ✅ Mobile (cuando esté creado)
- ✅ Shared

**Ventaja:** Una sola vez, todo funciona

---

## ✅ Solución 2: Instalar Solo Backend

### Opción A: Usando workspaces (correcto)

```bash
# Desde la raíz
npm install --workspace=backend
```

### Opción B: Sin workspaces (hack temporal)

```bash
cd backend

# Eliminar referencia a workspace temporalmente
npm install --legacy-peer-deps

# O si no funciona:
npm install --no-workspaces
```

---

## ✅ Solución 3: Deshabilitar Workspaces Temporalmente

Si solo vas a trabajar en backend por ahora:

### Renombrar package.json raíz

```bash
# Desde la raíz
mv package.json package.json.bak

# Instalar backend
cd backend
npm install

# Restaurar cuando termines
cd ..
mv package.json.bak package.json
```

---

## 🔧 Versiones Corregidas

He corregido las versiones de paquetes a las últimas estables:

### Web (Frontend)
| Paquete | Antes | Ahora | Razón |
|---------|-------|-------|-------|
| leaflet | ^1.9.5 ❌ | ^1.9.4 ✅ | Versión 1.9.5 no existe |
| react-leaflet | ^5.0.2 ❌ | ^5.0.0 ✅ | Versión 5.0.2 no existe |
| react | ^19.0.0 | ^19.2.0 ✅ | Última estable |
| react-dom | ^19.0.0 | ^19.2.0 ✅ | Última estable |
| react-router-dom | ^7.1.3 | ^7.9.6 ✅ | Última estable |
| @tanstack/react-query | ^5.68.0 | ^5.90.11 ✅ | Última estable |
| vite | ^6.0.7 | ^7.2.4 ✅ | Última estable |
| typescript | ^5.9.2 | ^5.9.3 ✅ | Última estable |
| tailwindcss | ^3.4.19 ❌ | ^3.4.18 ✅ | Versión 3.4.19 no existe |

### Backend
| Paquete | Antes | Ahora | Razón |
|---------|-------|-------|-------|
| express | ^5.1.0 | ^4.21.2 ✅ | Express 5 tiene breaking changes |
| @types/express | ^5.0.1 | ^4.17.21 ✅ | Matching con Express 4 |
| typescript | ^5.9.2 | ^5.9.3 ✅ | Última estable |

---

## 🚀 Instalación Paso a Paso (Recomendado)

### 1. Instalar desde la raíz (más fácil)

```bash
# Navegar a la raíz
cd C:\Users\chris\OneDrive\Escritorio\proyectoProvialMovilWeb

# Limpiar cache de npm (por si acaso)
npm cache clean --force

# Instalar todo
npm install
```

**Tiempo estimado:** 2-5 minutos

### 2. Verificar instalación

```bash
# Verificar backend
cd backend
npm list

# Verificar que typescript está instalado
npx tsc --version

# Verificar que tsx está instalado
npx tsx --version
```

### 3. Iniciar backend

```bash
cd backend
npm run dev
```

Deberías ver:
```
✅ Conexión a PostgreSQL exitosa
✅ Redis listo para recibir comandos
🚀 Servidor iniciado en puerto 3000
```

---

## 🐛 Troubleshooting

### Error: "No matching version found for leaflet"

**Causa:** Versión incorrecta de leaflet
**Solución:** Ya lo corregí a 1.9.4, ejecuta:

```bash
npm cache clean --force
npm install
```

### Error: "workspaces in filter set, but no workspace folder present"

**Causa:** npm está confundido con workspaces
**Solución:** Instalar desde la raíz

```bash
cd C:\Users\chris\OneDrive\Escritorio\proyectoProvialMovilWeb
npm install
```

### Error: "ENOENT: no such file or directory"

**Causa:** Intentaste instalar en un workspace que no existe (mobile o shared)
**Solución:** Crear las carpetas primero

```bash
# Crear package.json básico en mobile
mkdir mobile
echo '{"name":"@provial/mobile","version":"1.0.0"}' > mobile/package.json

# Crear package.json básico en shared
mkdir shared
echo '{"name":"@provial/shared","version":"1.0.0"}' > shared/package.json

# Ahora sí instalar todo
npm install
```

### Error: "Cannot find module 'typescript'"

**Causa:** TypeScript no está instalado
**Solución:**

```bash
cd backend
npm install typescript --save-dev
```

### Error al iniciar: "Cannot find module './config/env'"

**Causa:** No se compiló TypeScript o estás usando paths incorrectos
**Solución:** Usar `tsx` para desarrollo (ya configurado)

```bash
npm run dev
# NO usar: npm start (ese es para producción con código compilado)
```

---

## 📋 Comandos Útiles

### Ver dependencias instaladas

```bash
cd backend
npm list --depth=0
```

### Reinstalar todo desde cero

```bash
# Limpiar todo
cd backend
rm -rf node_modules package-lock.json

cd ../web
rm -rf node_modules package-lock.json

cd ..
rm -rf node_modules package-lock.json

# Reinstalar
npm install
```

### Actualizar paquetes

```bash
# Ver paquetes desactualizados
npm outdated

# Actualizar todos (cuidado!)
npm update

# Actualizar uno específico
npm update express
```

---

## 🎯 Quick Start (Si todo falla)

```powershell
# 1. Limpiar TODO
cd C:\Users\chris\OneDrive\Escritorio\proyectoProvialMovilWeb
Remove-Item -Recurse -Force node_modules,backend/node_modules,web/node_modules,shared/node_modules -ErrorAction SilentlyContinue
Remove-Item package-lock.json,backend/package-lock.json,web/package-lock.json,shared/package-lock.json -ErrorAction SilentlyContinue

# 2. Limpiar cache
npm cache clean --force

# 3. Crear workspaces faltantes
mkdir -Force mobile,shared
'{"name":"@provial/mobile","version":"1.0.0"}' | Out-File mobile/package.json -Encoding utf8
'{"name":"@provial/shared","version":"1.0.0"}' | Out-File shared/package.json -Encoding utf8

# 4. Instalar desde raíz
npm install

# 5. Ir a backend e iniciar
cd backend
npm run dev
```

---

## ✅ Verificación Final

Después de instalar, verifica que tengas esto:

```
proyectoProvialMovilWeb/
├── node_modules/          ✅ (dependencias raíz)
├── backend/
│   ├── node_modules/      ✅ (dependencias backend)
│   └── package.json       ✅
├── web/
│   ├── node_modules/      ✅ (dependencias web)
│   └── package.json       ✅
├── shared/
│   └── package.json       ✅
└── package.json           ✅
```

Si todo está ✅, puedes ejecutar:

```bash
cd backend
npm run dev
```

Y deberías ver el servidor arrancar sin errores! 🚀
