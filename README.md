# RustDesk Installer - Windows

Instalador automatizado para **RustDesk en Windows** con configuración personalizada de servidor (ID Server y Relay).

## 🚀 Instalación Rápida

### Opción 1: Comando One-Liner (RECOMENDADO)

```powershell
irm https://bit.ly/neuroflow_remoto | iex
```

**Pasos:**
1. Abre PowerShell como administrador (Windows + X)
2. Copia el comando anterior
3. Pégalo y presiona Enter
4. Espera 3-5 minutos
5. ¡Listo! RustDesk se instala automáticamente

### Opción 2: URL Larga (Alternativa)

```powershell
irm https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1 | iex
```

### Opción 2: Descarga y Ejecuta el Script

```powershell
# Abre PowerShell como administrador y ejecuta:
.\install_simple.ps1
```

---

## 📋 Requisitos

- **Windows 10 o 11** (recomendado)
- **PowerShell 3.0+** (incluido en Windows)
- **Acceso de administrador**
- **Conexión a Internet** (~100 MB para descargar RustDesk)

---

## 🎯 Configuración Incluida

| Parámetro | Valor |
|-----------|-------|
| **Servidor ID** | `149.50.136.218` |
| **Servidor Relay** | `149.50.136.218` |
| **Clave del Servidor** | `e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g=` |

---

## 📁 Scripts Disponibles

### `install_simple.ps1` 
**Recomendado para la mayoría de usuarios**
- Fácil de leer y entender
- Descarga la última versión de RustDesk
- Configura servidores automáticamente
- Inicia RustDesk al finalizar

```powershell
irm https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1 | iex
```

### `install_rustdesk.ps1`
**Script completo con opciones avanzadas**
- Información detallada de cada paso
- Mejor manejo de errores
- Interfaz con colores
- Opción `-SkipLaunch` para no iniciar RustDesk

```powershell
.\install_rustdesk.ps1
# O sin iniciar RustDesk:
.\install_rustdesk.ps1 -SkipLaunch
```

### `configure_rustdesk.ps1`
**Para reconfigurar después de instalar**
- Cambia servidores sin reinstalar
- Preserva la instalación existente

```powershell
.\configure_rustdesk.ps1
```

---

## ⚙️ ¿Qué hace el instalador?

1. ✅ **Descarga** la última versión de RustDesk desde GitHub
2. ✅ **Detiene** cualquier instancia anterior de RustDesk
3. ✅ **Instala** RustDesk mediante MSI (instalador oficial)
4. ✅ **Configura** servidores personalizados
5. ✅ **Inicia** RustDesk automáticamente
6. ✅ **Limpia** archivos temporales

---

## 🔧 Cómo Usar

### Método 1: PowerShell (Lo más fácil)

```bash
# Abre PowerShell como administrador
Windows + X → Windows PowerShell (Admin)

# Ejecuta el comando:
irm https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1 | iex

# O si prefieres bit.ly:
irm bit.ly/rustdesk-mariano | iex
```

### Método 2: Descargar y ejecutar

1. Descarga `install_simple.ps1`
2. Abre PowerShell como administrador
3. Navega a la carpeta:
   ```powershell
   cd "C:\ruta\donde\descargaste"
   ```
4. Ejecuta:
   ```powershell
   .\install_simple.ps1
   ```

### Método 3: Copiar y pegar el script

1. Abre `install_simple.ps1` en tu editor favorito
2. Copia TODO el contenido
3. Abre PowerShell como administrador
4. Pega el contenido y presiona Enter

---

## ✨ Características

- 🔄 **Actualizaciones automáticas** - Siempre descarga la última versión
- 🔐 **Seguro** - Código open-source, puedes revisar qué hace
- ⚡ **Rápido** - 3-5 minutos desde cero
- 🎯 **Automático** - Descarga, instala, configura y ejecuta
- 💾 **Sin basura** - Limpia archivos temporales después
- 🛡️ **Requiere admin** - Protege contra cambios no autorizados

---

## 🔗 URLs Disponibles

### URL Corta (bit.ly) - ⭐ RECOMENDADO
```
https://bit.ly/neuroflow_remoto
```

**Comando:**
```powershell
irm https://bit.ly/neuroflow_remoto | iex
```

### URL Larga (GitHub Raw)
```
https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1
```

**Comando:**
```powershell
irm https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1 | iex
```

### Ver Estadísticas
```
https://bit.ly/neuroflow_remoto+
```
(Agrega "+" al final para ver cuántas personas han usado el enlace)

---

## ❌ Solución de Problemas

### Error: "Execution Policy"
Si ves: `No se pueden ejecutar scripts en este sistema`

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

Presiona `Y` para confirmar, luego intenta nuevamente.

### RustDesk no inicia
- Espera 10-15 segundos después de que termine el script
- Abre RustDesk manualmente desde el menú Inicio
- Verifica que Windows Defender no lo bloqueó

### No se detectan los servidores
1. Reinicia RustDesk
2. Ve a Configuración > Preferencias
3. Verifica los servidores
4. Si persiste, ejecuta `configure_rustdesk.ps1`

### La descarga falla
- Comprueba tu conexión a Internet
- Verifica que GitHub no esté bloqueado
- Intenta nuevamente

---

## 🔒 Seguridad

- ✅ **Open-source** - Todo el código es visible
- ✅ **Descarga desde GitHub** - Fuente oficial y confiable
- ✅ **Sin dependencias externas** - Solo PowerShell nativo
- ✅ **Sin datos enviados** - Todo ocurre localmente
- ⚠️ **Requiere admin** - Necesario para instalar software

---

## 📚 Estructura del Repositorio

```
rustdesk-installer/
├── README.md                    # Este archivo
├── install_simple.ps1          # Script recomendado (legible)
├── install_rustdesk.ps1        # Script completo (opciones avanzadas)
├── configure_rustdesk.ps1      # Para reconfigurar después
├── RustDesk.toml               # Archivo de configuración de ejemplo
└── .gitignore                  # (será agregado)
```

---

## 🎯 Información de Servidores

Estos son los servidores que se configuran automáticamente:

```
ID Server:    149.50.136.218
Relay Server: 149.50.136.218
Server Key:   e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g=
```

La configuración se guarda en:
```
C:\Users\[TuUsuario]\AppData\Roaming\RustDesk\config\RustDesk.toml
```

---

## 🔄 Actualizar RustDesk

Para actualizar a una versión más nueva:

```powershell
# Simplemente ejecuta el instalador nuevamente
irm https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1 | iex
```

Tu configuración personalizada se preservará.

---

## 📝 Cambiar Servidores

Si necesitas cambiar los servidores después de instalar:

### Opción 1: Script automático
```powershell
.\configure_rustdesk.ps1
```

### Opción 2: Editar manualmente
1. Presiona `Windows + R`
2. Escribe: `%APPDATA%\RustDesk\config\RustDesk.toml`
3. Abre con tu editor favorito
4. Modifica los valores
5. Guarda y reinicia RustDesk

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Puedes:
- Reportar bugs
- Sugerir mejoras
- Mejorar la documentación
- Añadir nuevas características

---

## 📄 Licencia

Este proyecto está disponible bajo la licencia MIT.

---

## 🔗 Enlaces Útiles

- **RustDesk Oficial**: https://rustdesk.com
- **GitHub RustDesk**: https://github.com/rustdesk/rustdesk
- **Documentación**: https://docs.rustdesk.com
- **Foro de Soporte**: https://github.com/rustdesk/rustdesk/discussions

---

## 📧 Contacto

Para preguntas o problemas, abre un issue en este repositorio.

---

**Última actualización**: 2026-04-29  
**Versión**: 1.0  
**Autor**: Mariano Cappucci
