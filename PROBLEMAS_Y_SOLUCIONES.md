# Problemas Conocidos y Soluciones

## ❌ Problema 1: Los Servidores No Aparecen en Preferencias

### Síntoma:
- Ejecutas el instalador
- RustDesk se abre pero no muestra los servidores configurados
- En Configuración > Preferencias no ves los datos del servidor

### Causa Raíz:
RustDesk no siempre lee el archivo TOML inmediatamente. Puede haber varios problemas:

1. **RustDesk no ha iniciado completamente**
   - El archivo se escribe antes de que RustDesk cree su estructura
   - RustDesk no recarga la configuración automáticamente

2. **Ubicación del archivo TOML**
   - El archivo debe estar en: `%APPDATA%\RustDesk\config\RustDesk.toml`
   - RustDesk busca configuración en múltiples lugares

3. **Formato del archivo TOML**
   - El formato debe ser exacto
   - Los espacios y saltos de línea importan

### Soluciones (en orden de efectividad):

#### ✅ Solución 1: Usar Script Mejorado (RECOMENDADO)
```powershell
# Ejecuta el nuevo script que maneja mejor la configuración:
.\install_smart.ps1

# O si ya está instalado, usa el configurador mejorado:
.\configure_smart.ps1
```

#### ✅ Solución 2: Forzar Reinicio de RustDesk
```powershell
# 1. Cierra RustDesk completamente
taskkill /IM rustdesk.exe /F

# 2. Espera 5 segundos
Start-Sleep -Seconds 5

# 3. Inicia RustDesk
C:\Users\$env:USERNAME\AppData\Roaming\RustDesk\rustdesk.exe
```

#### ✅ Solución 3: Editar Archivo Manualmente
```powershell
# 1. Abre el archivo de configuración:
Start-Process notepad "C:\Users\$env:USERNAME\AppData\Roaming\RustDesk\config\RustDesk.toml"

# 2. Verifica que contenga:
#    [network]
#    relay-server = "149.50.136.218"
#    [server]
#    id = "149.50.136.218"
#    key = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="

# 3. Guarda y cierra

# 4. Reinicia RustDesk
taskkill /IM rustdesk.exe /F
Start-Sleep -Seconds 3
C:\Users\$env:USERNAME\AppData\Roaming\RustDesk\rustdesk.exe
```

#### ✅ Solución 4: Limpiar y Reconfigura
```powershell
# 1. Cierra RustDesk
taskkill /IM rustdesk.exe /F

# 2. Borra la carpeta de configuración
Remove-Item "C:\Users\$env:USERNAME\AppData\Roaming\RustDesk\config" -Recurse -Force

# 3. Ejecuta el instalador nuevamente
.\install_smart.ps1
```

---

## ❌ Problema 2: El Instalador No Detecta RustDesk Existente

### Síntoma:
- Ya tienes RustDesk instalado
- Ejecutas el instalador
- Vuelve a descargar e instalar (innecesariamente)

### Causa:
El script original no verificaba correctamente si RustDesk estaba instalado.

### Solución:
Usa **`install_smart.ps1`** que detecta:
- ✓ Por archivo ejecutable (`rustdesk.exe`)
- ✓ Por entrada en el registro de Windows
- ✓ Por carpeta de configuración

```powershell
# El nuevo script es mucho más inteligente:
.\install_smart.ps1

# Si RustDesk ya está instalado:
# → Solo configura los servidores (2 minutos)
# 
# Si no está instalado:
# → Descarga, instala y configura (5-7 minutos)
```

---

## ❌ Problema 3: Ubicación de Configuración Incorrecta

### Ubicaciones donde RustDesk busca configuración:

```
C:\Users\[USERNAME]\AppData\Roaming\RustDesk\
├── config\
│   ├── RustDesk.toml           ← Archivo principal
│   ├── rustdesk.toml           ← Alternativo (minúsculas)
│   └── config.toml             ← Posible ubicación
├── rustdesk.exe                ← Ejecutable
├── data.db                     ← Base de datos
└── other files...
```

### Asegúrate de:
- ✓ Crear la carpeta `config` si no existe
- ✓ Usar nombre **`RustDesk.toml`** (con mayúsculas)
- ✓ Usar encoding UTF-8 sin BOM
- ✓ Espacios correctos en el TOML

---

## ❌ Problema 4: PowerShell Execution Policy

### Síntoma:
```
No se pueden ejecutar scripts en este sistema
```

### Solución:
```powershell
# Ejecuta ESTO en PowerShell (como admin):
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Presiona Y para confirmar

# Luego ejecuta tu script:
.\install_smart.ps1
```

---

## ✅ Solución Completa Paso a Paso

Si nada funciona, sigue esto exactamente:

### Paso 1: Limpiar completamente
```powershell
# Cierra RustDesk
taskkill /IM rustdesk.exe /F 2>$null

# Espera
Start-Sleep -Seconds 3

# Desinstala RustDesk
Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*RustDesk*"} | ForEach-Object {$_.Uninstall()}

# Borra la carpeta
Remove-Item "$env:APPDATA\RustDesk" -Recurse -Force -ErrorAction SilentlyContinue

# Borra la carpeta de descargas temporal
Remove-Item "$env:TEMP\rustdesk_installer" -Recurse -Force -ErrorAction SilentlyContinue
```

### Paso 2: Instalar nuevo
```powershell
# Abre PowerShell como admin
# Ejecuta:
.\install_smart.ps1
```

### Paso 3: Verificar configuración
```powershell
# Abre el archivo de configuración:
notepad "$env:APPDATA\RustDesk\config\RustDesk.toml"

# Debe contener:
# [network]
# relay-server = "149.50.136.218"
# [server]
# id = "149.50.136.218"
# key = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="
```

---

## 🔍 Como Debuggear

### Ver el contenido del archivo TOML:
```powershell
Get-Content "$env:APPDATA\RustDesk\config\RustDesk.toml"
```

### Ver si RustDesk está corriendo:
```powershell
Get-Process -Name "rustdesk"
```

### Ver logs de RustDesk (si existen):
```powershell
Get-ChildItem "$env:APPDATA\RustDesk" -Recurse -Include "*.log"
```

### Verificar que la carpeta existe:
```powershell
Test-Path "$env:APPDATA\RustDesk\config"
```

---

## 📝 Diferencias Entre Scripts

| Script | Detecta Instalación | Instala Si No Existe | Configura |
|--------|-------------------|-------------------|-----------|
| `install_simple.ps1` | ❌ No | ✅ Sí | ✅ Sí |
| **`install_smart.ps1`** | **✅ Sí** | **✅ Sí** | **✅ Sí** |
| `configure_rustdesk.ps1` | ❌ No | ❌ No | ✅ Sí |
| **`configure_smart.ps1`** | **✅ Sí** | **❌ No** | **✅ Sí** |

---

## 🎯 Recomendación

**Usa estos scripts en este orden:**

1. **Primera vez (cualquier caso):**
   ```powershell
   .\install_smart.ps1
   ```
   → Detecta si está instalado, si no → instala
   → Configura los servidores automáticamente

2. **Necesitas cambiar configuración después:**
   ```powershell
   .\configure_smart.ps1
   ```
   → Solo reconfigura, no reinstala

3. **Si algo falla:**
   ```powershell
   # Limpia y vuelve a intentar
   .\install_smart.ps1
   ```

---

## 🐛 Reportar Problemas

Si encuentras un problema no documentado:

1. Ejecuta el script con verbose:
   ```powershell
   # Copia el script a un archivo .ps1
   # Abre PowerShell ISE (editor)
   # Pega el script
   # Presiona F5 para ejecutar y ver detalles
   ```

2. Anota qué exactamente no funciona

3. Abre un issue en:
   ```
   https://github.com/marianocappucci/rustdesk-installer/issues
   ```

---

## 📚 Referencias

- **Documentación RustDesk:** https://docs.rustdesk.com
- **Formato TOML:** https://toml.io
- **PowerShell Docs:** https://docs.microsoft.com/powershell

---

**Última actualización:** 2026-04-29
