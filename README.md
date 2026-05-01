# Dotfiles

Gestionados con [chezmoi](https://www.chezmoi.io) para automatizar la configuración tras formateo.

## Uso

```powershell
# Instalar chezmoi
winget install --id twpayne.chezmoi -e --silent

# Aplicar configuración
chezmoi init --apply https://github.com/Sovengar/dotfiles
```

## Requisitos previos

1. OneDrive sincronizado (para `env.toml`)
2. GitHub CLI instalado (`gh auth login` si el repo es privado)

## Estructura

- `.chezmoiscripts/` - Scripts de automatización
- `dot_*/` - Dotfiles raíz
- `dot_config/` - Configuraciones en ~/.config
- `AppData/` - Configuraciones de Windows