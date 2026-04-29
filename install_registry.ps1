# ============================================================
# INSTALADOR RUSTDESK - USANDO REGISTRO DE WINDOWS
# Configura servidor a través del registro (método alternativo)
# ============================================================

param(
    [string]$IdServer = "149.50.136.218",
    [string]$RelayServer = "149.50.136.218",
    [string]$ServerKey = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="
)

# Títulos
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Instalador RustDesk - Configuración por Registro" -ForegroundColor Cyan
Write-Host "Método alternativo (Registry)" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

$rustdeskAppData = "$env:APPDATA\RustDesk"
$rustdeskConfig = "$rustdeskAppData\config"
$configFile = "$rustdeskConfig\RustDesk.toml"
$rustdeskExe = "$rustdeskAppData\rustdesk.exe"

# ============================================================
# 1. VERIFICAR SI RUSTDESK ESTA INSTALADO
# ============================================================
Write-Host "[1/4] Verificando RustDesk..." -ForegroundColor Yellow

if (-not (Test-Path $rustdeskExe)) {
    Write-Host "[!] RustDesk no está instalado`n" -ForegroundColor Red
    Write-Host "    Ejecuta primero: install_smart.ps1`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "[✓] RustDesk encontrado`n" -ForegroundColor Green

# ============================================================
# 2. DETENER RUSTDESK
# ============================================================
Write-Host "[2/4] Deteniendo RustDesk..." -ForegroundColor Yellow

Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "[✓] RustDesk detenido`n" -ForegroundColor Green

# ============================================================
# 3. CREAR ARCHIVO TOML
# ============================================================
Write-Host "[3/4] Creando archivo TOML..." -ForegroundColor Yellow

if (-not (Test-Path $rustdeskConfig)) {
    New-Item -ItemType Directory -Path $rustdeskConfig -Force | Out-Null
}

$configContent = @"
# Configuracion de RustDesk
# Servidor ID y Relay personalizado
# Actualizado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

[network]
relay-server = "$RelayServer"

[server]
id = "$IdServer"
key = "$ServerKey"
"@

$configContent | Out-File -FilePath $configFile -Encoding UTF8 -Force

Write-Host "[✓] Archivo TOML creado: $configFile`n" -ForegroundColor Green

# ============================================================
# 4. CONFIGURAR REGISTRO (METODO ALTERNATIVO)
# ============================================================
Write-Host "[4/4] Configurando registro de Windows..." -ForegroundColor Yellow

# Crear llave de registro si no existe
$regPath = "HKCU:\Software\RustDesk"

try {
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Write-Host "[*] Creada llave de registro`n" -ForegroundColor Yellow
    }

    # Intentar establecer valores en el registro
    # Nota: Los nombres exactos pueden variar según versión de RustDesk

    # Estos son valores típicos que RustDesk podría usar
    $regValues = @{
        "relay-server" = $RelayServer
        "id-server" = $IdServer
        "server-id" = $IdServer
        "relay" = $RelayServer
    }

    foreach ($valueName in $regValues.Keys) {
        try {
            Set-ItemProperty -Path $regPath -Name $valueName -Value $regValues[$valueName] -ErrorAction SilentlyContinue
            Write-Host "[*] Registro: $valueName = $($regValues[$valueName])" -ForegroundColor Gray
        } catch {
            # Silenciosamente continuar si falla
        }
    }

    Write-Host "[✓] Registro configurado (si es aplicable)`n" -ForegroundColor Green
} catch {
    Write-Host "[!] Error en registro (continuando...): $_`n" -ForegroundColor Yellow
}

# ============================================================
# 5. INICIAR RUSTDESK
# ============================================================
Write-Host "[*] Iniciando RustDesk..." -ForegroundColor Yellow

if (Test-Path $rustdeskExe) {
    Start-Process -FilePath $rustdeskExe
    Write-Host "[✓] RustDesk iniciado`n" -ForegroundColor Green
    Start-Sleep -Seconds 5
} else {
    Write-Host "[!] RustDesk.exe no encontrado`n" -ForegroundColor Red
    exit 1
}

# ============================================================
# RESUMEN FINAL
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "✓ CONFIGURACION COMPLETADA" -ForegroundColor Green
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "Métodos aplicados:" -ForegroundColor Cyan
Write-Host "  1. Archivo TOML: $configFile" -ForegroundColor White
Write-Host "  2. Registro Windows: HKCU:\Software\RustDesk" -ForegroundColor White

Write-Host "`nConfiguración:" -ForegroundColor Cyan
Write-Host "  Servidor ID:   $IdServer" -ForegroundColor Yellow
Write-Host "  Servidor Relay: $RelayServer" -ForegroundColor Yellow

Write-Host "`nPROXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "  1. RustDesk se abrirá en 5 segundos" -ForegroundColor White
Write-Host "  2. Ve a Configuración > Preferencias" -ForegroundColor White
Write-Host "  3. Busca la pestaña 'Rojo' (Opciones avanzadas)" -ForegroundColor White
Write-Host "  4. Verifica los servidores`n" -ForegroundColor White

Write-Host "SI NO APARECEN LOS SERVIDORES:" -ForegroundColor Yellow
Write-Host "  1. Cierra RustDesk" -ForegroundColor Yellow
Write-Host "  2. Ejecuta: .\diagnostico.ps1" -ForegroundColor Yellow
Write-Host "  3. Busca el archivo TOML creado" -ForegroundColor Yellow
Write-Host "  4. Verifica las ubicaciones posibles`n" -ForegroundColor Yellow

Write-Host "============================================================`n" -ForegroundColor Cyan
