# dotfiles

Repositorio público que **loguea accesos y enruta** a los repos privados de dotfiles.

## Fresh install (máquina nueva)

### Linux Personal (CachyOS)

```bash
curl -fsL https://raw.githubusercontent.com/Sovengar/dotfiles/master/launchers/personal.sh | bash
```

Instala git + gh, autentica con GitHub, clona el repo privado y delega al installer privado. El installer actualiza SO, instala chezmoi, ejecuta fases y aplica dotfiles.

### Linux Server (Ubuntu)

```bash
curl -fsL https://raw.githubusercontent.com/Sovengar/dotfiles/master/launchers/server.sh | bash
```

Autentica con GitHub, clona el repo privado y delega. El installer ejecuta update, chezmoi, fases y apply. Shell: **fish** (no zsh).

### Windows

```powershell
irm https://raw.githubusercontent.com/Sovengar/dotfiles/master/launchers/windows.ps1 | iex
```

Verifica winget, instala Git + gh via winget, clona el repo privado y delega. El installer ejecuta chezmoi init, `run-all.ps1` (winget + npm + bun + go + manual), chezmoi diff y apply.

## Apply diario (máquina ya configurada)

El repo privado ya está clonado en `~/.local/share/chezmoi`:

```bash
cd ~/.local/share/chezmoi
git pull --ff-only
chezmoi diff
chezmoi apply
```

## Repos privados

- `Sovengar/dotfiles-linux-personal` — CachyOS desktop (Hyprland, zsh, fish)
- `Sovengar/dotfiles-linux-server` — Ubuntu Server headless (fish)
- `Sovengar/dotfiles-windows-personal` — Windows (PowerShell)

## Estructura

```
dotfiles/
├── launchers/        ← Scripts públicos (curl | bash / iex)
│   ├── personal.sh
│   ├── server.sh
│   └── windows.ps1
├── backup/           ← Backups del refactor mono→multi repo
├── AGENTS.md
└── README.md
```
