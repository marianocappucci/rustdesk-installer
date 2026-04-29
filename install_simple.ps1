# ============================================================
# INSTALADOR RUSTDESK - COMANDO SIMPLE
# Copia este script completo y pega en PowerShell (Admin)
# ============================================================

# Variables de configuración
$rustdeskAppData = "$env:APPDATA\RustDesk"
$rustdeskConfig = "$rustdeskAppData\config"
$configFile = "$rustdeskConfig\RustDesk.toml"
$downloadDir = "$env:TEMP\rustdesk_installer"
$msiFile = "$downloadDir\rustdesk_installer.msi"

# Datos del servidor
$idServer = "149.50.136.218"
$relayServer = "149.50.136.218"
$serverKey = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="

# Títulos
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Instalador RustDesk - Configuracion Personalizada" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# ============================================================
# 1. Obtener última versión
# ============================================================
Write-Host "[1/8] Obteniendo ultima version de RustDesk..." -ForegroundColor Yellow

try {
    $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" -UseBasicParsing
    $asset = $releases.assets | Where-Object { $_.name -like "*x86_64.msi" } | Select-Object -First 1

    if ($asset) {
        $downloadUrl = $asset.browser_download_url
        $version = $releases.tag_name
        Write-Host "[✓] Version: $version`n" -ForegroundColor Green
    }
} catch {
    Write-Host "[!] Usando URL alternativa`n" -ForegroundColor Yellow
    $downloadUrl = "https://github.com/rustdesk/rustdesk/releases/download/1.2.7/rustdesk-1.2.7-x86_64.msi"
}

# ============================================================
# 2. Crear directorio temporal
# ============================================================
Write-Host "[2/8] Creando directorio temporal..." -ForegroundColor Yellow

if (-not (Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
}
Write-Host "[✓] Directorio: $downloadDir`n" -ForegroundColor Green

# ============================================================
# 3. Descargar RustDesk
# ============================================================
Write-Host "[3/8] Descargando RustDesk..." -ForegroundColor Yellow

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $downloadUrl -OutFile $msiFile -UseBasicParsing
$size = (Get-Item $msiFile).Length / 1MB
Write-Host "[✓] Descargado (${size:F1} MB)`n" -ForegroundColor Green

# ============================================================
# 4. Detener RustDesk
# ============================================================
Write-Host "[4/8] Deteniendo RustDesk..." -ForegroundColor Yellow

Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Write-Host "[✓] RustDesk detenido`n" -ForegroundColor Green

# ============================================================
# 5. Instalar RustDesk
# ============================================================
Write-Host "[5/8] Instalando RustDesk..." -ForegroundColor Yellow

Start-Process -FilePath "msiexec.exe" `
    -ArgumentList "/i `"$msiFile`" /quiet /norestart" `
    -Wait
Start-Sleep -Seconds 5
Write-Host "[✓] RustDesk instalado`n" -ForegroundColor Green

# ============================================================
# 6. Configurar servidores
# ============================================================
Write-Host "[6/8] Configurando servidores personalizados..." -ForegroundColor Yellow

if (-not (Test-Path $rustdeskConfig)) {
    New-Item -ItemType Directory -Path $rustdeskConfig -Force | Out-Null
}

$configContent = @"
# Configuracion de RustDesk
# Actualizado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

[network]
relay = "$relayServer"

[server]
id = "$idServer"
key = "$serverKey"

"@

$configContent | Out-File -FilePath $configFile -Encoding UTF8 -Force
Write-Host "[✓] Archivo: $configFile`n" -ForegroundColor Green

# ============================================================
# 7. Iniciar RustDesk
# ============================================================
Write-Host "[7/8] Iniciando RustDesk..." -ForegroundColor Yellow

$rustdeskExe = "$rustdeskAppData\rustdesk.exe"
if (Test-Path $rustdeskExe) {
    Start-Process -FilePath $rustdeskExe
    Write-Host "[✓] RustDesk iniciado`n" -ForegroundColor Green
}

# ============================================================
# 8. Limpiar archivos
# ============================================================
Write-Host "[8/8] Limpiando archivos temporales..." -ForegroundColor Yellow

Remove-Item -Path $downloadDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[✓] Limpieza completada`n" -ForegroundColor Green

# ============================================================
# Resumen final
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "✓ INSTALACION COMPLETADA" -ForegroundColor Green
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "Detalles:`n" -ForegroundColor White
Write-Host "  Servidor ID:      $idServer"
Write-Host "  Servidor Relay:   $relayServer"
Write-Host "  Ubicacion:        $rustdeskAppData"
Write-Host "  Archivo config:   $configFile`n"

Write-Host "RustDesk se está iniciando... Espera 10-15 segundos" -ForegroundColor Yellow
Write-Host "`nVe a Configuracion > Preferencias para verificar los servidores`n" -ForegroundColor Cyan
