# HyDE Theming Framework — Architecture Reference

> Target audience: someone who wants to understand HyDE deeply so they can own/replace it.

> Migration docs: see `docs/hyde-migration/` for area-by-area decoupling notes. This file remains the compact Hyprland/theme reference.

## Core Architecture

HyDE is a theming framework for Hyprland. Its config/runtime is split across source directories with different ownership:

| Directory | Owner | Contents |
|-----------|-------|----------|
| `~/.local/share/hyde/` | HyDE package (read-only) | Data/templates such as env-theme and rofi/theme assets |
| `~/.local/lib/hyde/` | HyDE package (read-only) | Runtime scripts: `hyde-shell` delegates here for wallpaper, theme, app/service, rofi, screenshot, waybar |
| `~/.config/hypr/hyprland/` | **User / chezmoi** | LUA-based config that replaces stock via `CONFIG_ALREADY_LOADED` |
| `~/.config/hyde/themes/` | HyDE `hyde-shell` | Each theme is a subdir: `Rosé Pine/`, `Catppuccin Mocha/`, etc. |
| `~/.config/hyde/wallbash/` | User templates | Dcol templates + post-processing scripts |
| `~/.config/hypr/themes/` | **Auto-generated** | `colors.conf`, `wallbash.conf`, `theme.conf` — regenerated on EVERY theme switch |

## Config Load Order (Include Chain)

```
                  ┌──────────────────────────┐
                  │  CONFIG_ALREADY_LOADED?   │
                  └────────────┬─────────────┘
                               │
              ┌─ NO ──────────┴────────── YES ─┐
              ▼                                 ▼
   ~/.local/share/hyde/              ~/.config/hypr/hyprland/
   (stock configs, skipped         (chezmoi-managed LUA)
    if flag is set)                      │
                              ┌─────────┴──────────┐
                              ▼                    ▼
                    hyde/variables.lua     hyde/wallbash.lua
                    hyde/defaults.lua      hyde_theme.lua
                    hyde/startup.lua       finale.lua
                    hyde/*.lua             animations.lua
                    keybindings.lua        workflows.lua
                    userprefs.lua          monitors.lua
                              │
                              ▼
                    workflows.conf (USER editable)
                              │
                              ▼
                    finale.conf (auto-generated snapshot)
```

## Theme Switch Pipeline

When you change wallpaper or select a new theme (`SUPER+SHIFT+T` or `hyde-shell themeselect`):

```
THEME SWITCH TRIGGERED
        │
        ▼
┌─────────────────────────────────┐
│ 1. WALLBASH: COLOR EXTRACTION    │
│    ImageMagick extracts colors   │
│    with HyDE custom shell logic  │
│    Extract 4 dominant colors     │
│    → Generate 9 accent shades    │
│    → Write ~/.config/hypr/themes/ │
│      colors.conf (hex+rgba)      │
│      wallbash.conf ($GTK_THEME…) │
│      theme.conf (hypr sections)  │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ 2. DCONF TEMPLATE EXPANSION      │
│    For each file in              │
│    ~/.config/hyde/wallbash/      │
│      always/  (runs always)      │
│      theme/   (runs on theme chg)│
│    Replace <wallbash_pry1> with  │
│    actual hex colors             │
│    → $cacheDir/wallbash/         │
│    → Post-process scripts        │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ 3. HYPRLAND RELOAD               │
│    wallbash.lua reads overrides  │
│    hyde_theme.lua reads theme    │
│    finale.lua writes snapshot    │
│    → Colors apply to borders,    │
│      gaps, blur, active/inactive │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│ 4. EXTERNAL APP THEMES           │
│    dunst colors update           │
│    kitty theme reload            │
│    waybar/rofi colors update     │
│    GTK theme/icon theme set      │
│    VS Code theme generated       │
└─────────────────────────────────┘
```

## Files Changed on Theme Switch

### Completely regenerated (entire file replaced)

| File | Source | Risk of losing data |
|------|--------|---------------------|
| `~/.config/hypr/themes/colors.conf` | Wallbash | None (auto-gen) |
| `~/.config/hypr/themes/wallbash.conf` | Wallbash | None (auto-gen) |
| `~/.config/hypr/themes/theme.conf` | Theme dir | None (auto-gen) |
| `~/.config/kitty/theme.conf` | `kitty.theme` in theme dir | None (auto-gen) |
| `~/.config/kitty/hyde.conf` | Wallbash | None (auto-gen) |
| `~/.config/hypr/hyprland/hyde/finale.conf` | finale.lua | None (auto-gen) |
| `~/.config/hypr/hyprland/animations/theme.conf` | `animations --select` | None (auto-gen) |
| `~/.config/hypr/hyprlock/theme.conf` | Lock screen preset | None (auto-gen) |
| `~/.cache/hyde/wallbash/*` | Dcol expansion | None (cache) |

### Partially regenerated (only color variables change, structure preserved)

| File | What changes | What stays |
|------|-------------|------------|
| `~/.config/dunst/dunstrc` | Urgency colors (bg/fg/frame) | corner_radius, icon_theme, dmenu, timeouts, icon path |
| `~/.config/gtk-3.0/settings.ini` | icon-theme-name, gtk-theme-name | font, cursor, scaling, event sounds |
| `~/.config/gtk-4.0` | Symlink target (theme name) | It's just a symlink |
| `~/.config/rofi/theme.rasi` | All color variables (bg/fg/br/ex/select) | Layout, font, border properties |
| `~/.config/waybar/theme.css` | CSS `@define-color` values | All other CSS rules |
| `~/.config/waybar/user-style.css` | Color values | CSS structure |
| `~/.config/qt5ct/qt5ct.conf` | theme/font values | Existing config sections |
| `~/.config/qt6ct/qt6ct.conf` | theme/font values | Existing config sections |
| `~/.config/xsettingsd/xsettingsd.conf` | GTK/icon/cursor values | Other xsettingsd values |
| `~/.gtkrc-2.0` | GTK/icon/cursor values | Other gtkrc values |
| `~/.Xresources`, `~/.Xdefaults` | Xresources color/theme values | Other Xresources values |
| `~/.config/kdeglobals` | KDE/Qt theme values | Other KDE settings |
| `~/.local/share/icons/default/index.theme` | Cursor theme target | File structure |

### NOT regenerated (user-managed)

| File | Notes |
|------|-------|
| `~/.config/hypr/hyprland/keybindings.lua` | User-defined |
| `~/.config/hypr/hyprland/userprefs.lua` | User-defined |
| `~/.config/hypr/hyprland/monitors.lua` | User-defined (monitor layout) |
| `~/.config/hypr/hyprland/workflows.conf` | User-defined (workflow overlays) |
| `~/.config/waybar/config.jsonc` | User-defined (bar layout) |
| `~/.config/kitty/kitty.conf` | User-defined (includes hyde.conf + theme.conf) |
| `~/.config/hyde/wallbash/always/*` | User templates (dcol) |

## Dependency Chain

### From wallpaper to screen:

```
wallpaper (image file)
    │
    ▼
ImageMagick `magick` + HyDE `wallbash.sh`
    │  → 4 dominant colors × 9 accent shades
    ▼
colors.conf (hex values)
    │
    ├──→ hyde_theme.lua  →  hyprland: borders, gaps, blur, active_window
    ├──→ wallbash.lua    →  variables: GTK_THEME, ICON_THEME, cursor, fonts
    ├──→ dcol templates  →  VS Code theme, cava, Spotify, Discord, Chrome
    │
    ▼
kitty/theme.conf  →  kitty terminal colors
rofi/theme.rasi   →  launcher colors
waybar/theme.css  →  bar colors
dunst/dunstrc     →  notification colors
```

### Application startup chain:

**Without UWSM (direct Hyprland launch):**

```
hyprland starts
    │
    ▼
hyde/startup.lua
    ├── polkit
    ├── waybar (hyprland-bar.scope)
    ├── dunst (hyprland-notifications.service)
    ├── wallpaper (wallpaper.service)
    ├── cliphist (clipboard manager)
    ├── nm-applet / blueman-applet / udiskie
    └── hypridle / hyprsunset
```

**With UWSM (bootstrapped via systemd user session):**

```
uwsm (systemd user session)
    ├── Sets environment variables (overrides shell config)
    ├── Imports env from PAM + systemd user manager
    └── Starts Hyprland as a managed user unit
            │
            ▼
    hyde/startup.lua
        ├── Each service is a systemd unit with
        │   implicit Wants=uwsm-mainston.service
        ├── dbus-update-activation-environment
        │   competes with uwsm's own env mgmt
        └── (same app list as above)
```

## UWSM Integration

[UWSM (Universal Wayland Session Manager)](https://github.com/Vladimir-csp/uwsm) bootstraps Hyprland as a systemd user unit. It sits between the display manager / TTY login and Hyprland itself.

### What UWSM changes

| Aspect | Without UWSM | With UWSM |
|--------|-------------|-----------|
| **Entry point** | `Hyprland` called from shell/login | `uwsm start hyprland` via systemd |
| **Env vars** | Set by shell init + `hyde/startup.lua` | Set by UWSM (PAM → systemd); overrides shell config |
| **Service lifecycle** | `hyde-shell app` creates scopes manually | Units implicitly `Wants=uwsm-mainston.service` |
| **dbus activation** | `dbus-update-activation-environment` in startup.lua | UWSM handles dbus env propagation |

### Environment variable conflict

`~/.config/zsh/conf.d/hyde/env.zsh` sets XDG variables, but under UWSM:

```
login → PAM → uwsm sets env → shell init runs (overridden by uwsm) → hyprland starts
```

This means `env_if_unset()` in `hyde/env.lua` may receive values already locked by UWSM, making the zsh env file ineffective for Wayland session vars. The `env.zsh` comment acknowledges this explicitly.

### Service unit implications

Services started by `startup.lua` via `hyde-shell app -u <unit>` generate systemd units. Under UWSM:

- Units should declare `Wants=uwsm-mainston.service` for proper ordering
- `systemctl --user import-environment` may be redundant since UWSM already imports from the user manager
- Units that depend on `$WAYLAND_DISPLAY` rely on UWSM propagating it correctly — if UWSM's env import order changes, those services may start before the compositor is ready

### Migration notes

- `hyde-shell app -t scope` → `uwsm app` (manages app lifecycle with UWSM awareness)
- `hyde-shell app -t service` → systemd user unit with `Wants=uwsm-mainston.service`
- `dbus-update-activation-environment` calls in `startup.lua` are partially redundant under UWSM but harmless
- `HYPRLAND_CONFIG` env var behavior depends on whether UWSM imports it from the user environment

## hyde-shell: Central Orchestrator

All theme operations funnel through `hyde-shell`. It's a shell script at `~/.local/lib/hyde/hyde-shell`.

| Command | Action |
|---------|--------|
| `hyde-shell themeselect` | Open theme selector (rofi) |
| `hyde-shell wallpaper` | Change wallpaper |
| `hyde-shell wallbashtoggle -m` | Toggle dark/light mode |
| `hyde-shell animations --select` | Select animation preset |
| `hyde-shell workflows --select` | Select workflow overlay |
| `hyde-shell hyprlock --select` | Select lock screen preset |
| `hyde-shell wbarconfgen n` | Regenerate waybar config for N monitors |
| `hyde-shell app` | Run app with systemd scope management |

## How to Replace HyDE

### Phase 1: Config ownership (you're already here)

You already own `~/.config/hypr/hyprland/` via chezmoi. The LUA config system IS the replacement mechanism. `CONFIG_ALREADY_LOADED` bypasses stock configs.

### Phase 2: Theme engine replacement

To own theme switching without `hyde-shell`:

1. **Color extraction**: Replace HyDE's ImageMagick-based `wallbash.sh` with `pywal`, `matugen` (Material You), or your own script
2. **Theme application**: Instead of wallbash templates, use your own scripts that write colors to target files
3. **Variables**: Move theme settings from `wallbash.conf` into chezmoi data

### Phase 3: Hyde-shell replacement

Replace `hyde-shell` calls in `keybindings.lua` with direct commands or your own wrapper:

| hyde-shell call | Replace with |
|----------------|-------------|
| `hyde-shell app` | `systemd-run --user --scope` or `uwsm app` (UWSM-aware) |
| `hyde-shell themeselect` | Your own theme picker script |
| `hyde-shell wallpaper` | `hyprctl hyprpaper wallpaper`, `swaybg`, etc. |
| `hyde-shell animations --select` | Your own animation preset loader |
| `hyde-shell lock-session` | `loginctl lock-session` |
| `hyde-shell screenshot s` | `grim`, `slurp` |
| `hyde-shell window.pin` | `hyprctl dispatch pin` |

### What's valuable in HyDE and hard to replicate

- **Dcol template system**: The `<wallbash_pry1>` → hex replacement pipeline is elegant. You'd need to reimplement or simplify it.
- **Systemd scope management**: `hyde-shell app` wraps daemons with proper lifecycle. Under UWSM, `uwsm app` handles this natively. Raw `systemctl --user` also works but loses UWSM integration.
- **Theme directory structure**: Each theme is a portable directory. You'd define your own format.
- **Animation presets**: 18+ curated presets. You can keep the `.conf` files but replace the selection UI.

### What's NOT worth replicating

- **Wallbash cache** (`~/.cache/hyde/`): Pure ephemera. Regenerate on demand.
- **Dcol post-process scripts**: Most just call `pkill -USR2` or rewrite a JSON file.
- **HyDE color extractor**: Replace `wallbash.sh` with any color extraction tool if exact HyDE palette matching is not required.

## Current chezmoi strategy

| Category | Managing? | Why |
|----------|-----------|-----|
| `~/.config/hypr/hyprland/*.lua` | ✅ Yes | User owns these via LUA config |
| `~/.config/kitty/kitty.conf` | ✅ Yes | User structure (includes hyde) |
| `~/.config/dunst/dunstrc` | ❌ Ignored | Theme changes colors via Hyde |
| `~/.config/gtk-3.0/settings.ini` | ❌ Ignored | Theme changes GTK/icon theme |
| `~/.config/gtk-4.0` | ❌ Ignored | Theme changes symlink |
| `~/.config/kitty/theme.conf` | ❌ Ignored | Entirely Hyde-regenerated |
| `~/.config/kitty/hyde.conf` | ❌ Ignored | Entirely Hyde-regenerated |
| `~/.config/rofi/theme.rasi` | ❌ Ignored | Theme changes colors |
| `~/.config/waybar/theme.css` | ❌ Ignored | Theme changes colors |
| `~/.config/rclone/rclone.conf` | ✅ Yes | Accept diff noise from token refresh |

> NOTE: The "ignored" files are excluded from chezmoi via `.chezmoiignore`. On fresh install, HyDE's stock configs or `hyde-shell` commands will recreate them. If you plan to remove HyDE, you'll need to provide your own versions of these before removing `.chezmoiignore` entries.
