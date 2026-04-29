# ============================================================
# SCRIPT DE DIAGNOSTICO - RUSTDESK CONFIGURATION
# Investiga dónde RustDesk guarda la configuración
# ============================================================

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Diagnóstico de Configuración de RustDesk" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

$rustdeskAppData = "$env:APPDATA\RustDesk"

# ============================================================
# 1. Verificar carpetas
# ============================================================
Write-Host "[1] Verificando ubicaciones de archivos..." -ForegroundColor Yellow

Write-Host "`n📁 Carpeta principal:" -ForegroundColor Cyan
Write-Host "   $rustdeskAppData" -ForegroundColor Gray
if (Test-Path $rustdeskAppData) {
    Write-Host "   ✅ Existe" -ForegroundColor Green
} else {
    Write-Host "   ❌ NO existe" -ForegroundColor Red
}

Write-Host "`n📁 Subcarpetas:" -ForegroundColor Cyan
if (Test-Path $rustdeskAppData) {
    Get-ChildItem -Path $rustdeskAppData -Directory | ForEach-Object {
        Write-Host "   ✓ $_" -ForegroundColor Green
    }
}

# ============================================================
# 2. Buscar archivos de configuración
# ============================================================
Write-Host "`n`n[2] Buscando archivos de configuración..." -ForegroundColor Yellow

$configLocations = @(
    "$rustdeskAppData\config\RustDesk.toml",
    "$rustdeskAppData\config\rustdesk.toml",
    "$rustdeskAppData\config\config.toml",
    "$rustdeskAppData\RustDesk.toml",
    "$rustdeskAppData\config.toml",
    "$rustdeskAppData\config\*.toml",
    "$rustdeskAppData\*.toml"
)

foreach ($location in $configLocations) {
    if (Test-Path $location) {
        Write-Host "`n✅ Encontrado: $location" -ForegroundColor Green
        Write-Host "   Contenido:" -ForegroundColor Cyan
        Get-Content $location | ForEach-Object {
            Write-Host "   $_" -ForegroundColor Gray
        }
    }
}

# ============================================================
# 3. Buscar todos los archivos en la carpeta
# ============================================================
Write-Host "`n`n[3] Todos los archivos en AppData\RustDesk:" -ForegroundColor Yellow

if (Test-Path $rustdeskAppData) {
    Get-ChildItem -Path $rustdeskAppData -Recurse -File | ForEach-Object {
        Write-Host "   $($_.FullName)" -ForegroundColor Gray
    }
}

# ============================================================
# 4. Verificar registro de Windows
# ============================================================
Write-Host "`n`n[4] Buscando en Registro de Windows..." -ForegroundColor Yellow

$regPaths = @(
    "HKLM:\Software\RustDesk",
    "HKCU:\Software\RustDesk",
    "HKLM:\Software\WOW6432Node\RustDesk"
)

foreach ($regPath in $regPaths) {
    if (Test-Path $regPath) {
        Write-Host "`n✅ Encontrado: $regPath" -ForegroundColor Green
        Get-ItemProperty -Path $regPath | ForEach-Object {
            $_.PSObject.Properties | ForEach-Object {
                if ($_.Name -notlike "PS*") {
                    Write-Host "   $($_.Name) = $($_.Value)" -ForegroundColor Gray
                }
            }
        }
    }
}

# ============================================================
# 5. Buscar archivos de base de datos
# ============================================================
Write-Host "`n`n[5] Buscando bases de datos..." -ForegroundColor Yellow

$dbFiles = Get-ChildItem -Path $rustdeskAppData -Recurse -Include "*.db", "*.sqlite", "*.sqlite3" -ErrorAction SilentlyContinue

if ($dbFiles) {
    foreach ($file in $dbFiles) {
        Write-Host "`n✅ Base de datos: $($file.FullName)" -ForegroundColor Green
        Write-Host "   Tamaño: $($file.Length) bytes" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ No se encontraron bases de datos" -ForegroundColor Yellow
}

# ============================================================
# 6. Verificar procesos y archivos abiertos
# ============================================================
Write-Host "`n`n[6] Verificando proceso RustDesk..." -ForegroundColor Yellow

$rustdeskProc = Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue

if ($rustdeskProc) {
    Write-Host "✅ RustDesk está ejecutándose" -ForegroundColor Green
    Write-Host "   PID: $($rustdeskProc.Id)" -ForegroundColor Gray
    Write-Host "   Memoria: $($rustdeskProc.WorkingSet / 1MB) MB" -ForegroundColor Gray
} else {
    Write-Host "❌ RustDesk no está ejecutándose" -ForegroundColor Yellow
}

# ============================================================
# 7. Leer archivo de configuración si existe
# ============================================================
Write-Host "`n`n[7] Contenido del archivo TOML (si existe):" -ForegroundColor Yellow

$configFile = "$rustdeskAppData\config\RustDesk.toml"

if (Test-Path $configFile) {
    Write-Host "`n✅ Archivo encontrado: $configFile" -ForegroundColor Green
    Write-Host "`nContenido completo:" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────" -ForegroundColor Gray
    Get-Content $configFile | Write-Host -ForegroundColor White
    Write-Host "────────────────────────────────────────`n" -ForegroundColor Gray
} else {
    Write-Host "`n❌ Archivo NO encontrado: $configFile" -ForegroundColor Red
}

# ============================================================
# 8. Recomendaciones
# ============================================================
Write-Host "`n[8] Recomendaciones:" -ForegroundColor Yellow

Write-Host "`nSi el archivo TOML NO existe:" -ForegroundColor Yellow
Write-Host "  1. RustDesk no ha creado la carpeta config/" -ForegroundColor Gray
  Write-Host "  2. Intenta abrir RustDesk al menos una vez" -ForegroundColor Gray
Write-Host "  3. Luego ejecuta este diagnóstico nuevamente" -ForegroundColor Gray

Write-Host "`nSi el archivo TOML existe pero no tiene configuración:" -ForegroundColor Yellow
Write-Host "  1. RustDesk puede estar usando solo el registro" -ForegroundColor Gray
Write-Host "  2. O el formato TOML no es el correcto" -ForegroundColor Gray
Write-Host "  3. Intenta usar configure_registry.ps1" -ForegroundColor Gray

Write-Host "`nSi quieres actualizar manualmente:" -ForegroundColor Yellow
Write-Host "  1. Cierra RustDesk completamente" -ForegroundColor Gray
Write-Host "  2. Edita $configFile" -ForegroundColor Gray
Write-Host "  3. Abre RustDesk nuevamente" -ForegroundColor Gray

Write-Host "`n============================================================`n" -ForegroundColor Cyan
