# ============================================================
# INSTALADOR RUSTDESK - VERSION MEJORADA
# Detecta instalación existente y configura correctamente
# ============================================================

# Detener en errores
$ErrorActionPreference = 'Stop'

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
Write-Host "Instalador RustDesk INTELIGENTE" -ForegroundColor Cyan
Write-Host "Detecta instalación y configura automáticamente" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# ============================================================
# 0. VERIFICAR SI RUSTDESK YA ESTA INSTALADO
# ============================================================
Write-Host "[0/?] Verificando instalación existente..." -ForegroundColor Yellow

$rustdeskInstalled = $false
$rustdeskExe = "$rustdeskAppData\rustdesk.exe"

# Verificar por archivo ejecutable
if (Test-Path $rustdeskExe) {
    Write-Host "[✓] RustDesk ya está instalado`n" -ForegroundColor Green
    $rustdeskInstalled = $true
}

# Verificar por registro (instalación MSI)
try {
    $regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $rustdeskReg = Get-ItemProperty $regPath | Where-Object { $_.DisplayName -like "*RustDesk*" }

    if ($rustdeskReg) {
        Write-Host "[✓] RustDesk encontrado en registro`n" -ForegroundColor Green
        $rustdeskInstalled = $true
    }
} catch {
    Write-Host "[!] No se pudo verificar registro`n" -ForegroundColor Yellow
}

# ============================================================
# 1. SI NO ESTA INSTALADO - DESCARGAR E INSTALAR
# ============================================================
if (-not $rustdeskInstalled) {
    Write-Host "[1/6] Obteniendo ultima version de RustDesk..." -ForegroundColor Yellow

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

    # Crear directorio temporal
    Write-Host "[2/6] Creando directorio temporal..." -ForegroundColor Yellow
    if (-not (Test-Path $downloadDir)) {
        New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
    }
    Write-Host "[✓] Directorio: $downloadDir`n" -ForegroundColor Green

    # Descargar RustDesk
    Write-Host "[3/6] Descargando RustDesk..." -ForegroundColor Yellow
    $ProgressPreference = 'SilentlyContinue'
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $msiFile -UseBasicParsing
        $size = (Get-Item $msiFile).Length / 1MB
        Write-Host "[✓] Descargado (${size:F1} MB)`n" -ForegroundColor Green
    } catch {
        Write-Host "[!] Error en descarga: $_`n" -ForegroundColor Red
        exit 1
    }

    # Detener RustDesk si está corriendo
    Write-Host "[4/6] Deteniendo RustDesk..." -ForegroundColor Yellow
    Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "[✓] RustDesk detenido`n" -ForegroundColor Green

    # Instalar RustDesk
    Write-Host "[5/6] Instalando RustDesk (esto puede tomar unos minutos)..." -ForegroundColor Yellow
    try {
        $process = Start-Process -FilePath "msiexec.exe" `
            -ArgumentList "/i `"$msiFile`" /quiet /norestart" `
            -Wait -PassThru

        # Esperar a que se cree la carpeta de RustDesk
        $maxWait = 30
        $waited = 0
        while (-not (Test-Path $rustdeskAppData) -and $waited -lt $maxWait) {
            Start-Sleep -Seconds 1
            $waited++
        }

        Start-Sleep -Seconds 3
        Write-Host "[✓] RustDesk instalado`n" -ForegroundColor Green
    } catch {
        Write-Host "[!] Error en instalación: $_`n" -ForegroundColor Red
        exit 1
    }

    $rustdeskInstalled = $true
}

# ============================================================
# 2. CONFIGURAR SERVIDORES (Instalación nueva o existente)
# ============================================================
Write-Host "[*] Configurando servidores personalizados..." -ForegroundColor Yellow

# Detener RustDesk antes de modificar configuración
Write-Host "[*] Deteniendo RustDesk antes de configurar..." -ForegroundColor Yellow
Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Crear directorio de configuración si no existe
if (-not (Test-Path $rustdeskConfig)) {
    Write-Host "[*] Creando directorio de configuración..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $rustdeskConfig -Force | Out-Null
}

# Crear archivo de configuración
Write-Host "[*] Escribiendo configuración en archivo TOML..." -ForegroundColor Yellow

$configContent = @"
# Configuracion de RustDesk
# Servidor ID y Relay Personalizado
# Actualizado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

[network]
relay-server = "$relayServer"

[server]
id = "$idServer"
key = "$serverKey"
"@

# Escribir el archivo
$configContent | Out-File -FilePath $configFile -Encoding UTF8 -Force
Write-Host "[✓] Archivo creado: $configFile`n" -ForegroundColor Green

# Verificar que el archivo se creó correctamente
if (Test-Path $configFile) {
    Write-Host "[✓] Archivo verificado`n" -ForegroundColor Green
    $fileContent = Get-Content $configFile
    Write-Host "Contenido del archivo:`n" -ForegroundColor Cyan
    Write-Host $fileContent -ForegroundColor Gray
    Write-Host "`n"
} else {
    Write-Host "[!] Error: No se pudo crear el archivo de configuración`n" -ForegroundColor Red
    exit 1
}

# ============================================================
# 3. INICIAR RUSTDESK
# ============================================================
Write-Host "[*] Iniciando RustDesk..." -ForegroundColor Yellow

$rustdeskExe = "$rustdeskAppData\rustdesk.exe"

if (Test-Path $rustdeskExe) {
    try {
        Start-Process -FilePath $rustdeskExe -ErrorAction SilentlyContinue
        Write-Host "[✓] RustDesk iniciado`n" -ForegroundColor Green

        # Esperar a que RustDesk se abra
        Start-Sleep -Seconds 3
    } catch {
        Write-Host "[!] No se pudo iniciar RustDesk: $_`n" -ForegroundColor Yellow
        Write-Host "[*] Busca RustDesk en el menú Inicio`n" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] RustDesk.exe no encontrado en: $rustdeskExe`n" -ForegroundColor Red
    exit 1
}

# ============================================================
# 4. LIMPIAR ARCHIVOS TEMPORALES
# ============================================================
if (Test-Path $downloadDir) {
    Write-Host "[*] Limpiando archivos temporales..." -ForegroundColor Yellow
    Remove-Item -Path $downloadDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[✓] Limpieza completada`n" -ForegroundColor Green
}

# ============================================================
# RESUMEN FINAL
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "✓ CONFIGURACION COMPLETADA" -ForegroundColor Green
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "Estado:" -ForegroundColor White
if ($rustdeskInstalled) {
    Write-Host "  Instalación:      Ya estaba instalado ✓" -ForegroundColor Gray
} else {
    Write-Host "  Instalación:      Nueva instalación completada ✓" -ForegroundColor Gray
}

Write-Host "`nConfiguración:" -ForegroundColor White
Write-Host "  Servidor ID:      $idServer" -ForegroundColor Gray
Write-Host "  Servidor Relay:   $relayServer" -ForegroundColor Gray
Write-Host "  Clave:            $($serverKey.Substring(0, 20))..." -ForegroundColor Gray

Write-Host "`nUbicación:" -ForegroundColor White
Write-Host "  RustDesk:         $rustdeskAppData" -ForegroundColor Gray
Write-Host "  Configuración:    $configFile" -ForegroundColor Gray

Write-Host "`nProximos pasos:" -ForegroundColor Cyan
Write-Host "  1. RustDesk se abrirá automáticamente" -ForegroundColor White
Write-Host "  2. Espera 5-10 segundos para que cargue la configuración" -ForegroundColor White
Write-Host "  3. Abre Configuración > Preferencias > Rojo (Opciones)" -ForegroundColor White
Write-Host "  4. Verifica que los servidores estén correctamente configurados" -ForegroundColor White
Write-Host "  5. Si ves los servidores, ¡todo funciona correctamente!" -ForegroundColor White

Write-Host "`n⚠️  IMPORTANTE:" -ForegroundColor Yellow
Write-Host "  Si no ves los servidores en las preferencias:" -ForegroundColor Yellow
Write-Host "  1. Cierra RustDesk completamente" -ForegroundColor Yellow
Write-Host "  2. Ejecuta este script nuevamente" -ForegroundColor Yellow
Write-Host "  3. O ejecuta: configure_rustdesk.ps1" -ForegroundColor Yellow

Write-Host "`n============================================================`n" -ForegroundColor Cyan
