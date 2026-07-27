# Dotfiles

Gestionados con [chezmoi](https://www.chezmoi.io). Hay **3 repositorios separados**, cada uno 100% autocontenido:

| Repo | SO | Distro | Shell | Dotfiles | Setup |
|------|----|--------|-------|----------|-------|
| `dotfiles-linux-personal` | Linux | CachyOS (pacman+AUR) | zsh + fish | Desktop completo (44 dirs en `dot_config/`) | `packaging/` 30+ categorías |
| `dotfiles-linux-server` | Linux | Ubuntu Server (apt) | fish | Headless + dev tools (12 dirs en `dot_config/`) | `packaging/` minimal |
| `dotfiles-windows-personal` | Windows | winget / PowerShell | PowerShell | AppData, Documents, packages.yaml | `run-all.ps1` |

Cada repo tiene `.chezmoiroot` (→ `home`) para que `chezmoi diff/add/edit/apply` funcionen **sin `--source`**.

## Flujos

### (1) Aplicar dotfiles — máquina ya configurada

```bash
# Linux (personal o server) — cd dentro del repo
cd ~/.local/share/chezmoi
chezmoi diff    # revisar cambios
chezmoi apply   # aplicar

# Windows
chezmoi diff
chezmoi apply
```

Pull + apply (máquina ya configurada):

```bash
cd ~/.local/share/chezmoi
git pull --ff-only
chezmoi apply
```

### (2a) Fresh install — Linux Personal (CachyOS)

```bash
curl -fsL https://raw.githubusercontent.com/Sovengar/dotfiles/master/launchers/personal.sh | bash
```

El script público (launcher) instala git + gh, autentica con GitHub,
clona el repo privado, y delega al installer privado.
El installer privado (actualiza SO, instala chezmoi, ejecuta fases,
aplica dotfiles):

### (2b) Fresh install — Linux Server (Ubuntu)

```bash
curl -fsL https://raw.githubusercontent.com/Sovengar/dotfiles/master/launchers/server.sh | bash
```

El launcher público autentica con GitHub, clona el repo privado, y delega.
El installer privado ejecuta update, chezmoi, fases y apply. Shell: **fish** (no zsh).

### (2c) Fresh install — Windows

```powershell
irm https://raw.githubusercontent.com/Sovengar/dotfiles/master/launchers/windows.ps1 | iex
```

El script:
1. Verifica winget
2. Instala Git + chezmoi via winget
3. Clona repo
4. `Set-ExecutionPolicy RemoteSigned`
5. `chezmoi init`
6. `run-all.ps1` (instala todo: winget + npm + bun + go + manual)
7. `chezmoi diff` → `chezmoi apply`

## Estructura del repositorio público (`Sovengar/dotfiles`)

```
dotfiles/
├── launchers/                  ← Scripts públicos (curl | bash)
│   ├── personal.sh             ← Launcher para dotfiles-linux-personal (privado)
│   ├── server.sh               ← Launcher para dotfiles-linux-server (privado)
│   └── windows.ps1             ← Launcher para dotfiles-windows-personal (privado)
├── backup/                     ← Backups del refactor
├── README.md
└── AGENTS.md
```

Cada launcher instala git + gh, autentica con GitHub, clona el repo privado correspondiente,
y delega a su `setup/install.sh` (que vive en el repo privado).

## Estructura de cada repo privado

Cada repo privado tiene `.chezmoiroot` (→ `home`) para que `chezmoi diff/add/edit/apply` funcionen **sin `--source`**.

### dotfiles-linux-personal

```
dotfiles-linux-personal/
├── .chezmoiroot              ← "home" (chezmoi lo lee automáticamente)
├── .sops.yaml                ← SOPS config (age recipient)
├── home/                     ← Source state (chezmoi diff/apply sin --source)
│   ├── .chezmoi.toml.tmpl    ← Config template (email, age, profile prompt)
│   ├── .chezmoiignore
│   ├── .chezmoiscripts/      ← Scripts ligeros (themes)
│   ├── dot_config/           ← 44 dirs (hypr, waybar, git, nvim, zsh, fish, etc.)
│   ├── dot_zshrc dot_zshenv
│   ├── dot_local/bin/        ← Scripts desktop
│   └── dot_agents/
├── setup/                    ← Scripts CachyOS
│   ├── install.sh            ← Bootstrap completo
│   ├── helpers/              ← logging, errors, guards, display
│   ├── preflight/            ← system checks, XDG, paru, chaotic-aur, brew
│   ├── packaging/            ← 30+ categorías
│   ├── config/              ← shell default, brew PATH, mounts, audio
│   ├── setup/               ← dev dirs, TUI generators, themes
│   ├── themes/
│   ├── fixes/
│   └── post-install/        ← resumen + próximos pasos
├── secrets/                  ← SOPS-encrypted secrets
├── docs/                     ← Documentation
└── README.md
```

### dotfiles-linux-server

```
dotfiles-linux-server/
├── .chezmoiroot
├── .sops.yaml
├── home/
│   ├── .chezmoi.toml.tmpl
│   ├── .chezmoiignore
│   └── dot_config/          ← 12 dirs (bat, fish, fzf, git, lazygit, lazydocker,
│   │                           mise, nvim, opencode, starship, yazi, environment.d)
├── setup/
│   ├── install.sh           ← Bootstrap apt-based
│   ├── helpers/
│   ├── preflight/
│   ├── packaging/           ← CLI: core-tools, shells, dev-tools, container-tools, security
│   ├── config/             ← shell prompt, PATH, mise (fish)
│   └── post-install/
├── secrets/
├── docs/
└── README.md
```

### dotfiles-windows-personal

```
dotfiles-windows-personal/
├── .chezmoiroot
├── home/
│   ├── .chezmoi.toml.tmpl
│   ├── .chezmoiignore
│   ├── .chezmoiscripts/    ← Registry context menus, dev shortcuts, startup, age restore
│   ├── .chezmoidata/       ← packages.yaml (winget + npm + bun + go + manual)
│   ├── AppData/            ← Windows AppData (Roaming + Local)
│   ├── Documents/          ← PowerShell profile, PowerToys backup
│   ├── dot_starship/
│   └── .local/bin/
├── setup/
│   ├── install.ps1         ← Bootstrap completo
│   ├── run-all.ps1         ← Orquestador idempotente
│   ├── 00-env-vars.ps1
│   ├── 01-wsl-setup.ps1
│   ├── 10-install-packages.ps1
│   ├── 20-configure-system.ps1
│   ├── 30-setup-registry.ps1
│   ├── 35-setup-auth.ps1
│   ├── 40-setup-docker.ps1
│   ├── registry/           ← .reg files
│   ├── personal/            ← SSH, shortcuts (con prompt)
│   ├── miniwindows/        ← Windows 11 VM para Office 365
│   └── unmanaged/          ← .gitignore'ed
└── README.md
```

## Arquitectura: separación de concerns

| Capa | Mecanismo | Frecuencia | Linux Personal | Linux Server | Windows |
|------|-----------|-----------|----------------|-------------|---------|
| **Dotfiles** | `chezmoi apply` | Diario | Shell, Hyprland, WezTerm, Lazygit, OpenCode | Shell, Lazygit, nvim, OpenCode | PowerShell, WezTerm, Lazygit, OpenCode |
| **Scripts ligeros** | `run_onchange_` chezmoi | Cuando cambian | Themes post-apply | (sin) | Registry, shortcuts, age restore |
| **App installation** | `setup/install.sh` | Post-formateo | `packaging/` 30+ categorías | `packaging/` minimal apt | `10-install-packages.ps1` |
| **System config** | Script manual | Post-formateo | XDG, brew PATH, mounts | shell prompt, PATH, mise | PATH, symlinks, registry, Docker |

## Configuración inicial (chezmoi init)

Cada repo privado tiene su propio `.chezmoi.toml.tmpl`.

```bash
# Personal (CachyOS)
chezmoi init https://github.com/Sovengar/dotfiles-linux-personal
# Responde "personal" al prompt de profile

# Server (Ubuntu)
chezmoi init https://github.com/Sovengar/dotfiles-linux-server
# Responde "server" al prompt de profile
```

```powershell
# Windows
chezmoi init https://github.com/Sovengar/dotfiles-windows-personal
```

> **Nota**: Los repos son privados. Necesitas `gh auth login` antes de
> `chezmoi init` para que git pueda clonar. El launcher público ya lo hace por ti.

## Arquitectura: 2 capas

| Capa | Repo | Responsabilidad |
|------|------|-----------------|
| **Launcher** (público) | `Sovengar/dotfiles` | `curl \| bash` → instala git + gh → autentica → clona repo privado → delega |
| **Installer** (privado) | `dotfiles-*` | `setup/install.sh` → update OS → chezmoi → fases → `chezmoi diff` → `chezmoi apply` |

## 🔐 Secret Vault

Secretos via `sops + age` en `secrets/dotfiles.sops.yaml`. La clave privada `age` nunca se sube a Git.

```bash
# Restaurar age key
mkdir -p ~/.config/sops/age
# Restaurar desde KeePassXC: Database/SO/chezmoi age identity (Notes)
chmod 600 ~/.config/sops/age/keys.txt

# Editar secrets
sops secrets/dotfiles.sops.yaml
```

El script `run_before_00-restore-age-key.*` restaura la key desde KeePassXC si falta.

| OS | Ruta default esperada |
|----|----------------------|
| Linux | `~/onedrive/BBDD.kdbx` |
| Windows | `%USERPROFILE%\OneDrive\BBDD.kdbx` |

## Por qué 3 repos separados

Cada repo es un source dir independiente con `.chezmoiroot`. Ventajas:
- `chezmoi diff/add/edit/apply` funcionan **sin `--source`**
- Sin templates condicionales por OS que ensucien los `.chezmoiignore`
- Cada repo puede tener su propio branch, issues, CI
- Sin `shared/` — duplicación aceptada a cambio de simplicidad

## Paquetes declarativos

Solo Windows tiene lista declarativa: `home/.chezmoidata/packages.yaml`.
Linux usa scripts imperativos en `setup/packaging/`.

## Requisitos

### Linux Personal (CachyOS)
- pacman + paru (AUR) + chaotic-aur
- `curl | bash`: curl, bash, sudo, internet

### Linux Server (Ubuntu)
- Ubuntu/Debian con apt
- `curl | bash`: curl, bash, sudo, internet

### Windows
- PowerShell 5.1+
- winget
- KeePassXC database para restaurar age key