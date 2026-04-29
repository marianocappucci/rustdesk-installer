# ============================================================
# Script de Configuración Rápida de RustDesk
# Quick Configuration Script
# ============================================================

param(
    [string]$IdServer = "149.50.136.218",
    [string]$RelayServer = "149.50.136.218",
    [string]$ServerKey = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="
)

# Verificar si se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "❌ Este script requiere privilegios de administrador" -ForegroundColor Red
    Write-Host "Ejecuta PowerShell como administrador" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Configurador Rápido de RustDesk" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# Rutas
$rustdeskAppData = "$env:APPDATA\RustDesk"
$rustdeskConfig = "$rustdeskAppData\config"
$configFile = "$rustdeskConfig\RustDesk.toml"

# ============================================================
# 1. VERIFICAR INSTALACION
# ============================================================
Write-Host "[*] Verificando instalación de RustDesk..." -ForegroundColor Yellow

if (-not (Test-Path $rustdeskAppData)) {
    Write-Host "[!] RustDesk no está instalado" -ForegroundColor Red
    Write-Host "    Ejecuta primero: install_rustdesk.ps1`n" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[✓] RustDesk está instalado`n" -ForegroundColor Green

# ============================================================
# 2. DETENER RUSTDESK
# ============================================================
Write-Host "[*] Deteniendo RustDesk..." -ForegroundColor Yellow

Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "[✓] RustDesk detenido`n" -ForegroundColor Green

# ============================================================
# 3. CREAR CARPETA SI NO EXISTE
# ============================================================
if (-not (Test-Path $rustdeskConfig)) {
    New-Item -ItemType Directory -Path $rustdeskConfig -Force | Out-Null
    Write-Host "[✓] Carpeta de configuración creada`n" -ForegroundColor Green
}

# ============================================================
# 4. CREAR/ACTUALIZAR ARCHIVO DE CONFIGURACION
# ============================================================
Write-Host "[*] Actualizando archivo de configuración..." -ForegroundColor Yellow

$configContent = @"
# Configuración de RustDesk
# Actualizado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

[network]
relay = "$RelayServer"

[server]
id = "$IdServer"
key = "$ServerKey"

"@

$configContent | Out-File -FilePath $configFile -Encoding UTF8 -Force

Write-Host "[✓] Archivo actualizado: $configFile`n" -ForegroundColor Green

# ============================================================
# 5. MOSTRAR CONFIGURACION
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Configuración aplicada:" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "Servidor ID:       " -NoNewline -ForegroundColor Gray
Write-Host "$IdServer" -ForegroundColor Yellow

Write-Host "Servidor Relay:    " -NoNewline -ForegroundColor Gray
Write-Host "$RelayServer" -ForegroundColor Yellow

Write-Host "Clave (primeros 20): " -NoNewline -ForegroundColor Gray
Write-Host "$($ServerKey.Substring(0, 20))..." -ForegroundColor Yellow

Write-Host "`nArchivo de config: " -NoNewline -ForegroundColor Gray
Write-Host "$configFile`n" -ForegroundColor Yellow

# ============================================================
# 6. INICIAR RUSTDESK
# ============================================================
Write-Host "[*] Iniciando RustDesk..." -ForegroundColor Yellow

$rustdeskExe = "$rustdeskAppData\rustdesk.exe"

if (Test-Path $rustdeskExe) {
    Start-Process -FilePath $rustdeskExe
    Write-Host "[✓] RustDesk iniciado`n" -ForegroundColor Green
} else {
    Write-Host "[!] No se encontró: $rustdeskExe`n" -ForegroundColor Yellow
}

# ============================================================
# FIN
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "✓ Configuración completada" -ForegroundColor Green
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. RustDesk se está reiniciando con la nueva configuración"
Write-Host "  2. Ve a Configuración > Preferencias para verificar"
Write-Host "  3. Conecta a tu servidor de RustDesk`n" -ForegroundColor White

pause
