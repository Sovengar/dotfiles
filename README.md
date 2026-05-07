# Dotfiles

Gestionados con [chezmoi](https://www.chezmoi.io).

Dos flujos independientes:

| Flujo | ¿Cuándo? | ¿Cómo? |
|-------|----------|--------|
| **Dotfiles** `(1)` | Cualquier máquina (diario) | `chezmoi apply` |
| **Formateo** `(2)` | Máquina nueva o actualizar paquetes | `.\windows\setup\run-all.ps1` |

---

## (1) Flujo Dotfiles — máquina ya configurada

```powershell
chezmoi apply
```

Aplica **solo dotfiles** (configs de shell, wezterm, lazygit, opencode, starship, git, etc.) y scripts ligeros. 
Rápido, predecible, sin instalación de apps.

### Para mantener actualizado

```powershell
chezmoi update
# = git pull + chezmoi apply
```

---

## (2) Flujo Formateo — máquina nueva (o actualización)

`run-all.ps1` es **idempotente**: puedes ejecutarlo en máquina nueva (instala todo)
o en máquina ya configurada (actualiza lo que falte). Cada sub-script verifica
estado antes de actuar.

```powershell
# 0. Sincronizar OneDrive y crear Secret Vault (ver 🔐 Secret Vault abajo)

# 1. Download dependencies
winget install --id Git.Git -e --source winget --silent
winget install --id twpayne.chezmoi -e --source winget --silent

# 2. Clone config
chezmoi init https://github.com/Sovengar/dotfiles

# 3 (Windows). Allow script execution 
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# 4. WSL + prerequisitos (virtualización, Ubuntu, crear usuario Linux)
.\windows\setup\01-wsl-setup.ps1
# Reiniciar si el script lo indica; crear usuario Ubuntu la primera vez

# 5. (Work PC) Developer Mode para symlinks — CORRER COMO ADMIN
.\windows\setup\02-enable-symlinks.ps1
# Abre PowerShell como administrador (usuario admin), corre esto, cierra.
# Solo toca el registro, no tus dotfiles. Se hace una vez por máquina.

# 6. Setup all (instala o actualiza)
.\windows\setup\run-all.ps1
```

`run-all.ps1` corre en orden:
- `00-env-vars.ps1` — variables XDG
- `10-install-packages.ps1` — ~70+ apps via winget + manual
- `20-configure-system.ps1` — PATH, symlinks
- `personal/ssh-client-setup.ps1` — SSH keys (con prompt)
- `personal/startup-shortcuts.ps1`, `setup-listary.ps1` — personales (con prompt)
- `30-setup-registry.ps1` — context menus
- `35-setup-auth.ps1` — gh + opencode login (con prompt)
- `40-setup-docker.ps1` — Docker WSL2 integration (último)

Post-run-all: `chezmoi apply` (dotfiles + scripts ligeros + auth.json desde env.toml).

---

## Estructura del repositorio

```
dotfiles/
├── home/                         ← Source state de chezmoi (se sincroniza a ~/)
│   ├── .chezmoiscripts/          ← Scripts LIGEROS auto-sync (registry, shortcuts)
│   ├── .chezmoidata/             ← Datos declarativos (packages.yaml)
│   ├── dot_*                     ← Dotfiles raíz (~/.gitconfig, etc.)
│   ├── dot_config/               ← Configs en ~/.config (wezterm, lazygit, etc.)
│   └── Documents/                ← PowerShell profile, PowerToys backup
│
├── windows/
│   ├── setup/                    ← TODO: scripts standalone, NO chezmoi
│   │   ├── 00-env-vars.ps1
│   │   ├── 01-wsl-setup.ps1
│   │   ├── 02-enable-symlinks.ps1
│   │   ├── 10-install-packages.ps1
│   │   ├── 20-configure-system.ps1
│   │   ├── lib.ps1
│   │   ├── 40-setup-docker.ps1
│   │   ├── setup-registry.ps1
│   │   ├── registry/             ← .reg files
│   │   │   ├── Wezterm/
│   │   │   ├── System/
│   │   │   ├── WindowsTerminal/
│   │   │   └── Removers/
│   │   ├── personal/             ← Scripts de máquina personal (con prompt)
│   │   │   └── ...
│   │   └── run-all.ps1           ← Orquestador
│
├── docs/                         ← Documentación adicional
├── README.md
└── .chezmoiroot                  ← root = home/
```

## Arquitectura: separación de concerns

| Capa | Mecanismo | Frecuencia | Qué hace |
|------|-----------|-----------|----------|
| **Dotfiles** | `chezmoi apply` | Diario | PowerShell profile, WezTerm, Lazygit, OpenCode, Starship, Git config |
| **Scripts ligeros** | `run_onchange_` via chezmoi | Cuando cambian | Registry context menus, dev shortcuts, startup |
| **App installation** | `windows/setup/*.ps1` manual | Solo post-formateo | winget, mise, npm/bun/go globals, manual downloads |
| **System config** | `windows/setup/*.ps1` manual | Solo post-formateo | PATH, symlinks, env vars, SSH |

## Paquetes declarativos

La lista completa de paquetes está en `home/.chezmoidata/packages.yaml`.
Los scripts standalone la leen via `chezmoi execute-template "{{ toJson .packages }}"`.

Para modificar qué se instala, editar SOLO ese archivo — no los scripts.

## 🔐 Secret Vault

Secretos (API keys, tokens, email) via `OneDrive\secrets\env.toml`. **Nunca se suben a Git.**

```powershell
# Solo primera vez:
New-Item -ItemType Directory -Path "$env:USERPROFILE\OneDrive\secrets" -Force
notepad "$env:USERPROFILE\OneDrive\secrets\env.toml"
```

Formato: usa `home/OneDrive/secrets/env.toml.tmpl` como referencia.
`[opencode].config` = contenido completo de `~/.local/share/opencode/auth.json`.

| Quién | Lee | Genera |
|-------|-----|--------|
| `.chezmoi.toml.tmpl` | `[git]`, `[ssh]` | `dot_gitconfig.tmpl` |
| `35-firecrawl-key.ps1` | `[api_keys].firecrawl` | `FIRECRAWL_API_KEY` env |
| `auth.json.tmpl` | `[opencode].config` | `~/.local/share/opencode/auth.json` |

Tras refrescar OAuth (`opencode login`), copia los nuevos tokens a `env.toml`.

## Requisitos

- OneDrive sincronizado (para env.toml)
