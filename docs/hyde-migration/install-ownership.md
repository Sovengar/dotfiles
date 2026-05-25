# Install And Ownership Migration

> Goal: translate HyDE's installer/restore model into explicit chezmoi ownership.

This is the critical migration area. Runtime use of `hyde-shell` is acceptable; HyDE restore/install scripts overwriting `.config` files is not.

## Install Pipeline

| Script | Role |
|--------|------|
| `Scripts/install.sh` | Main orchestrator: packages, restore, theme, post-install, services. |
| `Scripts/install_pre.sh` | Pacman/bootloader/Chaotic-AUR setup. |
| `Scripts/install_pkg.sh` | Installs packages from lists through pacman/AUR helper. |
| `Scripts/install_aur.sh` | Installs AUR helper. |
| `Scripts/restore_cfg.sh` | Deploys configs from PSV/LST/JSON, with backups. |
| `Scripts/restore_cfg.psv` | Current source of truth for file ownership/deploy flags. |
| `Scripts/restore_fnt.sh` | Installs fonts/icons/themes from archives. |
| `Scripts/restore_thm.sh` | Imports themes. |
| `Scripts/restore_shl.sh` | Sets shell, installs/updates OMZ/plugins. |
| `Scripts/install_pst.sh` | SDDM/avatar/dolphin/shell/flatpak post-install. |
| `Scripts/restore_svc.sh` | Enables system services. |
| `Scripts/uninstall.sh` | Moves configs to backup/remove dirs and deletes HyDE state/cache. |

## `restore_cfg.psv` Flags

| Flag | Meaning | Chezmoi migration equivalent |
|------|---------|------------------------------|
| `P` | Populate only if target missing; preserve existing. | Add once, then avoid force overwrite. |
| `S` | Sync from HyDE source; backup existing; overwrite target. | Chezmoi-managed source of truth or generated file. |
| `O` | Move target to backup; copy new. | Avoid for user dotfiles; explicit migration step only. |
| `B` | Backup only. | Manual backup if needed. |
| `T` | Trash target to backup; no deploy. | Manual cleanup. |
| `I` | Ignore. | Leave unmanaged. |

The PSV file is the migration checklist. It tells which files HyDE considers user-preserved and which it considers HyDE-owned.

## High-Value Ownership Groups

| Group | HyDE behavior | Migration decision |
|-------|---------------|--------------------|
| UWSM | `S` sync for `~/.config/uwsm/env*`. | Owned in chezmoi and split into semantic env/toolkit/compositor files. |
| Hyprland Lua/conf | Mixed `P` and `S`. | Already mostly chezmoi-owned; keep control. |
| Shell | zsh/fish core dirs mostly `S`; user stubs `P`. | Zsh/fish startup is owned; stop HyDE restore from touching both. |
| Kitty | `kitty.conf` preserved; `hyde.conf`/`theme.conf` sync/generated. | Stable config owned; generated theme include stays ignored. |
| Waybar | config/style mostly preserved; modules/shared scripts partly ignored/synced. | Own layout; leave color include generated until replacement. |
| Dunst | `S` sync plus wallbash rewrite. | Split static config from generated colors. |
| GTK/Qt/Kvantum | `S` sync and theme switch partial rewrites. | Own after theme replacement. |
| Rofi/wlogout | Rofi preserved, wlogout synced. | Own when replacing launchers/theme. |
| HyDE libs/bins | `O` overwrite for `~/.local/bin`, `~/.local/lib/hyde`, `~/.local/share/hyde`. | Appropriate as engine surface; do not let restore overwrite owned configs. |

## Backup And Overwrite Risks

| Risk | Source |
|------|--------|
| Restore overwrites shell dirs. | `restore_cfg.psv` uses `S` for zsh/fish `conf.d`, functions, completions. |
| Restore overwrites HyDE libs and bins. | `O` entries for `~/.local/bin` and `~/.local/lib/hyde`. |
| Restore can regenerate Python/Lua env/state. | `restore_cfg.sh` runs `hyde-shell pyinit` and version cache steps. |
| `restore_shl.sh` mutates shell setup. | OMZ install/update, plugin clone, `chsh`. |
| Uninstall script is not a complete rollback. | Moves configs/state/cache, prints manual cleanup, does not fully reverse system tweaks. |
| Pacman/bootloader tweaks are outside dotfiles. | `install_pre.sh` can change `/etc/pacman.conf` and bootloader args. |

## Chezmoi Strategy

| Step | Action |
|------|--------|
| 1 | Keep generated files ignored until replacement generator exists. |
| 2 | For each PSV `P` file you care about, decide if chezmoi should own it. |
| 3 | For each PSV `S` file, decide whether it is truly source-owned or generated. |
| 4 | Move generated app theme files into include-only files when possible. |
| 5 | Stop running HyDE restore scripts once chezmoi owns the same paths. This matters more than removing `hyde-shell` calls. |
| 6 | Record external packages in `docs/ecosystem.md` when adding install scripts. |

## Files To Audit Before Changing HyDE Engine Ownership

| Path | Why |
|------|-----|
| `~/.config/hyde/config.toml` | Removed from this dotfiles flow; define values in the domain-specific file that consumes them. |
| `~/.local/state/hypr/staterc` | Hypr-scoped runtime selections such as current theme, animation, workflow, shader, and lock layout. |
| `~/.local/state/waybar/staterc` | Waybar-scoped runtime selections such as current layout/style and local values such as `WAYBAR_SCALE`. |
| `~/.cache/hyde/` | Wallpaper thumbnails, dcol cache, logs. |
| `~/.config/cfg_backups/` | Installer backups that may contain old user edits. |
| `~/.local/lib/hyde/` | Runtime scripts used by keybindings and startup. |
| `~/.local/bin/hyde-shell` | Tracked in chezmoi as `home/dot_local/bin/executable_hyde-shell`. |
| `~/.local/bin/hydectl`, `~/.local/bin/hyde-ipc` | Opaque binaries — role still unknown. Pending investigation. |

## Migration Stages

| Stage | Action | Status |
|-------|--------|--------|
| 1 | Treat `restore_cfg.psv` as the authoritative map of HyDE ownership. | Reference established. |
| 2 | Mark every target path as owned, generated, ignored, engine, or obsolete. | In progress. |
| 3 | Move session-critical files to chezmoi first. | Done for UWSM. |
| 4 | Move shell files next; stop `restore_shl.sh`. | Done for zsh/fish startup ownership; restore risk remains if HyDE scripts are run. |
| 5 | Keep visual generated files ignored until stable config/generated include boundaries exist. | Active; kitty follows this pattern. |
| 6 | Stop using HyDE install/restore scripts in the daily workflow. | Pending and high priority. All stable config is now chezmoi-owned; HyDE restore remains the only mechanism that can overwrite `.config` files. |
| 7 | Keep, rename, or wrap HyDE state/cache/libs according to engine needs. | In progress: `~/.local/state/hyde` and `~/.config/hyde/config.toml` were removed; runtime state now lives under `state/hypr` and `state/waybar`, while engine artifacts moved under `lib/hyde`. |
