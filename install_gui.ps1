# ============================================================
# INSTALADOR RUSTDESK CON INTERFAZ GRÁFICA
# NeuroFlow — v2.0
# ============================================================
# Compilar como EXE (en PowerShell admin):
#   Import-Module PS2EXE
#   Invoke-PS2EXE -InputFile install_gui.ps1 -OutputFile instalar_rustdesk.exe `
#                 -requireAdmin -NoConsole -Title "Instalador RustDesk - NeuroFlow" `
#                 -Description "Instala y configura RustDesk automáticamente" `
#                 -Company "NeuroFlow" -Version "2.0.0.0"
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()

# ── Configuración del servidor ─────────────────────────────────────────────────
$CFG_ID_SERVER    = "149.50.136.218"
$CFG_RELAY_SERVER = "149.50.136.218"
$CFG_SERVER_KEY   = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="
$CFG_COMPANY      = "NeuroFlow"

# ── Paleta ────────────────────────────────────────────────────────────────────
$clrBlue   = [Drawing.Color]::FromArgb(0, 120, 215)
$clrOrange = [Drawing.Color]::FromArgb(224, 108, 10)
$clrGreen  = [Drawing.Color]::FromArgb(16, 160, 90)
$clrRed    = [Drawing.Color]::FromArgb(196, 43, 28)
$clrBg     = [Drawing.Color]::FromArgb(243, 243, 243)
$clrWhite  = [Drawing.Color]::White
$clrText   = [Drawing.Color]::FromArgb(28, 28, 28)
$clrMuted  = [Drawing.Color]::FromArgb(100, 100, 112)

# ── Fuentes ───────────────────────────────────────────────────────────────────
$fH1   = New-Object Drawing.Font("Segoe UI", 15, [Drawing.FontStyle]::Bold)
$fH2   = New-Object Drawing.Font("Segoe UI", 11, [Drawing.FontStyle]::Bold)
$fBody = New-Object Drawing.Font("Segoe UI", 10)
$fSm   = New-Object Drawing.Font("Segoe UI", 9)
$fBold = New-Object Drawing.Font("Segoe UI", 10, [Drawing.FontStyle]::Bold)
$fMono = New-Object Drawing.Font("Consolas", 9)
$fBig  = New-Object Drawing.Font("Segoe UI", 24, [Drawing.FontStyle]::Bold)

# ── Utilidades ────────────────────────────────────────────────────────────────
function New-Label {
    param($Text, $Font, $ForeColor, $X, $Y, $W = 0, $H = 0, $Align = "TopLeft")
    $l = New-Object Windows.Forms.Label
    $l.Text      = $Text
    $l.Font      = $Font
    $l.ForeColor = $ForeColor
    $l.Location  = New-Object Drawing.Point($X, $Y)
    if ($W -gt 0) { $l.Size = New-Object Drawing.Size($W, $H) } else { $l.AutoSize = $true }
    $l.TextAlign = $Align
    return $l
}

function Get-InstalledVersion {
    $keys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($k in $keys) {
        try {
            $e = Get-ItemProperty $k -EA SilentlyContinue |
                 Where-Object { $_.DisplayName -like "*RustDesk*" } |
                 Select-Object -First 1
            if ($e -and $e.DisplayVersion) { return $e.DisplayVersion }
        } catch {}
    }
    foreach ($p in @(
        "$env:ProgramFiles\RustDesk\rustdesk.exe",
        "${env:ProgramFiles(x86)}\RustDesk\rustdesk.exe",
        "$env:APPDATA\RustDesk\rustdesk.exe"
    )) {
        if (Test-Path $p) {
            $v = (Get-Item $p).VersionInfo.FileVersion
            if ($v) { return $v }
        }
    }
    return $null
}

# ── Formulario principal ───────────────────────────────────────────────────────
$form = New-Object Windows.Forms.Form
$form.Text            = "Soporte Remoto — $CFG_COMPANY"
$form.ClientSize      = New-Object Drawing.Size(520, 564)
$form.StartPosition   = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox     = $false
$form.MinimizeBox     = $false
$form.BackColor       = $clrBg
$form.Font            = $fBody
try { $form.Icon = [Drawing.SystemIcons]::Shield } catch {}

# ── Header azul ───────────────────────────────────────────────────────────────
$hdr = New-Object Windows.Forms.Panel
$hdr.Dock      = "Top"
$hdr.Height    = 72
$hdr.BackColor = $clrBlue

$hdr.Controls.Add((New-Label "Soporte Remoto — $CFG_COMPANY" $fH1 $clrWhite 18 10))
$hdr.Controls.Add((New-Label "Instalador de acceso remoto seguro"  $fSm  ([Drawing.Color]::FromArgb(190,225,255)) 20 47))
$form.Controls.Add($hdr)

# ── Contenedor de pantallas ───────────────────────────────────────────────────
$main = New-Object Windows.Forms.Panel
$main.Location = New-Object Drawing.Point(0, 72)
$main.Size     = New-Object Drawing.Size(520, 492)
$form.Controls.Add($main)

# ════════════════════════════════════════════════════════════════════════════════
# PANTALLA W — BIENVENIDA / AVISO
# ════════════════════════════════════════════════════════════════════════════════
$pW = New-Object Windows.Forms.Panel
$pW.Dock = "Fill"

# Bloque: ¿Qué se instalará?
$cardExp = New-Object Windows.Forms.Panel
$cardExp.Location    = New-Object Drawing.Point(14, 12)
$cardExp.Size        = New-Object Drawing.Size(492, 82)
$cardExp.BackColor   = $clrWhite
$cardExp.BorderStyle = "FixedSingle"
$cardExp.Controls.Add((New-Label "¿Qué se instalará?" $fH2 $clrText 12 10))
$lExpBody = New-Object Windows.Forms.Label
$lExpBody.Text     = "RustDesk es una herramienta de acceso remoto que permite a técnicos de $CFG_COMPANY conectarse a tu computadora para brindarte soporte técnico de forma segura."
$lExpBody.Font     = $fBody
$lExpBody.ForeColor = $clrText
$lExpBody.Location = New-Object Drawing.Point(12, 35)
$lExpBody.Size     = New-Object Drawing.Size(466, 38)
$cardExp.Controls.Add($lExpBody)

# Bloque: ¿Qué hará exactamente?
$cardDo = New-Object Windows.Forms.Panel
$cardDo.Location    = New-Object Drawing.Point(14, 103)
$cardDo.Size        = New-Object Drawing.Size(492, 90)
$cardDo.BackColor   = [Drawing.Color]::FromArgb(240, 248, 255)
$cardDo.BorderStyle = "FixedSingle"
$cardDo.Controls.Add((New-Label "¿Qué hará este instalador?" $fBold $clrText 12 10))
$lDoBody = New-Object Windows.Forms.Label
$lDoBody.Text     = "  •  Descargará RustDesk (~90 MB) directamente de su sitio oficial`n  •  Lo instalará y configurará automáticamente`n  •  No envía ninguna información personal"
$lDoBody.Font     = $fSm
$lDoBody.ForeColor = $clrMuted
$lDoBody.Location = New-Object Drawing.Point(12, 32)
$lDoBody.Size     = New-Object Drawing.Size(466, 50)
$cardDo.Controls.Add($lDoBody)

# Bloque: Aviso de seguridad
$cardWarn = New-Object Windows.Forms.Panel
$cardWarn.Location    = New-Object Drawing.Point(14, 202)
$cardWarn.Size        = New-Object Drawing.Size(492, 122)
$cardWarn.BackColor   = [Drawing.Color]::FromArgb(255, 248, 228)
$cardWarn.BorderStyle = "FixedSingle"

$lWTitle = New-Object Windows.Forms.Label
$lWTitle.Text      = "⚠   AVISO DE SEGURIDAD"
$lWTitle.Font      = New-Object Drawing.Font("Segoe UI", 10, [Drawing.FontStyle]::Bold)
$lWTitle.ForeColor = $clrOrange
$lWTitle.Location  = New-Object Drawing.Point(12, 10)
$lWTitle.AutoSize  = $true
$cardWarn.Controls.Add($lWTitle)

$lWBody = New-Object Windows.Forms.Label
$lWBody.Text = "Las herramientas de acceso remoto pueden ser usadas de forma maliciosa por personas que se hacen pasar por técnicos.`n`nSolo instalá este programa si un técnico de $CFG_COMPANY te lo pidió. Si nadie te lo solicitó o recibiste este archivo de forma inesperada, hacé clic en Cancelar."
$lWBody.Font      = $fSm
$lWBody.ForeColor = [Drawing.Color]::FromArgb(110, 68, 0)
$lWBody.Location  = New-Object Drawing.Point(12, 34)
$lWBody.Size      = New-Object Drawing.Size(466, 82)
$cardWarn.Controls.Add($lWBody)

# Separador
$sep = New-Object Windows.Forms.Label
$sep.BorderStyle = "Fixed3D"
$sep.Height = 2; $sep.Width = 490
$sep.Location = New-Object Drawing.Point(14, 334)

# Checkbox de confirmación
$chk = New-Object Windows.Forms.CheckBox
$chk.Text     = "Un técnico de $CFG_COMPANY me pidió instalar este programa"
$chk.Font     = $fBold
$chk.Location = New-Object Drawing.Point(14, 344)
$chk.Size     = New-Object Drawing.Size(492, 28)

# Etiqueta de versión detectada
$lVer = New-Label "Verificando versión instalada..." $fSm $clrMuted 14 382 492 22

# Botones
$btnCnl = New-Object Windows.Forms.Button
$btnCnl.Text      = "Cancelar"
$btnCnl.Location  = New-Object Drawing.Point(14, 444)
$btnCnl.Size      = New-Object Drawing.Size(110, 38)
$btnCnl.FlatStyle = "Flat"
$btnCnl.BackColor = $clrWhite
$btnCnl.ForeColor = $clrText
$btnCnl.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(180, 180, 180)

$btnInst = New-Object Windows.Forms.Button
$btnInst.Text      = "Instalar"
$btnInst.Location  = New-Object Drawing.Point(396, 444)
$btnInst.Size      = New-Object Drawing.Size(110, 38)
$btnInst.FlatStyle = "Flat"
$btnInst.BackColor = [Drawing.Color]::FromArgb(160, 160, 160)
$btnInst.ForeColor = $clrWhite
$btnInst.Enabled   = $false
$btnInst.Font      = $fBold

$pW.Controls.AddRange(@($cardExp, $cardDo, $cardWarn, $sep, $chk, $lVer, $btnCnl, $btnInst))

# ════════════════════════════════════════════════════════════════════════════════
# PANTALLA P — PROGRESO
# ════════════════════════════════════════════════════════════════════════════════
$pP = New-Object Windows.Forms.Panel
$pP.Dock    = "Fill"
$pP.Visible = $false

$lPStep = New-Label "" $fH2 $clrText 14 16 492 28
$lPDet  = New-Label "" $fSm $clrMuted 14 48 492 20

$progBar = New-Object Windows.Forms.ProgressBar
$progBar.Location = New-Object Drawing.Point(14, 74)
$progBar.Size     = New-Object Drawing.Size(492, 24)
$progBar.Style    = "Continuous"
$progBar.Minimum  = 0
$progBar.Maximum  = 100

$lPct = New-Label "0%" $fSm $clrMuted 14 102 60 20

$logBox = New-Object Windows.Forms.ListBox
$logBox.Location            = New-Object Drawing.Point(14, 128)
$logBox.Size                = New-Object Drawing.Size(492, 290)
$logBox.Font                = $fMono
$logBox.BorderStyle         = "FixedSingle"
$logBox.SelectionMode       = "None"
$logBox.HorizontalScrollbar = $true
$logBox.BackColor           = [Drawing.Color]::FromArgb(14, 14, 22)
$logBox.ForeColor           = [Drawing.Color]::FromArgb(155, 255, 155)

$pP.Controls.AddRange(@($lPStep, $lPDet, $progBar, $lPct, $logBox))

# ════════════════════════════════════════════════════════════════════════════════
# PANTALLA R — RESULTADO
# ════════════════════════════════════════════════════════════════════════════════
$pR = New-Object Windows.Forms.Panel
$pR.Dock    = "Fill"
$pR.Visible = $false

$lRIcon  = New-Label "✓" (New-Object Drawing.Font("Segoe UI", 52)) $clrGreen 196 14 0 0
$lRTitle = New-Label "¡Instalación completada!" $fH1 $clrText 14 114 492 34 "MiddleCenter"
$lRMsg   = New-Label "RustDesk fue instalado y configurado correctamente." $fBody $clrMuted 14 154 492 24 "MiddleCenter"

$pnlId = New-Object Windows.Forms.Panel
$pnlId.Location    = New-Object Drawing.Point(80, 192)
$pnlId.Size        = New-Object Drawing.Size(360, 92)
$pnlId.BackColor   = [Drawing.Color]::FromArgb(232, 244, 255)
$pnlId.BorderStyle = "FixedSingle"
$lIdTitle = New-Label "Tu ID de RustDesk:" $fSm $clrMuted 0 8 360 22 "MiddleCenter"
$lId      = New-Label "—" $fBig $clrBlue 0 30 360 50 "MiddleCenter"
$pnlId.Controls.AddRange(@($lIdTitle, $lId))

$lRInstr = New-Label "Comunicá este número a tu técnico de $CFG_COMPANY para que pueda conectarse." $fSm $clrMuted 14 296 492 22 "MiddleCenter"

$btnClose = New-Object Windows.Forms.Button
$btnClose.Text      = "Cerrar"
$btnClose.Location  = New-Object Drawing.Point(190, 436)
$btnClose.Size      = New-Object Drawing.Size(140, 40)
$btnClose.FlatStyle = "Flat"
$btnClose.BackColor = $clrGreen
$btnClose.ForeColor = $clrWhite
$btnClose.Font      = $fBold

$pR.Controls.AddRange(@($lRIcon, $lRTitle, $lRMsg, $pnlId, $lRInstr, $btnClose))

$main.Controls.AddRange(@($pW, $pP, $pR))

# ── Estado del instalador en script scope (Add_Tick no ve variables de Add_Click)
$script:_sh      = $null
$script:_bgTimer = $null
$script:_ps      = $null
$script:_rs      = $null
$script:_handle  = $null
$script:_bBack   = $null

# ── Helpers de navegación ─────────────────────────────────────────────────────
function Show-Screen ([string]$s) {
    $pW.Visible = $s -eq "W"
    $pP.Visible = $s -eq "P"
    $pR.Visible = $s -eq "R"
}

# ── Eventos — Pantalla W ──────────────────────────────────────────────────────
$chk.Add_CheckedChanged({
    $btnInst.Enabled   = $chk.Checked
    $btnInst.BackColor = if ($chk.Checked) { $clrBlue } else { [Drawing.Color]::FromArgb(160,160,160) }
})

$btnCnl.Add_Click({ $form.Close() })
$btnClose.Add_Click({ $form.Close() })

$script:installedVer = $null
$form.Add_Shown({
    $script:installedVer = Get-InstalledVersion
    if ($script:installedVer) {
        $lVer.Text      = "RustDesk $($script:installedVer) ya está instalado — se actualizará a la última versión."
        $lVer.ForeColor = [Drawing.Color]::FromArgb(0, 128, 0)
        $btnInst.Text   = "Actualizar"
    } else {
        $lVer.Text      = "RustDesk no está instalado — se descargará la última versión disponible."
        $lVer.ForeColor = $clrMuted
    }
})

# ── Lógica de instalación ─────────────────────────────────────────────────────
$btnInst.Add_Click({
    Show-Screen "P"
    $form.Refresh()

    # Estado compartido — en $script: para que Add_Tick lo pueda leer
    $script:_sh = [hashtable]::Synchronized(@{
        Pct     = 0
        Step    = "Iniciando..."
        Detail  = ""
        LogQ    = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
        Done    = $false
        Success = $false
        Err     = ""
        RdId    = ""
    })

    $cfgIdSrv    = $CFG_ID_SERVER
    $cfgRelaySrv = $CFG_RELAY_SERVER
    $cfgKey      = $CFG_SERVER_KEY

    $script:_rs = [runspacefactory]::CreateRunspace()
    $script:_rs.ApartmentState = "MTA"
    $script:_rs.ThreadOptions  = "ReuseThread"
    $script:_rs.Open()
    $script:_rs.SessionStateProxy.SetVariable("sh",          $script:_sh)
    $script:_rs.SessionStateProxy.SetVariable("cfgIdSrv",    $cfgIdSrv)
    $script:_rs.SessionStateProxy.SetVariable("cfgRelaySrv", $cfgRelaySrv)
    $script:_rs.SessionStateProxy.SetVariable("cfgKey",      $cfgKey)

    $script:_ps = [powershell]::Create()
    $script:_ps.Runspace = $script:_rs
    [void]$script:_ps.AddScript({
        function L { param($m) [void]$sh.LogQ.Enqueue($m) }
        function S { param($step, $det = "") $sh.Step = $step; $sh.Detail = $det }
        function P { param($p) $sh.Pct = $p }

        try {
            # ── 1. Buscar última versión ───────────────────────────────────
            S "[1/5] Buscando última versión de RustDesk..."
            P 4
            L "Consultando GitHub API..."

            $rel = Invoke-RestMethod `
                -Uri "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" `
                -Headers @{ "User-Agent" = "NF-RustDesk-Installer/2.0"; "Accept" = "application/vnd.github.v3+json" } `
                -UseBasicParsing -TimeoutSec 30

            # Preferir MSI x86_64, luego cualquier MSI
            $asset = $rel.assets | Where-Object { $_.name -match "x86_64.*\.msi$" } | Select-Object -First 1
            if (-not $asset) { $asset = $rel.assets | Where-Object { $_.name -match "\.msi$" } | Select-Object -First 1 }
            if (-not $asset) { throw "No se encontró el instalador MSI en el release de GitHub." }

            $dlUrl      = $asset.browser_download_url
            $version    = $rel.tag_name
            $totalBytes = [long]$asset.size

            L "Versión disponible  : $version"
            L "Tamaño del archivo  : $([Math]::Round($totalBytes / 1MB, 1)) MB"
            L "URL                 : $dlUrl"
            P 10

            # ── 2. Descargar con progreso real por stream ──────────────────
            S "[2/5] Descargando RustDesk $version..."
            S "[2/5] Descargando RustDesk $version..." "Conectando..."
            L "Iniciando descarga..."

            $dlDir   = "$env:TEMP\rd_setup_$([guid]::NewGuid().ToString('N').Substring(0,6))"
            $msiPath = "$dlDir\rustdesk.msi"
            New-Item -ItemType Directory -Path $dlDir -Force | Out-Null

            Add-Type -AssemblyName System.Net.Http
            $http = New-Object System.Net.Http.HttpClient
            $http.DefaultRequestHeaders.Add("User-Agent", "NF-RustDesk-Installer/2.0")
            $http.Timeout = [TimeSpan]::FromMinutes(15)

            $resp = $http.GetAsync($dlUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
            if (-not $resp.IsSuccessStatusCode) {
                throw "Error HTTP $([int]$resp.StatusCode) al descargar el instalador."
            }

            $netStream  = $resp.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
            $fileStream = [IO.File]::OpenWrite($msiPath)
            $buf        = New-Object byte[] 65536
            $downloaded = [long]0
            $lastLogMB  = [long]0

            while ($true) {
                $n = $netStream.Read($buf, 0, $buf.Length)
                if ($n -eq 0) { break }
                $fileStream.Write($buf, 0, $n)
                $downloaded += $n

                if ($totalBytes -gt 0) {
                    $pct        = [Math]::Min(99, [int]($downloaded * 100 / $totalBytes))
                    $sh.Pct    = 10 + [int]($pct * 0.37)   # mapea 0-100% → 10-47%
                    $dlMB      = [Math]::Round($downloaded / 1MB, 1)
                    $totMB     = [Math]::Round($totalBytes / 1MB, 1)
                    $sh.Detail = "$dlMB MB de $totMB MB  ($pct%)"
                    # Log cada ~10 MB
                    if (($downloaded - $lastLogMB) -ge 10MB) {
                        $lastLogMB = $downloaded
                        L "  Descargado: $dlMB / $totMB MB"
                    }
                }
            }

            $fileStream.Close()
            $netStream.Close()
            $http.Dispose()

            $sizeMB = [Math]::Round((Get-Item $msiPath).Length / 1MB, 1)
            if ((Get-Item $msiPath).Length -lt 5MB) {
                throw "El archivo descargado parece incompleto ($sizeMB MB)."
            }
            L "Descarga completa: $sizeMB MB"
            P 50
            S "[2/5] Descarga completa" "$sizeMB MB"

            # ── 3. Detener y desinstalar versión anterior ──────────────────
            S "[3/5] Preparando instalación..."
            P 52
            L "Cerrando proceso rustdesk..."
            Get-Process "rustdesk" -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
            Start-Sleep -Seconds 2

            # Desinstalar versión previa para evitar error MSI 1603 en upgrades
            $uninstKeys = @(
                "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )
            $prevPkg = $null
            foreach ($k in $uninstKeys) {
                $prevPkg = Get-ItemProperty $k -EA SilentlyContinue |
                    Where-Object { $_.DisplayName -like "*RustDesk*" } |
                    Select-Object -First 1
                if ($prevPkg) { break }
            }

            if ($prevPkg) {
                L "Versión anterior detectada: $($prevPkg.DisplayVersion) — desinstalando..."
                $prodCode = [regex]::Match($prevPkg.UninstallString, '\{[A-F0-9-]{36}\}').Value
                if ($prodCode) {
                    $u = Start-Process msiexec.exe `
                        -ArgumentList "/x `"$prodCode`" /quiet /norestart" `
                        -Wait -PassThru
                    L "Desinstalación completada (código: $($u.ExitCode))."
                } else {
                    L "  (No se pudo extraer el producto — se intentará upgrade directo)"
                }
                Start-Sleep -Seconds 3
            } else {
                L "No hay versión anterior instalada."
            }
            P 56

            # ── 4. Instalar MSI ────────────────────────────────────────────
            S "[4/5] Instalando RustDesk $version..." "Puede tardar 1–3 minutos, no cierres esta ventana..."
            P 58
            L "Ejecutando instalador MSI (modo silencioso)..."

            $msiLog  = "$env:TEMP\rustdesk_install.log"
            $proc = Start-Process msiexec.exe `
                -ArgumentList "/i `"$msiPath`" /quiet /norestart /l*v `"$msiLog`"" `
                -Wait -PassThru

            # 0 = éxito, 1641/3010 = éxito + reinicio requerido
            if ($proc.ExitCode -notin @(0, 1641, 3010)) {
                # Mostrar las últimas líneas del log MSI para diagnóstico
                if (Test-Path $msiLog) {
                    $tail = Get-Content $msiLog -Tail 8 -EA SilentlyContinue |
                        Where-Object { $_ -match "error|value 3|return value" } |
                        Select-Object -Last 3
                    foreach ($tl in $tail) { L "  MSI: $tl" }
                }
                throw "El instalador MSI falló con código $($proc.ExitCode)."
            }
            L "Instalación correcta (código: $($proc.ExitCode))."
            Remove-Item $msiLog -EA SilentlyContinue
            P 82

            # ── 5. Configurar servidor ─────────────────────────────────────
            S "[5/5] Configurando servidor de $cfgIdSrv..."
            P 85
            L "Escribiendo configuración..."

            # Detener nuevamente por si el MSI lo inició al finalizar
            Get-Process "rustdesk" -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
            Start-Sleep -Seconds 1

            $cfgDir  = "$env:APPDATA\RustDesk\config"
            $cfgFile = "$cfgDir\RustDesk.toml"
            if (-not (Test-Path $cfgDir)) { New-Item -ItemType Directory $cfgDir -Force | Out-Null }

            # Escribir TOML sin BOM (UTF-8 puro)
            $toml = "[network]`nrelay-server = `"$cfgRelaySrv`"`n`n[server]`nid = `"$cfgIdSrv`"`nkey = `"$cfgKey`""
            [IO.File]::WriteAllText($cfgFile, $toml, (New-Object Text.UTF8Encoding $false))
            L "TOML escrito en: $cfgFile"

            # Redundancia: también configurar registro de Windows
            try {
                $rk = "HKCU:\Software\RustDesk"
                if (-not (Test-Path $rk)) { New-Item $rk -Force | Out-Null }
                Set-ItemProperty $rk "relay-server" $cfgRelaySrv -EA Stop
                Set-ItemProperty $rk "id-server"    $cfgIdSrv    -EA Stop
                Set-ItemProperty $rk "key"           $cfgKey      -EA Stop
                L "Registro HKCU:\Software\RustDesk configurado."
            } catch {
                L "  (Registro: omitido — OK)"
            }

            P 93
            L "Limpiando temporales..."
            Remove-Item $dlDir -Recurse -Force -EA SilentlyContinue

            # ── Iniciar RustDesk y leer ID ─────────────────────────────────
            L "Iniciando RustDesk..."
            $exe = @(
                "$env:ProgramFiles\RustDesk\rustdesk.exe",
                "${env:ProgramFiles(x86)}\RustDesk\rustdesk.exe",
                "$env:LOCALAPPDATA\RustDesk\rustdesk.exe",
                "$env:APPDATA\RustDesk\rustdesk.exe"
            ) | Where-Object { Test-Path $_ } | Select-Object -First 1

            if ($exe) {
                Start-Process $exe -EA SilentlyContinue
                L "RustDesk iniciado. Esperando conexión con servidor para obtener ID..."

                # Archivos de config donde RustDesk puede guardar el ID (varía por versión)
                $cfgFiles = @(
                    $cfgFile,
                    ($cfgFile -replace 'RustDesk\.toml$', 'RustDesk2.toml')
                )

                $deadline = (Get-Date).AddSeconds(30)
                while ((Get-Date) -lt $deadline -and -not $sh.RdId) {
                    Start-Sleep -Milliseconds 1200

                    # Método 1: rustdesk --get-id (v1.2+, más confiable)
                    try {
                        $tmpId = "$env:TEMP\rdid_out.txt"
                        $gp = Start-Process $exe -ArgumentList "--get-id" `
                            -Wait -PassThru -WindowStyle Hidden `
                            -RedirectStandardOutput $tmpId -EA SilentlyContinue
                        if (Test-Path $tmpId) {
                            $cliOut = (Get-Content $tmpId -Raw -EA SilentlyContinue).Trim()
                            Remove-Item $tmpId -EA SilentlyContinue
                            if ($cliOut -match '^\d{6,12}$') {
                                $sh.RdId = $cliOut
                                L "ID obtenido (CLI): $($sh.RdId)"
                            }
                        }
                    } catch {}

                    if ($sh.RdId) { break }

                    # Método 2: leer de los archivos de config
                    foreach ($cf in $cfgFiles) {
                        if (-not (Test-Path $cf)) { continue }
                        try {
                            $raw = [IO.File]::ReadAllText($cf)
                            # Buscar ID numérico entre comillas (excluye IPs con puntos)
                            foreach ($m in [regex]::Matches($raw, '"(\d{6,12})"')) {
                                $sh.RdId = $m.Groups[1].Value
                                L "ID obtenido (config): $($sh.RdId)"
                                break
                            }
                        } catch {}
                        if ($sh.RdId) { break }
                    }
                }

                if (-not $sh.RdId) {
                    L "  (El ID aparecerá en la app de RustDesk al conectarse al servidor)"
                }
            } else {
                L "! rustdesk.exe no encontrado — inicialo desde el menú Inicio."
            }

            P 100
            S "¡Completado!" "RustDesk $version instalado y listo para usar."
            L "─────────────────── COMPLETADO ───────────────────"
            $sh.Success = $true

        } catch {
            $sh.Err = $_.Exception.Message
            L "ERROR: $($_.Exception.Message)"
        } finally {
            $sh.Done = $true
        }
    })

    $script:_handle = $script:_ps.BeginInvoke()

    # Timer UI: lee $script:_sh y actualiza controles cada 100 ms
    $script:_bgTimer = New-Object Windows.Forms.Timer
    $script:_bgTimer.Interval = 100
    $script:_bgTimer.Add_Tick({
        try {
            $progBar.Value = [Math]::Min($script:_sh.Pct, 100)
            $lPct.Text     = "$($script:_sh.Pct)%"
            $lPStep.Text   = $script:_sh.Step
            $lPDet.Text    = $script:_sh.Detail

            # TryDequeue con variable local en este scope
            $line = $null
            while ($script:_sh.LogQ.TryDequeue([ref]$line)) {
                [void]$logBox.Items.Add([string]$line)
                $logBox.TopIndex = $logBox.Items.Count - 1
                $line = $null
            }

            if (-not $script:_sh.Done) { return }

            $script:_bgTimer.Stop()
            try { $script:_ps.EndInvoke($script:_handle) } catch {}
            $script:_ps.Dispose()
            $script:_rs.Close()

            if ($script:_sh.Success) {
                if ($script:_sh.RdId) {
                    $lId.Text = $script:_sh.RdId
                    $lId.Font = $fBig
                } else {
                    $lId.Text = "(Abrí RustDesk para ver tu ID)"
                    $lId.Font = $fBody
                }
                Show-Screen "R"
            } else {
                $lPStep.Text      = "Error durante la instalación"
                $lPStep.ForeColor = $clrRed
                $lPDet.Text       = $script:_sh.Err

                $script:_bBack = New-Object Windows.Forms.Button
                $script:_bBack.Text      = "← Volver"
                $script:_bBack.Location  = New-Object Drawing.Point(190, 450)
                $script:_bBack.Size      = New-Object Drawing.Size(140, 36)
                $script:_bBack.FlatStyle = "Flat"
                $script:_bBack.BackColor = $clrOrange
                $script:_bBack.ForeColor = $clrWhite
                $script:_bBack.Font      = $fBold
                $script:_bBack.Add_Click({
                    $pP.Controls.Remove($script:_bBack)
                    $lPStep.ForeColor = $clrText
                    $lPStep.Text  = ""
                    $lPDet.Text   = ""
                    [void]$logBox.Items.Clear()
                    $progBar.Value = 0; $lPct.Text = "0%"
                    Show-Screen "W"
                })
                $pP.Controls.Add($script:_bBack)
                $script:_bBack.BringToFront()
            }
        } catch {
            $script:_bgTimer.Stop()
            [Windows.Forms.MessageBox]::Show(
                "Error inesperado en el instalador:`n$_",
                "Error",
                [Windows.Forms.MessageBoxButtons]::OK,
                [Windows.Forms.MessageBoxIcon]::Error
            ) | Out-Null
        }
    })
    $script:_bgTimer.Start()
})

# ── Cleanup al cerrar ─────────────────────────────────────────────────────────
$form.Add_FormClosed({
    if ($script:_bgTimer -and $script:_bgTimer.Enabled) { $script:_bgTimer.Stop() }
    if ($script:_ps)  { try { $script:_ps.Dispose()  } catch {} }
    if ($script:_rs)  { try { $script:_rs.Close()    } catch {} }
})

# ── Lanzar ────────────────────────────────────────────────────────────────────
[Windows.Forms.Application]::Run($form)
