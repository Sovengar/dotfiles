# cdx — CD Interactivo Unificado

Navegador de directorios TUI con fzf+fd+rg. Combina cd directo, zoxide, y un explorador interactivo.

## Syntax

```
cdx              TUI — navegar carpetas con fd
cdx <path>       cd directo si la ruta existe
cdx <name>       zoxide → fallback a TUI con query
cdx -g <query>   búsqueda global por contenido (rg)
cdx -h           ayuda
cdx ~            ir a $HOME
cdx ...          ir a $HOME
```

## Modos

### TUI Mode (sin args o como fallback)

Explorador interactivo con fzf y preview. Navega por el sistema de archivos en tiempo real.

**Dependencias obligatorias**: `fd`, `fzf`, `rg`

**Atajos TUI**:

| Tecla | Acción |
|-------|--------|
| Enter | cd al directorio / open archivo |
| Esc | Subir al padre (`cd ..`) |
| Ctrl+C | Salir (mantiene posición) |
| Ctrl+G | Alternar fd (carpetas) ↔ rg (archivos) |
| Ctrl+A | Mostrar/ocultar dotfiles (.*) |
| Ctrl+W | Mostrar/ocultar WinHidden (AppData, ProgramData) |
| Ctrl+H | Ir a $HOME |

### Jump Mode (con argumento)

1. `cdx <path>` → `Set-Location` directo si la ruta existe
2. Si no existe → `zoxide query` (frecency, si está instalado)
3. Si no hay match → abre TUI con query pre-llenada

### Search Mode (`-g`)

`cdx -g <query>` lanza ripgrep en `$HOME` buscando contenido. Los resultados se muestran en fzf con preview.

### Preview

fzf muestra preview en panel derecho/top según el modo actual:

| Modo | Preview |
|------|---------|
| Find (fd) | Contenido del directorio con eza (si existe) |
| Search (rg) | 3 líneas alrededor del match con bat (si existe) |

## Dependencies

| Tool    | Required | Install |
|---------|----------|---------|
| **fd**  | Sí       | `winget install sharkdp.fd` |
| **fzf** | Sí       | `winget install junegunn.fzf` |
| **rg**  | Sí       | `winget install BurntSushi.ripgrep.MSVC` |
| **zoxide** | No    | `winget install ajeetdsouza.zoxide` |
| **eza** | No       | `winget install eza-community.eza` |
| **bat** | No       | `winget install sharkdp.bat` |

## Excluded directories

`node_modules`, `.git`, `.cache`, `vendor`, `target`, `build`, `dist`, `AppData`, `ProgramData`, `go/pkg/mod`

## Architecture

Script: `$HOME\Documents\PowerShell\Cdx.ps1` (cargado por `$PROFILE`)

```
cdx                    dispatch: path → jump → search → TUI
 ├─ Invoke-CdxTui      TUI loop: fd/rg + fzf + preview + toggles
 └─ Invoke-CdxSearch   ripgrep global search (-g)
```

El estado de toggles (rg, dotfiles, WinHidden) se persiste en `$env:TEMP\cdx_state.txt`
como bits en un entero: bit0=rg, bit1=dotfiles, bit2=WinHidden.
