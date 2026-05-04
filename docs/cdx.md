# cdx - CD Vitaminado

Jump to directories by name or search files/text with fzf navigation.

## Syntax

```
cdx [name]       Jump mode: frecency jump (zoxide) or search fallback
cdx <path>       Go directly if the path exists
cdx -s <query>   Force search mode with ripgrep + fzf
```

## Modes

### Jump Mode (default, no flag)

1. If the argument is an **existing path** → `Set-Location` immediately.
2. If **zoxide is installed** → calls `zoxide query` for a frecency-based jump.
3. If zoxide **not installed** or no match → falls back to **search mode** automatically.

### Search Mode (`-s` flag or auto-fallback)

Launches a 3-phase ripgrep search across `$HOME`, prioritizes results from `$HOME/dev` and `$HOME/.config`, and presents matches via fzf for interactive selection.

## Dependencies

| Tool       | Role                         | Install                                       |
|------------|------------------------------|-----------------------------------------------|
| **zoxide** | Frecency jumps (optional)    | `winget install ajeetdsouza.zoxide`           |
| **rg**     | Content/file name search     | `winget install BurntSushi.ripgrep.MSVC`      |
| **fzf**    | Interactive result selection | `winget install junegunn.fzf`                 |
| **PSFzf**  | PowerShell fzf integration   | `Install-Module -Name PSFzf -Scope CurrentUser` |

> cdx works without zoxide — it auto-falls back to rg+fzf search.

## Search Details

### Scope

- **Priority roots**: `$HOME/dev` and `$HOME/.config` — depth 6
- **Secondary scope**: entire `$HOME` — depth 5

### Excluded directories

`node_modules`, `.git`, `AppData`, `.cache`, `vendor`, `target`, `build`, `dist`

### Search phases (executed in parallel)

| # | Type                 | Method                                               |
|---|----------------------|------------------------------------------------------|
| 1 | **Content matches**  | `rg --files-with-matches --smart-case $Query`        |
| 2 | **File name matches**| `rg --files | rg $Query`                             |
| 3 | **Directory matches**| `Get-ChildItem -Directory -Recurse` filtered by name |

Results from all 3 phases are deduplicated and presented in a single fzf list.

### fzf interface

- **Preview pane** (top 50%): shows ripgrep context (3 lines around match) with syntax highlighting
- **Enter**: navigates to the selected path
- **Esc**: cancels

## Navigation Behavior

When a result is selected in fzf:

| Selection type | Navigation target                                            |
|----------------|--------------------------------------------------------------|
| **Directory**  | `Set-Location` to that directory                             |
| **File**       | Git repo root (if inside a git repo), otherwise parent dir   |

## Usage Examples

```powershell
# Jump to a frequently visited directory by name
cdx dev

# Jump to a directory containing "agent" in the name
cdx agent

# Force search mode even if zoxide is installed
cdx -s dotfiles

# Direct path (works as regular cd)
cdx C:\Users\buble\Documents

# Search for files containing "function cdx"
cdx -s "function cdx"
```

## Architecture

The command lives in `C:\Users\buble\Documents\PowerShell\Cdx.ps1` and is loaded by `$PROFILE`:

```powershell
. (Join-Path $PSScriptRoot 'Cdx.ps1')
```

Three functions compose the command:

```
cdx                        -- dispatch: path → jump → search
  ├─ Invoke-CdxSearch     -- rg + fzf pipeline
  └─ Resolve-CdxDestination -- navigate to directory or git root
```

## Why

- `cd` requires typing full paths or multiple `..\..\` chains
- `zoxide` is great for frecency but only works with previously visited dirs
- `cdx` combines frecency jumps with content-aware search for the best of both worlds
- The fzf preview gives context before you navigate, reducing wrong moves
