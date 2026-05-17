# Dotfiles

Gestionados con [chezmoi](https://www.chezmoi.io).

Dos flujos independientes por SO:

| Flujo | SO | ¿Cuándo? | ¿Cómo? |
|-------|----|----------|--------|
| **Dotfiles** `(1)` | Linux / Windows | Cualquier máquina (diario) | `chezmoi apply` |
| **Formateo Linux** `(2a)` | Linux | Máquina nueva | `curl -fsL https://raw.githubusercontent.com/Sovengar/dotfiles/master/linux/setup/install.sh \| bash` |
| **Formateo Windows** `(2b)` | Windows | Máquina nueva o actualizar paquetes | `.\windows\setup\run-all.ps1` |

---

## (1) Flujo Dotfiles — máquina ya configurada

```bash
chezmoi apply
```

Aplica **solo dotfiles** (configs de shell, wezterm, lazygit, opencode, starship, git, etc.) y scripts ligeros.
Rápido, predecible, sin instalación de apps.

### Para mantener actualizado

```bash
chezmoi update
# = git pull + chezmoi apply
```

---

## (2a) Flujo Formateo — Linux (máquina nueva)

Script bash que instala Git si falta, clona este repo y ejecuta el setup local. No aplica dotfiles automáticamente:

```bash
curl -fsL https://raw.githubusercontent.com/Sovengar/dotfiles/master/linux/setup/install.sh | bash
```

Si no usas `curl | bash`, inicializa el source state con `chezmoi` y ejecuta el setup local:

```bash
chezmoi init https://github.com/Sovengar/dotfiles
cd ~/.local/share/chezmoi
./linux/setup/install.sh
```

En una máquina nueva, primero ejecuta los scripts Linux y deja `chezmoi apply` para el final, manualmente.

El script `install.sh` orquesta 4 fases:

1. **Preflight** — checks de sistema, XDG dirs, Linuxbrew
2. **Packaging** — CLI tools, API tools, docker, dropbox, zsh+fish, KeePassXC, Zen Browser
3. **Config** — shell por defecto, brew en PATH, teclado, autostarts, mounts, audio, pyprland
4. **Post-install** — resumen + próximos pasos

Los scripts individuales pueden ejecutarse por separado:

```bash
# Ejemplo: solo instalar shells
bash ~/.local/share/chezmoi/linux/setup/packaging/30-shells.sh
```

> **Nota:** Detecta automáticamente apt/pacman/dnf/brew.  
> Los scripts heredados están en `linux/old/`.

---

## (2b) Flujo Formateo — Windows (máquina nueva o actualización)

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

# 3. Allow script execution 
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
- `35-setup-auth.ps1` — gh auth login (con prompt)
- `40-setup-docker.ps1` — Docker WSL2 integration (último)

Post-run-all: `chezmoi apply` (dotfiles + scripts ligeros + auth.json desde SOPS).

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
├── linux/                        ← Scripts para Linux (bash)
│   ├── setup/
│   │   ├── install.sh            ← Bootstrap: orquesta preflight → packaging → config → post-install
│   │   ├── helpers/              ← logging, errores, guards, display
│   │   ├── preflight/            ← system checks, XDG dirs, brew
│   │   ├── packaging/            ← CLI tools, API tools, docker, dropbox, shells, keepassxc, zen
│   │   ├── config/               ← shell default, PATH, teclado, autostarts, mounts, audio, pyprland
│   │   └── post-install/         ← resumen final
│   └── old/                      ← Dotfiles heredados (pre-chezmoi)
│
├── windows/                      ← Scripts para Windows (PowerShell)
│   ├── setup/
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
│   └── unmanaged/                ← Archivos no gestionados por chezmoi
│
├── docs/                         ← Documentación adicional
├── README.md
└── .chezmoiroot                  ← root = home/
```

## Arquitectura: separación de concerns

| Capa | Mecanismo | Frecuencia | Linux | Windows |
|------|-----------|-----------|-------|---------|
| **Dotfiles** | `chezmoi apply` | Diario | Shell config, WezTerm, Lazygit, OpenCode, Starship, Git config | PowerShell profile, WezTerm, Lazygit, OpenCode, Starship, Git config |
| **Scripts ligeros** | `run_onchange_` via chezmoi | Cuando cambian | Hooks post-actualización | Registry context menus, dev shortcuts, startup |
| **App installation** | Script manual | Solo post-formateo | `linux/setup/install.sh` (fases: helpers→preflight→packaging→config→post-install) | `windows/setup/10-install-packages.ps1` (winget + manual) |
| **System config** | Script manual | Solo post-formateo | XDG env vars, brew PATH, shells, mounts, autostarts | PATH, symlinks, registry, SSH, Docker |

## Paquetes declarativos

La lista completa de paquetes está en `home/.chezmoidata/packages.yaml`.
Los scripts standalone la leen via `chezmoi execute-template "{{ toJson .packages }}"`.

Para modificar qué se instala, editar SOLO ese archivo — no los scripts.

## 🔐 Secret Vault

Secretos (API keys, tokens, email, `opencode` auth) via `sops + age` en `secrets/dotfiles.sops.yaml`.
El archivo cifrado se sube a Git; la clave privada `age` **nunca** se sube.

```bash
# Linux/macOS
mkdir -p ~/.config/sops/age
# Restaurar desde KeePassXC: Database/SO/chezmoi age identity (Notes)
chmod 600 ~/.config/sops/age/keys.txt
```

```powershell
# Windows
New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\sops\age" -Force
# Restaurar desde KeePassXC: Database/SO/chezmoi age identity (Anotaciones)
```

`run_before_00-restore-age-key.*` restaura `~/.config/sops/age/keys.txt` desde KeePassXC si falta.

Para que el restore automatico funcione necesitas tener disponible la base KeePassXC:

| OS | Ruta default esperada |
|----|----------------------|
| Linux | `~/onedrive/BBDD.kdbx` |
| Windows | `%USERPROFILE%\OneDrive\BBDD.kdbx` |

La entrada esperada dentro de la base es `SO/chezmoi age identity` y la key debe estar en Notes/Anotaciones.
Si usas otra ruta o entrada, sobrescribe `KEEPASS_DB` o `KEEPASS_AGE_ENTRY` antes de `chezmoi apply`.

Editar secrets:

```bash
sops secrets/dotfiles.sops.yaml
```

`opencode.config` = contenido completo de `~/.local/share/opencode/auth.json`.

| Quién | Lee | Genera |
|-------|-----|--------|
| `dot_gitconfig.tmpl` | `[git].email` | `~/.gitconfig` |
| `run_once_after_20-firecrawl-key.ps1` | `[api_keys].firecrawl` | `FIRECRAWL_API_KEY` env |
| `auth.json.tmpl` | `[opencode].config` | `~/.local/share/opencode/auth.json` |

Tras refrescar OAuth (`opencode login`), actualiza `opencode.config` con `sops secrets/dotfiles.sops.yaml`.

## Requisitos

### Linux
- Gestor de paquetes (apt, pacman, o dnf)
- Máquina nueva con `curl | bash`: `curl`, `bash`, `sudo`, internet y un gestor soportado
- Máquina nueva sin `curl | bash`: `chezmoi` para inicializar el source state
- Máquina ya configurada: `chezmoi` para sincronizar/aplicar dotfiles

### Windows
- KeePassXC database disponible para restaurar `~/.config/sops/age/keys.txt`
- `sops` y `age` instalados antes de aplicar templates con secrets
- PowerShell 5.1+
- winget instalado
