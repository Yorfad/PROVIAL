# Script para cambiar configuracion entre PCs
# Uso: .\switch-pc.ps1 1  (para PC 1)
# Uso: .\switch-pc.ps1 2  (para PC 2)

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('1','2')]
    [string]$PC
)

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  CAMBIAR CONFIGURACION DE PC - SISTEMA PROVIAL" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

# Si no se especifica PC, mostrar menu
if (-not $PC) {
    Write-Host "Selecciona la PC que estas usando:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] PC 1 - Red 172.20.10.4" -ForegroundColor White
    Write-Host "  [2] PC 2 - Red 192.168.10.105" -ForegroundColor White
    Write-Host ""
    $PC = Read-Host "Ingresa el numero de PC (1 o 2)"

    if ($PC -ne '1' -and $PC -ne '2') {
        Write-Host "ERROR: Opcion invalida. Usa 1 o 2." -ForegroundColor Red
        exit 1
    }
}

# Determinar configuracion
$pcName = "PC $PC"
$backendEnv = "backend\.env.pc$PC"
$mobileConfig = "mobile\src\constants\config.pc$PC.ts"

if ($PC -eq '1') {
    $ip = "172.20.10.4"
} else {
    $ip = "192.168.10.105"
}

Write-Host "Cambiando a configuracion de $pcName (IP: $ip)..." -ForegroundColor Yellow
Write-Host ""

# Verificar que existan los archivos de configuracion
if (-not (Test-Path $backendEnv)) {
    Write-Host "ERROR: No se encontro $backendEnv" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $mobileConfig)) {
    Write-Host "ERROR: No se encontro $mobileConfig" -ForegroundColor Red
    exit 1
}

# Copiar configuracion de backend
Write-Host "[1/2] Actualizando configuracion de backend..." -ForegroundColor Cyan
Copy-Item $backendEnv "backend\.env" -Force
Write-Host "  [OK] backend\.env actualizado desde $backendEnv" -ForegroundColor Green

# Copiar configuracion de mobile
Write-Host "[2/2] Actualizando configuracion de mobile..." -ForegroundColor Cyan
Copy-Item $mobileConfig "mobile\src\constants\config.ts" -Force
Write-Host "  [OK] config.ts actualizado desde $mobileConfig" -ForegroundColor Green

# Guardar PC actual en archivo
$PC | Out-File ".pc-config" -NoNewline -Encoding utf8
Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  [OK] CONFIGURACION CAMBIADA EXITOSAMENTE" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PC Activa: $pcName" -ForegroundColor White
Write-Host "IP: $ip" -ForegroundColor White
Write-Host "API URL: http://${ip}:3001/api" -ForegroundColor White
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "1. Reiniciar backend:   cd backend ; npm run dev" -ForegroundColor White
Write-Host "2. Reiniciar app movil: cd mobile ; npx expo start --clear" -ForegroundColor White
Write-Host ""
