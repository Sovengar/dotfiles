# HyDE Migration Map

> Purpose: split HyDE into small, owned pieces so it can be replaced gradually without losing working desktop behavior.

This directory complements `docs/hyde-architecture.md`. That file remains the compact reference for Hyprland/theming. These files are area-by-area migration notes based on `/home/buble/dev/projects/HyDE`.

## Areas

| Area | Doc | Why it matters for decoupling |
|------|-----|--------------------------------|
| Theme and wallbash | `theme-wallbash.md` | Own color extraction, theme switching, generated app themes, wallpaper behavior. |
| Session and services | `session-services.md` | Replace `hyde-shell app`, transient systemd units, UWSM env, startup daemons. |
| Shells | `shells.md` | Own zsh/fish load order, aliases, prompt, completions, package aliases. |
| Runtime scripts | `runtime-scripts.md` | Replace `hyde-shell`, keybinding commands, package manager wrapper, helper scripts. |
| Install and ownership | `install-ownership.md` | Translate HyDE restore/install model into chezmoi ownership. |

## Safe Migration Order

| Stage | Goal | Main risk if skipped |
|-------|------|----------------------|
| 1 | Keep owning `~/.config/hypr/hyprland/` via chezmoi. | Stock HyDE `.conf` config can regain control. |
| 2 | Own UWSM env files before removing HyDE packages. | Wrong `HYPRLAND_CONFIG`, missing GPU/Wayland vars. |
| 3 | Replace startup service launches. | No waybar, dunst, wallpaper, clipboard, idle daemon, tray applets. |
| 4 | Replace keybinding launch commands. | `$TERMINAL`, `$BROWSER`, screenshots, lock, rofi helpers break. |
| 5 | Decouple zsh/fish. | `hyde-shell pm`, HyDE completions, OMZ setup, prompt setup remain coupled. |
| 6 | Replace theme/wallpaper pipeline. | App colors and GTK/Qt settings stop updating. |
| 7 | Remove install/restore coupling. | Future HyDE restore can overwrite user-owned configs. |
| 8 | Remove HyDE binaries/cache/state. | Only safe after no runtime path calls `hyde-shell`, `hydectl`, `hyde-ipc`, or scripts under `~/.local/lib/hyde`. |

## Do Not Remove Until Replaced

| Dependency surface | Replaces |
|--------------------|----------|
| `~/.config/uwsm/env*` | Session env, GPU detection, `HYPRLAND_CONFIG`. |
| `hyde-shell app` / `app2unit.sh` | systemd/UWSM lifecycle for daemons and app scopes. |
| `hyde-shell open` / `hyde-shell app -T` | Terminal, browser, editor, file-manager launch defaults. |
| `wallpaper.sh --start --global` | Wallpaper apply plus theme/wallbash refresh. |
| `theme.switch.sh` and `color.set.sh` | GTK/Qt/Hyprland/app color propagation. |
| `restore_cfg.psv` knowledge | Which files HyDE overwrites, preserves, or generates. |

## Current Corrections To Previous Assumptions

| Previous assumption | Verified behavior |
|---------------------|-------------------|
| Wallbash uses `wallust`. | It uses ImageMagick `magick` and custom shell logic in `wallbash.sh`. |
| `~/.local/share/hyde/` contains scripts. | Runtime scripts live mostly in `~/.local/lib/hyde/`; `~/.local/share/hyde/` is data/templates. |
| UWSM only imports `HYPRLAND_CONFIG`. | HyDE ships `env-hyprland.d/00-hyde.sh`, which sets `HYPRLAND_CONFIG` directly. |
| `hyde-shell app` is a large service manager. | It delegates to `app2unit.sh`, which wraps `systemd-run --user`. |
| Shell config is mostly user-owned. | Many zsh/fish dirs are `S` sync entries in `restore_cfg.psv`, so HyDE restore overwrites them. |
