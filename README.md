# Dotfiles

Gestionados con [chezmoi](https://www.chezmoi.io) para automatizar la configuración tras formateo.

## Uso

```powershell
# Instalar chezmoi
winget install --id twpayne.chezmoi -e --silent

# 1. CLONAR (sin aplicar aún)
chezmoi init https://github.com/Sovengar/dotfiles

# 2. PREVISUALIZAR cambios (OBLIGATORIO --dry-run)
chezmoi diff
chezmoi apply --dry-run

# 3. APLICAR solo si la previsualización es correcta
chezmoi apply
```

> ⚠️ **NUNCA ejecutes `chezmoi apply` sin `--dry-run` primero.**
> Un `--dry-run` previo evita estados inconsistentes si algo falla a medias.

## Requisitos previos

1. OneDrive sincronizado (para `env.toml`)
2. GitHub CLI instalado (`gh auth login` si el repo es privado)

## Windows Registry (Menús contextuales)

Los archivos `.reg` para menús contextuales están en `windows/registry/` y **no son gestionados por chezmoi** (no son dotfiles).

```powershell
# Aplicar todos los menús contextuales de WezTerm y Windows Terminal
cd windows/registry
.\apply-registry.ps1

# O aplicar manualmente un archivo específico
reg import "context-menus\Wezterm\open-with-opencode.reg"
```

**Estructura:**
- `context-menus/Wezterm/` - Menús para WezTerm
- `context-menus/WindowsTerminal/` - Menús para Windows Terminal
- `context-menus/Removers/` - Archivos para eliminar los menús (desinstalación)

## Estructura

- `.chezmoiscripts/` - Scripts de automatización (instalan apps, configuran WSL, etc.)
- `home/` - Dotfiles gestionados por chezmoi (se sincronizan a `~`)
  - `dot_*/` - Dotfiles raíz (`~/.bashrc`, `~/.gitconfig`, etc.)
  - `dot_config/` - Configuraciones en `~/.config`
  - `AppData/` - Configuraciones de Windows
- `windows/` - Configuraciones de Windows **NO gestionadas por chezmoi** (archivos de registro, scripts de setup, etc.)