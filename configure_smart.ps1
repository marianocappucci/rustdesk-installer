# ============================================================
# CONFIGURADOR INTELIGENTE DE RUSTDESK
# Aplica configuración de servidores correctamente
# ============================================================

param(
    [string]$IdServer = "149.50.136.218",
    [string]$RelayServer = "149.50.136.218",
    [string]$ServerKey = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="
)

# Variables
$rustdeskAppData = "$env:APPDATA\RustDesk"
$rustdeskConfig = "$rustdeskAppData\config"
$configFile = "$rustdeskConfig\RustDesk.toml"
$rustdeskExe = "$rustdeskAppData\rustdesk.exe"

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Configurador Inteligente de RustDesk" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# ============================================================
# 1. VERIFICAR QUE RUSTDESK ESTA INSTALADO
# ============================================================
Write-Host "[1/5] Verificando RustDesk..." -ForegroundColor Yellow

if (-not (Test-Path $rustdeskAppData)) {
    Write-Host "[!] RustDesk no está instalado`n" -ForegroundColor Red
    Write-Host "    Ejecuta primero: install_smart.ps1`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "[✓] RustDesk encontrado en: $rustdeskAppData`n" -ForegroundColor Green

# ============================================================
# 2. DETENER RUSTDESK
# ============================================================
Write-Host "[2/5] Deteniendo RustDesk..." -ForegroundColor Yellow

$rustdeskProcess = Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue

if ($rustdeskProcess) {
    Write-Host "[*] Deteniendo proceso: $($rustdeskProcess.Count) instancia(s)`n" -ForegroundColor Yellow
    Stop-Process -Name "rustdesk" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
} else {
    Write-Host "[*] RustDesk no está en ejecución`n" -ForegroundColor Gray
}

Write-Host "[✓] Listo para configurar`n" -ForegroundColor Green

# ============================================================
# 3. CREAR CARPETA DE CONFIGURACION
# ============================================================
Write-Host "[3/5] Preparando directorio de configuración..." -ForegroundColor Yellow

if (-not (Test-Path $rustdeskConfig)) {
    New-Item -ItemType Directory -Path $rustdeskConfig -Force | Out-Null
    Write-Host "[*] Carpeta creada: $rustdeskConfig`n" -ForegroundColor Yellow
} else {
    Write-Host "[*] Carpeta ya existe: $rustdeskConfig`n" -ForegroundColor Gray
}

# ============================================================
# 4. CREAR ARCHIVO DE CONFIGURACION
# ============================================================
Write-Host "[4/5] Escribiendo configuración..." -ForegroundColor Yellow

# Crear contenido del archivo TOML
$configContent = @"
# Configuracion de RustDesk
# Servidor personalizado
# Actualizado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

[network]
relay-server = "$RelayServer"

[server]
id = "$IdServer"
key = "$ServerKey"
"@

# Escribir archivo
try {
    $configContent | Out-File -FilePath $configFile -Encoding UTF8 -Force
    Write-Host "[✓] Archivo escrito: $configFile`n" -ForegroundColor Green
} catch {
    Write-Host "[!] Error escribiendo archivo: $_`n" -ForegroundColor Red
    exit 1
}

# Verificar contenido
Write-Host "Contenido del archivo TOML:`n" -ForegroundColor Cyan
Write-Host $configContent -ForegroundColor Gray
Write-Host "`n"

# ============================================================
# 5. INICIAR RUSTDESK
# ============================================================
Write-Host "[5/5] Iniciando RustDesk..." -ForegroundColor Yellow

if (Test-Path $rustdeskExe) {
    try {
        Start-Process -FilePath $rustdeskExe -ErrorAction SilentlyContinue
        Write-Host "[✓] RustDesk iniciado`n" -ForegroundColor Green
        Start-Sleep -Seconds 5
    } catch {
        Write-Host "[!] Error iniciando RustDesk: $_`n" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] RustDesk.exe no encontrado`n" -ForegroundColor Red
    exit 1
}

# ============================================================
# VERIFICACION
# ============================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "✓ CONFIGURACION APLICADA" -ForegroundColor Green
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "Servidores configurados:" -ForegroundColor Cyan
Write-Host "  ID Server:      $IdServer" -ForegroundColor Yellow
Write-Host "  Relay Server:   $RelayServer" -ForegroundColor Yellow
Write-Host "  Archivo config: $configFile`n" -ForegroundColor Yellow

Write-Host "VERIFICACION:" -ForegroundColor Cyan
Write-Host "  1. Espera 5-10 segundos para que RustDesk cargue" -ForegroundColor White
Write-Host "  2. Abre RustDesk (debe abrirse automáticamente)" -ForegroundColor White
Write-Host "  3. Ve a: Configuración > Preferencias" -ForegroundColor White
Write-Host "  4. Busca la pestaña 'Rojo' (Opciones avanzadas)" -ForegroundColor White
Write-Host "  5. Verifica que los servidores estén en la lista`n" -ForegroundColor White

Write-Host "SI LOS SERVIDORES NO APARECEN:" -ForegroundColor Yellow
Write-Host "  • Cierra RustDesk completamente" -ForegroundColor Yellow
Write-Host "  • Ejecuta este script nuevamente" -ForegroundColor Yellow
Write-Host "  • O comprueba el archivo TOML manualmente" -ForegroundColor Yellow

Write-Host "ARCHIVO DE CONFIGURACION:" -ForegroundColor Cyan
Write-Host "  Ruta: $configFile`n" -ForegroundColor Gray

Write-Host "Contenido:" -ForegroundColor Cyan
$configContent | Write-Host -ForegroundColor Gray

Write-Host "`n============================================================`n" -ForegroundColor Cyan

Write-Host "RustDesk se está abriendo en 5 segundos..." -ForegroundColor Yellow
Write-Host "Si no se abre, busca 'RustDesk' en el menú Inicio`n" -ForegroundColor Yellow

Start-Sleep -Seconds 5
