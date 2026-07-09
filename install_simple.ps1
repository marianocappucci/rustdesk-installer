# ============================================================
# INSTALADOR RUSTDESK - NeuroFlow
# Descarga la ultima version, muestra progreso en tiempo real
# ============================================================

# Verificar administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
if (-not $isAdmin) {
    Write-Host ""
    Write-Host "  ERROR: Ejecuta PowerShell como Administrador" -ForegroundColor Red
    Write-Host "  Clic derecho en PowerShell > Ejecutar como administrador" -ForegroundColor Yellow
    Write-Host ""
    pause; exit 1
}

# Configuracion del servidor
$idServer    = "149.50.136.218"
$relayServer = "149.50.136.218"
$serverKey   = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="

# Rutas
$rustdeskAppData = "$env:APPDATA\RustDesk"
$rustdeskConfig  = "$rustdeskAppData\config"
$configFile      = "$rustdeskConfig\RustDesk.toml"
$downloadDir     = "$env:TEMP\rustdesk_installer"
$msiFile         = "$downloadDir\rustdesk_installer.msi"

Clear-Host
Write-Host ""
Write-Host "  =====================================================" -ForegroundColor Cyan
Write-Host "       INSTALADOR RUSTDESK - NeuroFlow                 " -ForegroundColor Cyan
Write-Host "  =====================================================" -ForegroundColor Cyan
Write-Host ""

# ─────────────────────────────────────────────
# Funcion: barra de progreso visual
# ─────────────────────────────────────────────
function Write-Bar {
    param([int]$Pct, [string]$Extra = "")
    $width    = 35
    $filled   = [Math]::Round($width * $Pct / 100)
    $empty    = $width - $filled
    $bar      = ("#" * $filled) + ("-" * $empty)
    Write-Host "`r  [$bar] $Pct%  $Extra   " -NoNewline -ForegroundColor Cyan
}

# ─────────────────────────────────────────────
# PASO 1: Obtener ultima version
# ─────────────────────────────────────────────
Write-Host "  [1/6] Buscando ultima version disponible..." -ForegroundColor Yellow

$downloadUrl = $null
$version     = $null

# Metodo 1: GitHub API con cabeceras correctas
try {
    $apiHeaders = @{
        "User-Agent" = "Mozilla/5.0 RustDesk-Installer/1.0"
        "Accept"     = "application/vnd.github.v3+json"
    }
    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" `
        -Headers $apiHeaders `
        -UseBasicParsing `
        -TimeoutSec 20

    # Buscar MSI x86_64 con distintos patrones de nombre
    $asset = $release.assets | Where-Object { $_.name -match "x86_64.*\.msi$" } | Select-Object -First 1
    if (-not $asset) {
        $asset = $release.assets | Where-Object { $_.name -match "\.msi$" } | Select-Object -First 1
    }
    if ($asset) {
        $downloadUrl = $asset.browser_download_url
        $version     = $release.tag_name
    }
} catch {
    # Continua al siguiente metodo
}

# Metodo 2: seguir el redirect de /releases/latest para obtener el tag
if (-not $downloadUrl) {
    try {
        $req = [System.Net.WebRequest]::Create("https://github.com/rustdesk/rustdesk/releases/latest")
        $req.AllowAutoRedirect = $true
        $req.UserAgent = "RustDesk-Installer/1.0"
        $resp    = $req.GetResponse()
        $finalUrl = $resp.ResponseUri.AbsoluteUri
        $resp.Close()

        if ($finalUrl -match "/releases/tag/([^/?#\s]+)") {
            $version     = $matches[1]
            $downloadUrl = "https://github.com/rustdesk/rustdesk/releases/download/$version/rustdesk-$version-x86_64.msi"
        }
    } catch {
        # Continua
    }
}

if ($downloadUrl) {
    Write-Host "  [OK] Version: $version" -ForegroundColor Green
    Write-Host "       $downloadUrl" -ForegroundColor DarkGray
    Write-Host ""
} else {
    Write-Host "  [!!] No se pudo detectar la version automaticamente." -ForegroundColor Red
    Write-Host "       Verifica tu conexion a internet e intenta nuevamente." -ForegroundColor Yellow
    Write-Host ""
    pause; exit 1
}

# ─────────────────────────────────────────────
# PASO 2: Descargar RustDesk
# ─────────────────────────────────────────────
Write-Host "  [2/6] Descargando RustDesk $version..." -ForegroundColor Yellow
Write-Host "        (puede tardar 1-3 minutos segun tu conexion)" -ForegroundColor DarkGray
Write-Host ""

if (-not (Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
}

# Obtener tamano total del archivo para la barra de progreso
$totalMB = 0
try {
    $headReq = [System.Net.WebRequest]::Create($downloadUrl)
    $headReq.Method    = "HEAD"
    $headReq.UserAgent = "RustDesk-Installer/1.0"
    $headResp = $headReq.GetResponse()
    $totalMB  = [Math]::Round($headResp.ContentLength / 1MB, 1)
    $headResp.Close()
} catch {}

$downloadOk = $false

# Metodo 1: BITS (progreso nativo de Windows)
try {
    Import-Module BitsTransfer -ErrorAction Stop
    Start-BitsTransfer `
        -Source $downloadUrl `
        -Destination $msiFile `
        -DisplayName "RustDesk $version" `
        -Description "Descargando instalador de RustDesk..."
    $downloadOk = $true
} catch {}

# Metodo 2: WebClient en Job con barra de progreso por tamano de archivo
if (-not $downloadOk) {
    if (Test-Path $msiFile) { Remove-Item $msiFile -Force }

    $dlJob = Start-Job -ScriptBlock {
        param($url, $dest)
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "RustDesk-Installer/1.0")
        $wc.DownloadFile($url, $dest)
    } -ArgumentList $downloadUrl, $msiFile

    while ($dlJob.State -eq 'Running') {
        if (Test-Path $msiFile) {
            $currentMB = [Math]::Round((Get-Item $msiFile).Length / 1MB, 1)
            if ($totalMB -gt 0) {
                $pct = [Math]::Min(99, [Math]::Round($currentMB / $totalMB * 100))
                Write-Bar -Pct $pct -Extra "$currentMB MB / $totalMB MB"
            } else {
                Write-Host "`r  Descargando... $currentMB MB   " -NoNewline -ForegroundColor Cyan
            }
        }
        Start-Sleep -Milliseconds 500
    }

    $jobError = Receive-Job $dlJob 2>&1
    Remove-Job $dlJob

    if ($jobError -and $jobError -match "Exception") {
        Write-Host ""
        Write-Host "  [!!] Error en descarga: $jobError" -ForegroundColor Red
        pause; exit 1
    }
    $downloadOk = $true
}

# Metodo 3: Invoke-WebRequest como ultimo recurso
if (-not $downloadOk) {
    try {
        $ProgressPreference = 'Continue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $msiFile -UseBasicParsing
        $downloadOk = $true
    } catch {
        Write-Host "  [!!] Error al descargar: $_" -ForegroundColor Red
        pause; exit 1
    }
}

# Validar archivo descargado
if (-not (Test-Path $msiFile) -or (Get-Item $msiFile).Length -lt 1MB) {
    Write-Host ""
    Write-Host "  [!!] El archivo descargado parece incompleto o corrupto." -ForegroundColor Red
    Write-Host "       Intenta nuevamente o verifica tu conexion." -ForegroundColor Yellow
    pause; exit 1
}

$sizeMB = [Math]::Round((Get-Item $msiFile).Length / 1MB, 1)
Write-Bar -Pct 100 -Extra "$sizeMB MB"
Write-Host ""
Write-Host "  [OK] Descargado correctamente: $sizeMB MB" -ForegroundColor Green
Write-Host ""

# ─────────────────────────────────────────────
# PASO 3: Detener RustDesk si esta corriendo
# ─────────────────────────────────────────────
Write-Host "  [3/6] Deteniendo RustDesk..." -ForegroundColor Yellow
Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "  [OK] Listo" -ForegroundColor Green
Write-Host ""

# ─────────────────────────────────────────────
# PASO 4: Instalar RustDesk
# ─────────────────────────────────────────────
Write-Host "  [4/6] Instalando RustDesk $version..." -ForegroundColor Yellow
Write-Host "        (puede tardar 1-3 minutos, no cierres esta ventana)" -ForegroundColor DarkGray
Write-Host ""

$proc = Start-Process -FilePath "msiexec.exe" `
    -ArgumentList "/i `"$msiFile`" /quiet /norestart" `
    -PassThru

# Spinner mientras el instalador trabaja en segundo plano
$spinChars  = @('|', '/', '-', '\')
$spinIdx    = 0
$installStart = Get-Date

while (-not $proc.HasExited) {
    $elapsed = [Math]::Round((Get-Date).Subtract($installStart).TotalSeconds)
    $s       = $spinChars[$spinIdx % 4]
    Write-Host "`r  $s Instalando... ($elapsed seg transcurridos)   " -NoNewline -ForegroundColor Yellow
    Start-Sleep -Milliseconds 300
    $spinIdx++
}

Write-Host "`r  [OK] Instalacion completada                                  " -ForegroundColor Green
Write-Host ""

# Codigo 3010 = exito, reinicio requerido (es normal, no es error)
if ($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) {
    Write-Host "  [!!] Error durante la instalacion (codigo: $($proc.ExitCode))" -ForegroundColor Red
    Write-Host "       Intenta ejecutar el script nuevamente." -ForegroundColor Yellow
    pause; exit 1
}

Start-Sleep -Seconds 3

# ─────────────────────────────────────────────
# PASO 5: Configurar servidores
# ─────────────────────────────────────────────
Write-Host "  [5/6] Configurando servidores..." -ForegroundColor Yellow

if (-not (Test-Path $rustdeskConfig)) {
    New-Item -ItemType Directory -Path $rustdeskConfig -Force | Out-Null
}

$configContent = @"
[network]
relay = "$relayServer"

[server]
id = "$idServer"
key = "$serverKey"
"@

$configContent | Out-File -FilePath $configFile -Encoding UTF8 -Force

# RustDesk2.toml - formato moderno (RustDesk 1.2+)
$configFile2 = "$rustdeskConfig\RustDesk2.toml"
$configContent2 = @"
[options]
custom-rendezvous-server = "$idServer"
relay-server = "$relayServer"
key = "$serverKey"
"@
$configContent2 | Out-File -FilePath $configFile2 -Encoding UTF8 -Force

Write-Host "  [OK] Configuracion guardada" -ForegroundColor Green

# ─────────────────────────────────────────────
# Config tambien para el servicio (cuenta SYSTEM)
# El instalador MSI registra un servicio "RustDesk" que corre como SYSTEM
# y arranca en cada boot. Si no tiene esta config, usa la de fabrica y la
# GUI la hereda al reconectarse - por eso "se resetea" tras reiniciar.
# ─────────────────────────────────────────────
try {
    $sysCfgDir = "$env:SystemRoot\System32\config\systemprofile\AppData\Roaming\RustDesk\config"
    if (-not (Test-Path $sysCfgDir)) { New-Item -ItemType Directory $sysCfgDir -Force | Out-Null }
    $configContent  | Out-File -FilePath "$sysCfgDir\RustDesk.toml"  -Encoding UTF8 -Force
    $configContent2 | Out-File -FilePath "$sysCfgDir\RustDesk2.toml" -Encoding UTF8 -Force
    Write-Host "  [OK] Configuracion del servicio (SYSTEM) guardada" -ForegroundColor Green
} catch {
    Write-Host "  [!] No se pudo escribir la config de SYSTEM: $_" -ForegroundColor Yellow
}

try {
    $svc = Get-Service -Name "RustDesk" -ErrorAction SilentlyContinue
    if ($svc) {
        Restart-Service -Name "RustDesk" -Force -ErrorAction Stop
        Write-Host "  [OK] Servicio RustDesk reiniciado" -ForegroundColor Green
    }
} catch {
    Write-Host "  [!] No se pudo reiniciar el servicio RustDesk: $_" -ForegroundColor Yellow
}
Write-Host ""

# ─────────────────────────────────────────────
# PASO 6: Iniciar RustDesk
# ─────────────────────────────────────────────
Write-Host "  [6/6] Iniciando RustDesk..." -ForegroundColor Yellow

$possiblePaths = @(
    "$env:APPDATA\RustDesk\rustdesk.exe",
    "$env:ProgramFiles\RustDesk\rustdesk.exe",
    "${env:ProgramFiles(x86)}\RustDesk\rustdesk.exe",
    "$env:LOCALAPPDATA\RustDesk\rustdesk.exe"
)
$rustdeskExe = $possiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($rustdeskExe) {
    Start-Process -FilePath $rustdeskExe -ErrorAction SilentlyContinue
    Write-Host "  [OK] RustDesk iniciado" -ForegroundColor Green
} else {
    Write-Host "  [!] Abre RustDesk desde el menu Inicio" -ForegroundColor Yellow
}

# Limpiar temporales
Remove-Item -Path $downloadDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host ""

# ─────────────────────────────────────────────
# RESUMEN FINAL
# ─────────────────────────────────────────────
Write-Host "  =====================================================" -ForegroundColor Green
Write-Host "       INSTALACION COMPLETADA EXITOSAMENTE             " -ForegroundColor Green
Write-Host "  =====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Version instalada: $version" -ForegroundColor White
Write-Host "  Servidor ID:       $idServer" -ForegroundColor White
Write-Host "  Servidor Relay:    $relayServer" -ForegroundColor White
Write-Host ""
Write-Host "  RustDesk se esta abriendo. Espera unos segundos." -ForegroundColor Cyan
Write-Host "  Si no aparece, buscalo en el menu Inicio." -ForegroundColor DarkGray
Write-Host ""
