# ============================================================
# Script de instalación de RustDesk con configuración personalizada
# RustDesk Installation Script for Windows
# ============================================================

param(
    [switch]$SkipLaunch = $false
)

# Verificar si se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "❌ Error: Este script debe ejecutarse como administrador" -ForegroundColor Red
    Write-Host "Por favor, ejecuta PowerShell como administrador" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Instalador de RustDesk - Configuración Personalizada" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# ============================================================
# CONFIGURACION
# ============================================================
$rustdeskAppData = "$env:APPDATA\RustDesk"
$rustdeskConfig = "$rustdeskAppData\config"
$configFile = "$rustdeskConfig\RustDesk.toml"
$downloadDir = "$env:TEMP\rustdesk_installer"
$msiFile = "$downloadDir\rustdesk_installer.msi"

# Datos del servidor
$idServer = "149.50.136.218"
$relayServer = "149.50.136.218"
$serverKey = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="

# ============================================================
# 1. OBTENER ULTIMA VERSION
# ============================================================
Write-Host "[*] Obteniendo información de la última versión de RustDesk..." -ForegroundColor Yellow

try {
    $apiUrl = "https://api.github.com/repos/rustdesk/rustdesk/releases/latest"
    $releases = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing

    # Buscar el archivo MSI para x86_64
    $asset = $releases.assets | Where-Object { $_.name -like "*x86_64.msi" } | Select-Object -First 1

    if ($asset) {
        $downloadUrl = $asset.browser_download_url
        $version = $releases.tag_name
        Write-Host "[✓] Versión encontrada: $version" -ForegroundColor Green
    } else {
        throw "No se encontró archivo MSI x86_64"
    }
} catch {
    Write-Host "[!] No se pudo obtener la versión automáticamente" -ForegroundColor Yellow
    Write-Host "Usando URL alternativa..." -ForegroundColor Yellow
    $downloadUrl = "https://github.com/rustdesk/rustdesk/releases/download/1.2.7/rustdesk-1.2.7-x86_64.msi"
}

Write-Host "[✓] URL: $downloadUrl`n" -ForegroundColor Green

# ============================================================
# 2. CREAR DIRECTORIO DE DESCARGA
# ============================================================
Write-Host "[*] Preparando directorio de descarga..." -ForegroundColor Yellow

if (-not (Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
}

Write-Host "[✓] Directorio: $downloadDir`n" -ForegroundColor Green

# ============================================================
# 3. DESCARGAR RUSTDESK
# ============================================================
Write-Host "[*] Descargando RustDesk..." -ForegroundColor Yellow

try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $msiFile -UseBasicParsing

    if (Test-Path $msiFile) {
        $size = (Get-Item $msiFile).Length / 1MB
        Write-Host "[✓] Descargado correctamente (${size:F1} MB)`n" -ForegroundColor Green
    } else {
        throw "El archivo no se descargó"
    }
} catch {
    Write-Host "[!] Error en descarga: $_" -ForegroundColor Red
    pause
    exit 1
}

# ============================================================
# 4. DETENER RUSTDESK
# ============================================================
Write-Host "[*] Deteniendo RustDesk si está ejecutándose..." -ForegroundColor Yellow

Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "[✓] RustDesk detenido`n" -ForegroundColor Green

# ============================================================
# 5. INSTALAR RUSTDESK
# ============================================================
Write-Host "[*] Instalando RustDesk (modo silencioso)..." -ForegroundColor Yellow

try {
    $process = Start-Process -FilePath "msiexec.exe" `
        -ArgumentList "/i `"$msiFile`" /quiet /norestart" `
        -Wait -PassThru

    Start-Sleep -Seconds 5

    Write-Host "[✓] RustDesk instalado`n" -ForegroundColor Green
} catch {
    Write-Host "[!] Error durante la instalación: $_" -ForegroundColor Red
    pause
    exit 1
}

# ============================================================
# 6. CREAR CARPETA DE CONFIGURACION
# ============================================================
Write-Host "[*] Preparando carpeta de configuración..." -ForegroundColor Yellow

if (-not (Test-Path $rustdeskConfig)) {
    New-Item -ItemType Directory -Path $rustdeskConfig -Force | Out-Null
}

Write-Host "[✓] Carpeta: $rustdeskConfig`n" -ForegroundColor Green

# ============================================================
# 7. GENERAR ARCHIVO DE CONFIGURACION
# ============================================================
Write-Host "[*] Generando archivo de configuración personalizada..." -ForegroundColor Yellow

$configContent = @"
# Configuración de RustDesk
# Servidor ID y Relay personalizado
# Fecha de configuración: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

[network]
relay = "$relayServer"

[server]
id = "$idServer"
key = "$serverKey"

"@

$configContent | Out-File -FilePath $configFile -Encoding UTF8 -Force

Write-Host "[✓] Archivo de configuración creado`n" -ForegroundColor Green

# ============================================================
# 8. MOSTRAR CONFIGURACION
# ============================================================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Configuración aplicada:" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "Servidor ID (Control Server): " -NoNewline
Write-Host "$idServer" -ForegroundColor Yellow

Write-Host "Servidor Relay:              " -NoNewline
Write-Host "$relayServer" -ForegroundColor Yellow

Write-Host "Clave del servidor:          " -NoNewline
Write-Host "$($serverKey.Substring(0, 20))..." -ForegroundColor Yellow

Write-Host "`nArchivo de configuración:    " -NoNewline
Write-Host "$configFile`n" -ForegroundColor Yellow

# ============================================================
# 9. INICIAR RUSTDESK (OPCIONAL)
# ============================================================
if (-not $SkipLaunch) {
    Write-Host "[*] Iniciando RustDesk..." -ForegroundColor Yellow

    $rustdeskExe = "$rustdeskAppData\rustdesk.exe"

    if (Test-Path $rustdeskExe) {
        Start-Process -FilePath $rustdeskExe
        Write-Host "[✓] RustDesk iniciado`n" -ForegroundColor Green
    } else {
        Write-Host "[!] RustDesk.exe no encontrado en: $rustdeskExe" -ForegroundColor Yellow
        Write-Host "Busca RustDesk en el menú Inicio`n" -ForegroundColor Yellow
    }
}

# ============================================================
# 10. LIMPIAR ARCHIVOS TEMPORALES
# ============================================================
Write-Host "[*] Limpiando archivos temporales..." -ForegroundColor Yellow

Remove-Item -Path $downloadDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "[✓] Limpieza completada`n" -ForegroundColor Green

# ============================================================
# RESUMEN FINAL
# ============================================================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "✓ Instalación completada exitosamente" -ForegroundColor Green
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Abre RustDesk desde el menú Inicio o escritorio"
Write-Host "  2. Ve a Configuración > Preferencias"
Write-Host "  3. Verifica que los servidores estén correctamente configurados"
Write-Host "  4. Reinicia RustDesk si es necesario`n" -ForegroundColor White

Write-Host "Ubicación de RustDesk:       " -NoNewline
Write-Host "$rustdeskAppData" -ForegroundColor Yellow

Write-Host "Archivo de configuración:    " -NoNewline
Write-Host "$configFile`n" -ForegroundColor Yellow

Write-Host "Para más información: https://rustdesk.com" -ForegroundColor Gray

pause
