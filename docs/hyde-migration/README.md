# HyDE Migration Map

> Purpose: split HyDE into small, owned pieces so the stable config surface is controlled by chezmoi while HyDE can remain as the runtime/theme engine.

This directory complements `docs/hyde-architecture.md`. That file remains the compact reference for Hyprland/theming. These files are area-by-area migration notes based on `/home/buble/dev/projects/HyDE`.

## Ownership Boundary

The goal is not to remove `~/.local/lib/hyde` or ban `hyde-shell` calls. HyDE can stay as an engine for runtime helpers, theme refresh, generated outputs, and app/service wrappers.

The real boundary is ownership:

| Surface | Desired owner | Rule |
|---------|---------------|------|
| `~/.config/hypr`, `~/.config/fish`, `~/.config/kitty`, `~/.config/zsh` | User / chezmoi | Stable config structure is authored here, not restored from HyDE. |
| Generated Hypr state | HyDE engine for now | Generated Hypr artifacts live in `$XDG_STATE_HOME/hypr`, not in `.config`. They are runtime state and stay out of chezmoi. |
| Wallbash templates | User / chezmoi | `~/.local/share/hyde/wallbash` is now the owned template source that tells HyDE where to write generated app/theme outputs. |
| `~/.local/lib/hyde`, `hyde-shell` | Runtime engine to appropriate | Calls are acceptable if they are chosen by owned config. Rename/wrap later only if useful. |
| HyDE install/restore scripts | Avoid in daily workflow | They can overwrite user-owned `.config` paths and are the main ownership risk. |

## Areas

| Area | Doc | Why it matters for decoupling |
|------|-----|--------------------------------|
| Theme and wallbash | `theme-wallbash.md` | Own color extraction, theme switching, generated app themes, wallpaper behavior. |
| Session and services | `session-services.md` | Replace `hyde-shell app`, transient systemd units, UWSM env, startup daemons. |
| Shells | `shells.md` | Own zsh/fish load order, aliases, prompt, completions, package aliases. |
| Runtime scripts | `runtime-scripts.md` | Replace `hyde-shell`, keybinding commands, package manager wrapper, helper scripts. |
| Install and ownership | `install-ownership.md` | Translate HyDE restore/install model into chezmoi ownership. |

## Safe Migration Order

| Stage | Goal | Current status | Main risk if skipped |
|-------|------|----------------|----------------------|
| 1 | Keep owning `~/.config/hypr/hyprland/` via chezmoi. | Done for Lua config. | Stock HyDE `.conf` config can regain control. |
| 2 | Own UWSM env files. | Done: split into semantic env/toolkit/compositor/dev files. | Wrong `HYPRLAND_CONFIG`, missing GPU/Wayland vars. |
| 3 | Decide whether startup service launches stay on `hyde-shell app` or become owned units/wrappers. | Done for now: `hyde-shell` is an accepted runtime engine API. | Service lifecycle stays implicit in HyDE conventions. |
| 4 | Make keybinding launch commands intentional. | Done for now: `hyde-shell` calls are accepted runtime engine API calls. | Owned keybindings still delegate to HyDE commands without an explicit contract. |
| 5 | Decouple zsh/fish config ownership. | Done: zsh/fish startup uses owned modules; HyDE runtime aliases remain intentional. | Shell startup can still be dictated by HyDE-owned loaders. |
| 6 | Own theme/wallpaper config boundaries. | In progress: Hypr generated outputs moved to state; Wallbash templates are in chezmoi; Kitty boundary done. | App colors and GTK/Qt settings stop updating or overwrite stable config. |
| 7 | Remove install/restore coupling. | Pending. | Future HyDE restore can overwrite user-owned configs. |
| 8 | Appropriate or rename HyDE runtime surface. | Optional/later. | Names remain HyDE-branded even if the engine is effectively yours. |

## Do Not Remove Until Replaced Or Appropriated

| Dependency surface | Replaces |
|--------------------|----------|
| `~/.config/uwsm/env*` | Session env, GPU detection, `HYPRLAND_CONFIG`. |
| `hyde-shell app` / `app2unit.sh` | systemd/UWSM lifecycle for daemons and app scopes. |
| `hyde-shell open` / `hyde-shell app -T` | Terminal, browser, editor, file-manager launch defaults. |
| `wallpaper.sh --start --global` | Wallpaper apply plus theme/wallbash refresh. |
| `theme.switch.sh` and `color.set.sh` | GTK/Qt/Hyprland/app color propagation. |
| `restore_cfg.psv` knowledge | Which files HyDE overwrites, preserves, or generates. |

These surfaces may remain if they are treated as engine APIs. The migration task is to stop them from owning stable `.config` files by restore/sync side effects.

## Current Corrections To Previous Assumptions

| Previous assumption | Verified behavior |
|---------------------|-------------------|
| Wallbash uses `wallust`. | It uses ImageMagick `magick` and custom shell logic in `wallbash.sh`. |
| `~/.local/share/hyde/` contains scripts. | Runtime scripts live mostly in `~/.local/lib/hyde/`; `~/.local/share/hyde/` is data/templates. |
| UWSM only imports `HYPRLAND_CONFIG`. | HyDE stock ships `env-hyprland.d/00-hyde.sh`, but this repo now owns semantic UWSM env files. |
| `hyde-shell app` is a large service manager. | It delegates to `app2unit.sh`, which wraps `systemd-run --user`. |
| Shell config is mostly user-owned. | Many zsh/fish dirs are `S` sync entries in `restore_cfg.psv`, so HyDE restore overwrites them. |
| Generated Hypr files belong in `.config`. | They are state and now live under `$XDG_STATE_HOME/hypr`. |
| `hyprland/style/*.lua` should parse generated files directly. | State consumption is under `hyprland/scripts/*`; `style/*` applies Hypr config. |

## Current Progress Snapshot

| Area | Status | Notes |
|------|--------|-------|
| Kitty | Mostly owned | `kitty.conf` and `defaults_from_hyde.conf` are chezmoi-managed; `autogenerated_theme.conf` remains HyDE-generated and ignored. |
| Fish | Owned startup | `conf.d/*.fish` are owned files; remaining `hyde-shell pm` aliases/completion are accepted runtime calls, not ownership blockers. |
| Zsh | Owned startup | `~/.zshenv`, `~/.config/zsh/.zshenv`, `.zshrc`, and `conf.d` modules are owned; HyDE terminal startup was removed. |
| Hyprland Lua | Owned | `.config/hypr/hyprland/*.lua` is controlled by chezmoi. Runtime calls can still use HyDE intentionally. |
| Hypr generated state | Owned boundary, HyDE generated | HyDE writes `$XDG_STATE_HOME/hypr/*`; `hypr/scripts/*` reads it; stable config no longer tracks `autogenerated_files`. |
| Hypr runtime state | Domain-owned | `~/.local/state/hypr/staterc` stores Hypr selections; `~/.local/state/hypr/hyprsunset` stores blue-light state. No `~/.local/state/hyde` directory is used. |
| Waybar runtime state | Domain-owned | `~/.local/state/waybar/staterc` stores layout/style selections plus local Waybar values such as `WAYBAR_SCALE`. |
| Wallbash templates | Owned | `~/.local/share/hyde/wallbash/**` is in chezmoi; app-specific templates/scripts from `~/.config/hyde/wallbash` were merged into this canonical path. |
| `hyde-shell` entrypoint | Tracked | `~/.local/bin/hyde-shell` now managed via `home/dot_local/bin/executable_hyde-shell`. |
| UWSM env | Owned | Split by semantic responsibility (paths, tool-config, compositor, toolkits, gpu, dev). |
| Startup/services | Runtime engine API | Still delegates heavily to `hyde-shell app`; this is intentional while `hyde-shell` remains the runtime boundary. |
| Install/restore | Risk | HyDE restore/install remains the main threat to config ownership. |

## Remaining Work

| Area | What is still pending | Priority |
|------|-----------------------|----------|
| Install/restore | Stop using HyDE `restore_cfg.sh` / `restore_shl.sh` in daily workflow. This is the only remaining mechanism that can overwrite owned `.config` files. | 🔴 HIGH |
| Opaque binaries | `hydectl`, `hyde-ipc` remain opaque. `hyde-config` and `~/.config/hyde/config.toml` are no longer part of startup/config flow. | 🟡 MEDIUM |
| Theme engine | `wallbash.sh` (color extraction) still HyDE-owned. Decide keep or replace with `pywal`/`matugen`. `theme.switch.sh` still HyDE-owned. Optional replacement. | 🟢 LOW |
| Wallpaper backend | `wallpaper.sh` routes between swww/hyprpaper/mpvpaper. Could go direct if only one backend is used. | 🟢 LOW |
| Branding rename | Optional: rename `hyde-shell` wrapper, rename `70-hyde.zsh`/`90-hyde.fish`, rename UWSM files. Not required for ownership. | 🟢 OPTIONAL |
