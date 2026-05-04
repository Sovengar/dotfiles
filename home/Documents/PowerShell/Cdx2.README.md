# Cdx vs Cdx2 — Comparativa y Documentación

## cdx (original)

### Qué hace
- Navegador de directorios **local** (solo el directorio actual)
- Lista carpetas con `Get-ChildItem` y las pasa a `fzf`
- Preview: usa `cmd /c` para ejecutar `bat` o `dir /b` (con fallback a PowerShell)
- Navegación con Enter (cd) y Esc (aborta, vuelve a shell)
- `Ctrl+H` → vuelve a `~` (home) vía `become`

### Dependencias
- `fzf`
- `zoxide` (para fallback de queries)
- `bat` (opcional, para preview)
- `eza` (NO lo usa)
- `fd` (NO lo usa)
- `rg` (solo para `-s` / búsqueda de contenido)

### Parámetros
- `cdx <path>` → `cd` directo si existe
- `cdx <query>` → busca en zoxide (`zoxide query`)
- `cdx -s <query>` → búsqueda de contenido con `rg` en todo el disco (delegado a `Invoke-CdxSearch`)

---

## cdx2 (nuevo)

### Qué hace
- Navegador de directorios **recursivo** con `fd` (desde el directorio actual hacia abajo)
- Integración con **zoxide**: cachea la lista de dirs frecuentes al arrancar, muestra con `★` prefix
- Preview de directorios con `eza` (si está instalado) o `Get-ChildItem`
- Preview de archivos con `bat` (si está instalado) o `Get-Content`
- **Doble Esc** → vuelve al directorio donde se inició `cdx2` y sale
- **Ctrl+A** → toggle para mostrar/ocultar directorios ocultos
- **Ctrl+R** → toggle visual para "search inside files" (placeholder, no implementado funcionalmente)
- **Ctrl+H** → vuelve a `~` (home) vía `become`
- Paths relativos: no muestra el cwd repetido en cada línea
- Usa scripts temporales para toggles y preview (evita problemas de quoting de `cmd.exe`)

### Dependencias
- `fzf`
- `fd` (obligatorio, para búsqueda recursiva)
- `zoxide` (opcional, para `★` prefix y fallback de queries)
- `bat` (opcional, para preview de archivos)
- `eza` (opcional, para preview de directorios y salida final)
- `rg` (solo para `-s`, delegado a `Invoke-CdxSearch` de `Cdx.ps1`)

### Parámetros
- `cdx2` → abre navegador recursivo desde cwd
- `cdx2 <path>` → `cd` directo si existe
- `cdx2 <query>` → busca en zoxide (`zoxide query`)
- `cdx2 -s <query>` → búsqueda de contenido con `rg` (delegado a `Invoke-CdxSearch`)

---

## Tabla Comparativa

| Característica | cdx | cdx2 |
|---|---|---|
| **Búsqueda de dirs** | Local (Get-ChildItem) | Recursiva (fd) |
| **Zoxide** | Fallback en queries | Cache + `★` prefix visual |
| **Preview dirs** | `dir /b` o `bat` | `eza` o `Get-ChildItem` |
| **Preview archivos** | `bat` | `bat` |
| **Doble Esc** | ❌ No | ✅ Vuelve al dir original |
| **Ctrl+H (home)** | ✅ | ✅ |
| **Ctrl+A (hidden)** | ❌ No | ✅ Toggle |
| **Ctrl+R (rg mode)** | ❌ No | 🟡 Label visual |
| **Paths mostrados** | Absolutos/relativos | Relativos al cwd |
| **Salida al salir** | `Get-ChildItem` | `eza` (si está) |
| **Velocidad** | Instantáneo | Casi instantáneo (cache zoxide) |
| **Búsqueda de contenido (`-s`)** | ✅ `Invoke-CdxSearch` | ✅ Delegado a `Cdx.ps1` |

---

## ¿Qué tiene cdx que NO tiene cdx2?

1. **Preview nativo con `cmd.exe`** — cdx usa `cmd /c "bat ... || dir /b ..."` inline. cdx2 usa un script de PowerShell externo para evitar problemas de quoting.
2. **Fallback de preview a PowerShell** — cdx intenta `cmd.exe` primero y si falla usa `Get-ChildItem`. cdx2 usa directamente un script `.ps1`.
3. **Manejo de `$LASTEXITCODE`** — cdx verifica códigos de error explícitos. cdx2 delega en excepciones de PowerShell.
4. **Soporte `--relative-to`** — cdx usa `resolve-path --relative-to`. cdx2 usa `--base-directory` de fd.

## ¿Qué tiene cdx2 que NO tiene cdx?

1. **Navegación recursiva** — `fd --type d` busca en subdirectorios. cdx solo ve el nivel actual.
2. **Indicador visual de zoxide** — `★` prefix en dirs frecuentes.
3. **Doble Esc inteligente** — vuelve al directorio original, no al padre.
4. **Toggle de hidden files** — Ctrl+A para mostrar/ocultar `.dirs`.
5. **Preview de directorios con `eza`** — lista bonita con iconos.
6. **Scripts temporales** — evita problemas de quoting de `cmd.exe` en Windows.

---

## Estado Actual (último commit)

- cdx2 ha reemplazado a la versión antigua en el perfil.
- Preview funciona correctamente con script externo y env var.
- Doble Esc restaura el path original.
- Zoxide cache se carga una sola vez al inicio.

## Dependencias mínimas para cdx2

```powershell
# Obligatorio
winget install sharkdp.fd        # fd
winget install junegunn.fzf      # fzf

# Recomendado
winget install ajeetdsouza.zoxide # zoxide
winget install eza-community.eza  # eza
winget install sharkdp.bat        # bat
```
