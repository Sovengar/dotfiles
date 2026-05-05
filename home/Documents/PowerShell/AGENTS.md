# PowerShell Profile — Project AGENTS.md

## Descripción

Perfil de PowerShell con herramientas de navegación TUI, aliases tipo Unix, y completions.

## Archivos Clave

- `Microsoft.PowerShell_profile.ps1` — Entry point. Carga todo lo demás.
- `Cdx.ps1` — `cdx`: Navegador interactivo de directorios con fzf+fd+rg. Toggle Ctrl+G (fd↔rg), Ctrl+A (dotfiles), Ctrl+W (WinHidden), Ctrl+C (exit), Esc (cd ..).
- `CDX_DOCUMENTATION.md` — Documentación técnica (usuario + IA) de cdx. Debe reflejar siempre el estado actual de Cdx.ps1.
- `LinuxAliases.ps1` — Comandos tipo Unix: `ls` (eza), `grep` (rg), `find` (fd), `touch`, `head`, `tail`, `which`, `df`, `du`, `uptime`, `ps`, `wc`, `rm -rf`, `btm`.

## Dependencias Externas

- **fzf** — Motor de fuzzy finding TUI
- **fd** — Búsqueda rápida de archivos
- **rg (ripgrep)** — Búsqueda de contenido
- **eza** — `ls` con icons y colores
- **bat** — Preview de código con syntax highlighting
- **zoxide** — Navegación inteligente (aprende directorios frecuentes)
- **bottom (btm)** — Monitor de procesos

## Convenciones

- Preferir `fd` sobre `Get-ChildItem -Recurse` para búsqueda de archivos
- Preferir `rg` sobre `Select-String` para búsqueda de contenido
- Preferir `eza` sobre `Get-ChildItem` para listar directorios
- Usar `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` en scripts con output UTF-8
- Scripts temporales en `$env:TEMP` con prefijo `cdx_`

## Reglas

- NO modificar `Cdx.ps1` sin verificar que `cdx` function siga funcionando
- NO eliminar/excluir paths sin revisar `$script:CdxExcludeCatA` y `$script:CdxExcludeCatC`
- NO agregar dotfiles al profile sin preguntar
- NO modificar `Cdx.ps1` sin actualizar `CDX_DOCUMENTATION.md` para reflejar los cambios (comportamiento, nuevos flags, cambios en atajos, etc.)

## Versionado con Chezmoi

Todos los archivos de este directorio se versionan con **chezmoi**.

**Source (repo):** `C:\Users\buble\.local\share\chezmoi\home\Documents\PowerShell\`

**Flujo para persistir cambios:**

```powershell
# 1. Editar el archivo local (este directorio)
# 2. Sincronizar con chezmoi:
chezmoi re-add Documents\PowerShell\ARCHIVO.ps1

# Para actualizar TOOODO el directorio de una sola vez:
chezmoi re-add Documents\PowerShell\

# 3. Ir al source y commitear:
cd ~\.local\share\chezmoi
git add -A
git commit -m "feat(pwsh): descripción del cambio"
git push
```

> ⚠️ **Gotcha**: `chezmoi re-add` puede fallar con "not managed" aunque el archivo SÍ esté en el source (bug de path relativo). Workaround: usar ruta absoluta con `chezmoi add $HOME\Documents\PowerShell\ARCHIVO.ps1`.

**NO editar nunca los archivos dentro de `.local\share\chezmoi\home\` directamente.**
Siempre editar el archivo local (este directorio) y luego `chezmoi re-add`.
