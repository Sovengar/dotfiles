# Dotfiles Repo — Agent Instructions

## Repo structure

Monorepo containing 3 independent chezmoi profiles, each **100% self-contained** and designed to be split into its own GitHub repo:

- `linux-personal/` — CachyOS desktop. `home/` (dotfiles) + `setup/` (pacman/AUR install scripts). zsh + fish.
- `linux-server/`   — Ubuntu Server headless. `home/` (minimal CLI dotfiles) + `setup/` (apt install scripts). fish only.
- `windows/`        — Windows. `home/` (AppData, PowerShell profile, packages.yaml) + `setup/` (PowerShell install scripts).

Each profile has `.chezmoiroot` (→ `home`) so `chezmoi diff/add/edit/apply` work **without `--source`**.

Target repos:
- `github.com/Sovengar/dotfiles-linux-personal`
- `github.com/Sovengar/dotfiles-linux-server`
- `github.com/Sovengar/dotfiles-windows-personal`

Backups of the previous single-source layout are in `backup/` (delete after verifying everything works).

## Dependencies

When adding a new tool/dependency/package to any install script, **must also add it to `docs/ecosystem.md`** (in the corresponding profile's `docs/`) under the appropriate category.

## Profile-specific rules

- Don't mix Linux desktop configs (Hyprland, waybar, rofi, kitty, zsh) into `linux-server/home/`. Server is headless.
- `linux-server` uses **fish** (not zsh). No `dot_zshrc`/`dot_zshenv` in server.
- Don't add Windows-specific dotfiles into Linux profile homes. Each profile is self-contained.
- If a config is shared between `linux-personal` and `linux-server`, **duplicate it** (the user explicitly chose no `shared/`).
- `.chezmoi.toml.tmpl` lives in each `home/` (same template). It prompts for `profile` at `chezmoi init`.

## install.sh / install.ps1

Each profile's `setup/install.sh` (or `setup/install.ps1` on Windows) is the **single entry point** for a fresh machine:
1. Install git if missing
2. Update OS (`pacman -Syu` / `apt update && upgrade`)
3. Install chezmoi if missing
4. Clone repo to `~/.local/share/chezmoi`
5. `chezmoi init` (generates config from `.chezmoi.toml.tmpl`)
6. Run setup phases (preflight → packaging → config → post-install)
7. `chezmoi diff` → `chezmoi apply`

Never use `chezmoi apply --force`. Always `chezmoi diff` first.

