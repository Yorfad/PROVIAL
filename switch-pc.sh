#!/bin/bash
# Script para cambiar configuración entre PCs
# Uso: bash switch-pc.sh 1  (para PC 1)
# Uso: bash switch-pc.sh 2  (para PC 2)

PC=$1

echo "═══════════════════════════════════════════════════"
echo "  CAMBIAR CONFIGURACIÓN DE PC - SISTEMA PROVIAL"
echo "═══════════════════════════════════════════════════"
echo ""

# Si no se especifica PC, mostrar menú
if [ -z "$PC" ]; then
    echo "Selecciona la PC que estás usando:"
    echo ""
    echo "  [1] PC 1 - Red 172.20.10.4"
    echo "  [2] PC 2 - Red 192.168.10.105"
    echo ""
    read -p "Ingresa el número de PC (1 o 2): " PC

    if [ "$PC" != "1" ] && [ "$PC" != "2" ]; then
        echo "ERROR: Opción inválida. Usa 1 o 2."
        exit 1
    fi
fi

# Determinar configuración
pcName="PC $PC"
backendEnv="backend/.env.pc$PC"
mobileConfig="mobile/src/constants/config.pc$PC.ts"

if [ "$PC" == "1" ]; then
    ip="172.20.10.4"
else
    ip="192.168.10.105"
fi

echo "Cambiando a configuración de $pcName (IP: $ip)..."
echo ""

# Verificar que existan los archivos de configuración
if [ ! -f "$backendEnv" ]; then
    echo "ERROR: No se encontró $backendEnv"
    exit 1
fi

if [ ! -f "$mobileConfig" ]; then
    echo "ERROR: No se encontró $mobileConfig"
    exit 1
fi

# Copiar configuración de backend
echo "[1/2] Actualizando configuración de backend..."
cp "$backendEnv" "backend/.env"
echo "  ✓ backend/.env actualizado desde $backendEnv"

# Copiar configuración de mobile
echo "[2/2] Actualizando configuración de mobile..."
cp "$mobileConfig" "mobile/src/constants/config.ts"
echo "  ✓ config.ts actualizado desde $mobileConfig"

# Guardar PC actual en archivo
echo -n "$PC" > .pc-config

echo ""
echo "═══════════════════════════════════════════════════"
echo "  ✓ CONFIGURACIÓN CAMBIADA EXITOSAMENTE"
echo "═══════════════════════════════════════════════════"
echo ""
echo "PC Activa: $pcName"
echo "IP: $ip"
echo "API URL: http://${ip}:3001/api"
echo ""
echo "Próximos pasos:"
echo "1. Reiniciar backend: cd backend && npm run dev"
echo "2. Reiniciar app móvil: cd mobile && npx expo start --clear"
echo ""
