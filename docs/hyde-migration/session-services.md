# Session And Services Migration

> Goal: boot Hyprland, set the session env, and start desktop daemons without relying on `hyde-shell app`.

## Entry Chain

```
uwsm start hyprland
  -> ~/.config/uwsm/env
  -> ~/.config/uwsm/env.d/*.sh
  -> ~/.config/uwsm/env-hyprland
  -> ~/.config/uwsm/env-hyprland.d/*.sh
  -> HYPRLAND_CONFIG must point at the intended Hyprland entrypoint
  -> In this repo that entrypoint is ~/.config/hypr/hyprland.lua
  -> hyde/startup.lua starts services
```

The Lua config path bypasses the older `.conf` `CONFIG_ALREADY_LOADED` branch. For this migration, `HYPRLAND_CONFIG` is the key switch: HyDE stock points at `$XDG_DATA_HOME/hypr/hyprland.conf`, while this dotfiles repo needs the Lua entrypoint.

## UWSM Env Files To Own

| File | Important values |
|------|------------------|
| `Configs/.config/uwsm/env` | Sources `env.d/*.sh`; sets `APP2UNIT_SLICES`, `APP2UNIT_TYPE`. |
| `Configs/.config/uwsm/env.d/00-hyde.sh` | `PATH`, `LESSHISTFILE`, `PARALLEL_HOME`, `SCREENRC`. |
| `Configs/.config/uwsm/env.d/01-gpu.sh` | Detects AMD/Intel/Nouveau/NVIDIA and sets GL/VAAPI vars. |
| `Configs/.config/uwsm/env-hyprland` | Sources `env-hyprland.d/*.sh`. |
| `Configs/.config/uwsm/env-hyprland.d/00-hyde.sh` | `QT_*`, `MOZ_ENABLE_WAYLAND`, `GDK_SCALE`, `ELECTRON_OZONE_PLATFORM_HINT`, stock `HYPRLAND_CONFIG`, `HYPRLAND_NO_SD_NOTIFY`, `HYPRLAND_NO_SD_VARS`. |

Take ownership of these before uninstalling HyDE. Rename them later if wanted, but preserve behavior first and override stock `HYPRLAND_CONFIG` to the Lua entrypoint used by this repo.

## Startup Services

Actual startup is in `~/.config/hypr/hyprland/hyde/startup.lua` in the chezmoi-managed config, based on HyDE stock behavior.

| Service | Current command | Replacement direction |
|---------|-----------------|-----------------------|
| Portal reset | `hyde-shell resetxdgportal.sh` | Own small script or drop if stable. |
| Polkit | `hyde-shell app -t service -- polkitkdeauth.sh` | Direct systemd user service or `systemd-run`. |
| Waybar | `hyde-shell app ... -- waybar.py --watch` | Direct `waybar` or own wrapper. |
| Notifications | `hyde-shell app ... -- dunst` | User systemd service for `dunst`. |
| Wallpaper | `hyde-shell app ... -- wallpaper.sh --start --global` | Direct wallpaper backend, or owned theme pipeline. |
| Clipboard text | `wl-paste --type text --watch cliphist store` | User systemd service. |
| Clipboard image | `wl-paste --type image --watch cliphist store` | User systemd service. |
| Network tray | `nm-applet --indicator` | User systemd service or `exec-once`. |
| Media tray | `udiskie --no-automount --smart-tray` | User systemd service or `exec-once`. |
| Bluetooth tray | `blueman-applet` | User systemd service or `exec-once`. |
| Battery notify | `batterynotify.sh` | Replace if used; otherwise drop. |
| Idle | `hypridle` | User systemd service. |
| Blue light | `hyprsunset` | User systemd service. |
| HyDE config | `hyde-config --no-startup` | Investigate before dropping; likely HyDE-specific. |

## `hyde-shell app` Contract

| Layer | File | Behavior |
|-------|------|----------|
| CLI | `Configs/.local/bin/hyde-shell` | `app)` delegates to `app2unit.sh`. |
| Wrapper | `Configs/.local/lib/hyde/app2unit.sh` | Converts command into `systemd-run --user` service/scope. |
| Backend | systemd user | Units are tied to graphical session target/slices. |

Use `uwsm app` where possible. If not, a small `systemd-run --user --scope` or user service is enough for most daemons.

## Env Propagation

| Layer | Behavior |
|-------|----------|
| UWSM | Sets session env before Hyprland. These values win. |
| `env.lua` | Uses `env_if_unset()` for most vars, but force-prepends `~/.local/bin` and `~/.local/lib/hyde` to `PATH`. |
| `startup.lua` | Calls `dbus-update-activation-environment` and `systemctl --user import-environment` for Wayland/session vars. |

When removing HyDE, preserve env propagation in UWSM or systemd user services can start with missing `WAYLAND_DISPLAY`/desktop variables.

## Risks

| Risk | Impact |
|------|--------|
| Remove `hyde-shell app` first. | Desktop daemons stop starting. |
| Drop UWSM env files too early. | Hyprland may load wrong config path; GPU/Wayland vars missing. |
| Replace `waybar.py` blindly. | Bar still works with `waybar`, but HyDE-specific watch/theme reload behavior is lost. |
| Drop wallpaper service. | Theme/wallbash refresh no longer runs. |
| Leave `PATH` depending on `~/.local/lib/hyde`. | Scripts work by accident until HyDE lib is removed. |

## Migration Stages

| Stage | Action |
|-------|--------|
| 1 | Copy UWSM env files into chezmoi and verify `HYPRLAND_CONFIG`. |
| 2 | Replace each startup daemon with direct `systemd-run`, `uwsm app`, or real user units. |
| 3 | Change `startup.lua` to call owned scripts/units only. |
| 4 | Remove `~/.local/lib/hyde` from forced `PATH` only after no startup command needs it. |
| 5 | Stop `hyde-config`/`hyde-ipc` only after checking no feature you use depends on them. |
