# URLs y Comandos - RustDesk Installer

## 🚀 Comandos para Copiar y Pegar

### Opción 1: URL Larga (Directa de GitHub)

```powershell
irm https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1 | iex
```

**Cómo usar:**
1. Abre PowerShell como administrador (Windows + X)
2. Copia el comando anterior
3. Pégalo y presiona Enter
4. Espera 3-5 minutos

---

### Opción 2: URL Corta con bit.ly (RECOMENDADO)

```powershell
irm bit.ly/rustdesk-mariano | iex
```

**Cómo crear el acortador:**
1. Ve a https://bitly.com
2. Inicia sesión (crea cuenta si no tienes)
3. Pega esta URL en "Shorten your link":
   ```
   https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1
   ```
4. Bitly te genera un código corto (ej: `bit.ly/rustdesk-mariano`)
5. Usa ese código en el comando

**Ventajas:**
- ✅ Super corto
- ✅ Fácil de escribir y compartir
- ✅ Análisis de clics (bitly muestra cuántas personas lo usaron)
- ✅ Customizable (ej: `bit.ly/rustdesk-mariano`)

---

### Opción 3: URL con tu Dominio Propio (Si tienes)

Si tienes un dominio propio (ej: `tudominio.com`):

```powershell
irm tudominio.com/rustdesk | iex
```

**Cómo configurar:**
Configura un redirect en tu servidor web hacia:
```
https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1
```

---

## 🔗 URLs del Repositorio

| Recurso | URL |
|---------|-----|
| **Repositorio** | https://github.com/marianocappucci/rustdesk-installer |
| **Raw Script** | https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1 |
| **README** | https://github.com/marianocappucci/rustdesk-installer/blob/main/README.md |
| **Issues** | https://github.com/marianocappucci/rustdesk-installer/issues |

---

## 📋 Scripts Disponibles

### install_simple.ps1 (RECOMENDADO)
- Fácil de leer
- Rápido
- Perfecto para usuarios normales

```powershell
irm https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1 | iex
```

### install_rustdesk.ps1 (Completo)
- Más detalles y opciones
- Mejor para usuarios avanzados

```powershell
irm https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_rustdesk.ps1 | iex
```

### configure_rustdesk.ps1 (Reconfiguración)
- Para cambiar servidores después
- Sin necesidad de reinstalar

```powershell
irm https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/configure_rustdesk.ps1 | iex
```

---

## ⚙️ Configuración Incluida

Los scripts instalan RustDesk con esta configuración:

```
Servidor ID:     149.50.136.218
Servidor Relay:  149.50.136.218
Clave:           e0wsBkM2RcYOdy2mDeI82FogAgkhTQePyKXZlyGPr8g=
```

---

## 🎯 Mi Recomendación

**Para compartir con otros:**
```
Opción 1: "Usa este comando en PowerShell (como admin):

irm bit.ly/rustdesk-mariano | iex

O visita: github.com/marianocappucci/rustdesk-installer"
```

**Para documentación:**
```
github.com/marianocappucci/rustdesk-installer
```

**Para colaboradores/desarrolladores:**
```
git clone https://github.com/marianocappucci/rustdesk-installer.git
```

---

## 📊 Comparación de Métodos

| Método | URL | Ventajas | Desventajas |
|--------|-----|----------|-------------|
| **URL Larga** | `https://raw.github...` | Directo, sin intermediarios | Muy largo, difícil de escribir |
| **bit.ly** | `bit.ly/rustdesk-mariano` | Corto, personalizable, analytics | Depende de servicio tercero |
| **Dominio propio** | `tudominio.com/rustdesk` | Profesional, total control | Requiere dominio y servidor |

---

## 🔐 Seguridad

⚠️ **Importante:**

Cuando ejecutas:
```powershell
irm CUALQUIER_URL | iex
```

**Estás descargando y ejecutando código de Internet.** Esto es seguro SOLO si:
- ✅ Confías en la fuente
- ✅ Es código open-source que puedes revisar
- ✅ GitHub es una plataforma confiable

**En este caso:**
- ✅ Todo el código está en GitHub público
- ✅ Puedes revisar exactamente qué descarga
- ✅ No tiene malware ni código malicioso
- ✅ Es open-source bajo licencia MIT

---

## 📈 Estadísticas y Analítica

Si usas **bit.ly**, puedes ver:
- 📊 Cuántas personas usaron el enlace
- 📍 De dónde accedieron
- 🕐 Cuándo lo usaron
- 🔗 Redirecciones totales

Dashboard: https://bitly.com/your-links

---

## 🚀 Próximos Pasos

1. **Crear URL corta con bit.ly** (opcional pero recomendado)
2. **Compartir con usuarios:**
   ```
   irm bit.ly/rustdesk-mariano | iex
   ```

3. **Monitorear uso** (si usas bit.ly)

4. **Actualizar si hay cambios** en los scripts

---

## 📝 Ejemplo de Compartir

### Opción A: Simple
```
Para instalar RustDesk con servidor personalizado, ejecuta en PowerShell (como admin):

irm bit.ly/rustdesk-mariano | iex
```

### Opción B: Con más detalles
```
🚀 RustDesk Installer

Instala RustDesk con configuración automática en segundos.

Requisitos:
- Windows 10/11
- PowerShell (incluido)
- Acceso de administrador
- ~100 MB

Instalación:
1. Abre PowerShell como administrador
2. Ejecuta:
   irm bit.ly/rustdesk-mariano | iex
3. Espera 3-5 minutos

Más info: github.com/marianocappucci/rustdesk-installer
```

---

## 🆘 Soporte

Si encuentras problemas:

1. **Lee el README:**
   https://github.com/marianocappucci/rustdesk-installer#-solución-de-problemas

2. **Abre un issue:**
   https://github.com/marianocappucci/rustdesk-installer/issues

3. **Revisa los logs:**
   PowerShell mostrará dónde falla

---

## 🎁 Bonus: Crear tu Propio Acortador

### Con GitHub + Cloudflare (Gratis)

1. Configura un dominio personalizado en Cloudflare
2. Crea un redirect:
   ```
   URL: tudominio.com/rustdesk
   Target: https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1
   ```

3. Usa en tu comando:
   ```powershell
   irm tudominio.com/rustdesk | iex
   ```

**Ventajas:**
- Propio dominio
- Total control
- Gratis con Cloudflare

---

## ✅ Checklist Final

- [ ] Scripts están en GitHub
- [ ] README está actualizado
- [ ] URL raw funciona: `https://raw.githubusercontent.com/marianocappucci/rustdesk-installer/main/install_simple.ps1`
- [ ] Comando PowerShell funciona: `irm https://raw.github... | iex`
- [ ] bit.ly creado (opcional): `bit.ly/rustdesk-mariano`
- [ ] Listo para compartir

---

**Fecha**: 2026-04-29  
**Versión**: 1.0
