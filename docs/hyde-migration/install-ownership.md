# Install And Ownership Migration

> Goal: translate HyDE's installer/restore model into explicit chezmoi ownership.

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
| UWSM | `S` sync for `~/.config/uwsm/env*`. | Take ownership early; session-critical. |
| Hyprland Lua/conf | Mixed `P` and `S`. | Already mostly chezmoi-owned; keep control. |
| Shell | zsh/fish core dirs mostly `S`; user stubs `P`. | Take ownership and stop HyDE restore from touching them. |
| Kitty | `kitty.conf` preserved; `hyde.conf`/`theme.conf` sync/generated. | Keep user config, generate/include theme separately. |
| Waybar | config/style mostly preserved; modules/shared scripts partly ignored/synced. | Own layout; leave color include generated until replacement. |
| Dunst | `S` sync plus wallbash rewrite. | Split static config from generated colors. |
| GTK/Qt/Kvantum | `S` sync and theme switch partial rewrites. | Own after theme replacement. |
| Rofi/wlogout | Rofi preserved, wlogout synced. | Own when replacing launchers/theme. |
| HyDE libs/bins | `O` overwrite for `~/.local/bin`, `~/.local/lib/hyde`, `~/.local/share/hyde`. | Remove last; many commands depend on them. |

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
| 5 | Stop running HyDE restore scripts once chezmoi owns the same paths. |
| 6 | Record external packages in `docs/ecosystem.md` when adding install scripts. |

## Files To Audit Before Removing HyDE

| Path | Why |
|------|-----|
| `~/.config/hyde/config.toml` | User-level HyDE config. |
| `~/.local/state/hyde/staterc` | Runtime state such as wallbash mode/current theme. |
| `~/.local/state/hyde/config` | Generated config state used by HyDE scripts. |
| `~/.cache/hyde/` | Wallpaper thumbnails, dcol cache, logs. |
| `~/.config/cfg_backups/` | Installer backups that may contain old user edits. |
| `~/.local/lib/hyde/` | Runtime scripts used by keybindings and startup. |
| `~/.local/bin/hyde-shell`, `hydectl`, `hyde-ipc` | CLI/binary dependencies. |

## Migration Stages

| Stage | Action |
|-------|--------|
| 1 | Treat `restore_cfg.psv` as the authoritative map of HyDE ownership. |
| 2 | Mark every target path as owned, generated, ignored, or obsolete. |
| 3 | Move session-critical files to chezmoi first. |
| 4 | Move shell files next; stop `restore_shl.sh`. |
| 5 | Keep visual generated files ignored until `theme-wallbash.md` replacement is ready. |
| 6 | Remove HyDE install/restore scripts from your workflow. |
| 7 | Delete HyDE state/cache/libs only after runtime grep shows no calls. |
