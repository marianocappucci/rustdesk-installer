# Problema: La Configuración de Servidor NO Carga

## 🔴 Síntoma Exacto

- Ejecutas el instalador
- RustDesk se abre
- Pero en **Configuración > Preferencias > Rojo (Opciones)** NO ves los servidores configurados

---

## 🔍 Diagnosticar el Problema

### Paso 1: Ejecutar Script de Diagnóstico

```powershell
.\diagnostico.ps1
```

Este script mostrará:
- ✓ Dónde RustDesk tiene los archivos
- ✓ Si existe el archivo TOML
- ✓ Dónde está guardada realmente la configuración
- ✓ Contenido del registro de Windows
- ✓ Bases de datos usadas por RustDesk

---

## 🔴 Problema Probable 1: Archivo TOML en Lugar Incorrecto

### Síntoma:
- El archivo TOML se crea pero RustDesk no lo lee

### Causa:
RustDesk podría buscar la configuración en un lugar diferente a:
```
%APPDATA%\RustDesk\config\RustDesk.toml
```

### Solución:

```powershell
# 1. Ejecuta el diagnóstico
.\diagnostico.ps1

# 2. Revisa TODAS las ubicaciones donde busca archivos

# 3. Si encuentras que RustDesk busca en otro lugar, 
#    copia el archivo allí:
Copy-Item "$env:APPDATA\RustDesk\config\RustDesk.toml" `
          "$env:APPDATA\RustDesk\config.toml"

# 4. Reinicia RustDesk
taskkill /IM rustdesk.exe /F
Start-Sleep -Seconds 3
C:\Users\$env:USERNAME\AppData\Roaming\RustDesk\rustdesk.exe
```

---

## 🔴 Problema Probable 2: RustDesk Usa Registro en Lugar de TOML

### Síntoma:
- El archivo TOML existe y tiene el contenido correcto
- Pero RustDesk no lo lee
- Es posible que use el registro de Windows

### Solución:

```powershell
# Intenta configurar usando el registro:
.\install_registry.ps1
```

Este script:
- ✓ Crea el archivo TOML
- ✓ También configura el registro de Windows
- ✓ Reintenta con ambos métodos

---

## 🔴 Problema Probable 3: Base de Datos SQLite

### Síntoma:
- RustDesk usa una base de datos SQLite en lugar de archivos TOML

### Investigación:

```powershell
# Ver si existe base de datos
Get-ChildItem "$env:APPDATA\RustDesk" -Recurse -Include "*.db", "*.sqlite"
```

Si encuentras un archivo como `rustdesk.db` o similar, RustDesk está usando una base de datos.

### Solución:

```powershell
# Limpiar la base de datos existente
Remove-Item "$env:APPDATA\RustDesk\rustdesk.db" -Force -ErrorAction SilentlyContinue

# Crear archivo TOML
# Reiniciar RustDesk para que recree la base de datos
taskkill /IM rustdesk.exe /F
Start-Sleep -Seconds 3
C:\Users\$env:USERNAME\AppData\Roaming\RustDesk\rustdesk.exe
```

---

## 🔴 Problema Probable 4: Configuración Guardada Localmente

### Síntoma:
- RustDesk guarda su configuración por usuario en la base de datos
- No lee archivo TOML porque ya tiene configuración guardada

### Solución - Opción A: Limpiar Completamente

```powershell
# 1. Cierra RustDesk
taskkill /IM rustdesk.exe /F

# 2. Borra TODA la carpeta de configuración
Remove-Item "$env:APPDATA\RustDesk" -Recurse -Force

# 3. Ejecuta el instalador
.\install_smart.ps1
```

### Solución - Opción B: Editar Manualmente

```powershell
# 1. Abre RustDesk
# 2. Ve a Configuración > Preferencias > Rojo
# 3. Busca los campos para servidor ID y servidor Relay
# 4. Ingresa manualmente:
#    Servidor ID: 149.50.136.218
#    Servidor Relay: 149.50.136.218
#    Clave: e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g=
# 5. Guarda la configuración
```

---

## 🔴 Problema Probable 5: Formato TOML Incorrecto

### Síntoma:
- El archivo TOML existe
- Pero tiene formato incorrecto
- RustDesk lo ignora silenciosamente

### Verificar:

```powershell
# Ver el archivo exacto
Get-Content "$env:APPDATA\RustDesk\config\RustDesk.toml" | Format-List

# Debe tener exactamente este formato:
# [network]
# relay-server = "149.50.136.218"
#
# [server]
# id = "149.50.136.218"
# key = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="
```

### Solución:

```powershell
# Crear archivo con formato correcto exacto

$content = @"
[network]
relay-server = "149.50.136.218"

[server]
id = "149.50.136.218"
key = "e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g="
"@

$content | Out-File -FilePath "$env:APPDATA\RustDesk\config\RustDesk.toml" -Encoding UTF8 -Force -NoNewline

# Reinicia RustDesk
taskkill /IM rustdesk.exe /F
Start-Sleep -Seconds 3
C:\Users\$env:USERNAME\AppData\Roaming\RustDesk\rustdesk.exe
```

---

## 🎯 Flujo de Troubleshooting Completo

### Paso 1: Diagnosticar
```powershell
.\diagnostico.ps1
```

### Paso 2: Revisar Salida
El diagnóstico te dirá:
- [ ] ¿Existe la carpeta `config`?
- [ ] ¿Existe el archivo TOML?
- [ ] ¿Cuál es el contenido?
- [ ] ¿Hay base de datos SQLite?
- [ ] ¿Qué hay en el registro?

### Paso 3: Aplicar Solución Según Diagnóstico

**Si NO existe archivo TOML:**
→ Ejecuta `.\install_smart.ps1` nuevamente

**Si existe archivo TOML pero no hay configuración:**
→ Verificar formato y ejecutar `.\configure_smart.ps1`

**Si existe pero RustDesk no lo lee:**
→ Intenta `.\install_registry.ps1`

**Si hay base de datos SQLite:**
→ Borra la BD y reinstala

**Si todo está correcto pero no aparece:**
→ Intenta configuración manual en la UI

---

## 🔧 Solución Nuclear (Última Opción)

Si nada funciona, limpia TODO y comienza de nuevo:

```powershell
# 1. Cierra RustDesk
taskkill /IM rustdesk.exe /F 2>$null

# 2. Espera
Start-Sleep -Seconds 3

# 3. Desinstala RustDesk
Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*RustDesk*"} | ForEach-Object {$_.Uninstall()}

# 4. Espera
Start-Sleep -Seconds 5

# 5. Borra carpeta de configuración
Remove-Item "$env:APPDATA\RustDesk" -Recurse -Force -ErrorAction SilentlyContinue

# 6. Borra carpeta temporal
Remove-Item "$env:TEMP\rustdesk_installer" -Recurse -Force -ErrorAction SilentlyContinue

# 7. Instala nuevo
.\install_smart.ps1
```

---

## 📊 Tabla de Métodos por Problema

| Problema | Método | Script |
|----------|--------|--------|
| No detecta instalación | Inteligente | `install_smart.ps1` |
| Usa archivo TOML | TOML | `configure_smart.ps1` |
| Usa registro | Registro | `install_registry.ps1` |
| Usa base de datos | BD + TOML | Limpiar + `install_smart.ps1` |
| Configuración local | Manual + UI | Editar en Preferencias |

---

## 🆘 Si Nada Funciona

### Contactar Soporte RustDesk:
- https://github.com/rustdesk/rustdesk/discussions
- https://docs.rustdesk.com

### Información Útil para Soporte:
```powershell
# Recopilar información
Write-Host "=== Información RustDesk ==="
Write-Host "Versión de Windows: $([System.Environment]::OSVersion.VersionString)"
Write-Host "Usuario: $env:USERNAME"
Write-Host "RustDesk AppData: $env:APPDATA\RustDesk"

# Ejecutar diagnóstico y guardar en archivo
.\diagnostico.ps1 | Out-File "diagnostico_output.txt"
Write-Host "Diagnóstico guardado en: diagnostico_output.txt"
```

---

## 📝 Resumen

La configuración personalizada en RustDesk es complicada porque:
1. ❓ RustDesk busca configuración en múltiples lugares
2. ❓ Puede usar archivos TOML O registro OR base de datos
3. ❓ La prioridad depende de la versión de RustDesk
4. ❓ Algunos valores se cachean localmente

**La mejor solución:** Ejecutar `diagnostico.ps1` primero, ver exactamente qué está pasando, y luego aplicar la solución correcta.

---

**Última actualización:** 2026-04-29
