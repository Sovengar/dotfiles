# Session And Services Migration

> Goal: boot Hyprland, set the session env, and start desktop daemons through an explicit owned contract. `hyde-shell app` may remain if it is the chosen engine API.

Current status: service startup still delegates heavily to `hyde-shell app`. This is intentional while `hyde-shell` and `~/.local/lib/hyde` are the accepted runtime boundary. The ownership issue is restore/install side effects, not the command name.

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
| `Configs/.config/uwsm/env.d/00-paths.sh` | User-local PATH setup. |
| `Configs/.config/uwsm/env.d/01-gpu.sh` | Detects AMD/Intel/Nouveau/NVIDIA and sets GL/VAAPI vars. |
| `Configs/.config/uwsm/env.d/10-tool-config.sh` | `LESSHISTFILE`, `PARALLEL_HOME`, `SCREENRC`. |
| `Configs/.config/uwsm/env-hyprland` | Sources `env-hyprland.d/*.sh`. |
| `Configs/.config/uwsm/env-hyprland.d/00-compositor.sh` | `HYPRLAND_CONFIG`, `HYPRLAND_NO_SD_NOTIFY`, `HYPRLAND_NO_SD_VARS`. |
| `Configs/.config/uwsm/env-hyprland.d/10-toolkits.sh` | `QT_*`, `MOZ_ENABLE_WAYLAND`, `GDK_SCALE`, `ELECTRON_OZONE_PLATFORM_HINT`. |

These are owned by chezmoi and split by semantic responsibility. They preserve the required behavior and override stock `HYPRLAND_CONFIG` to the Lua entrypoint used by this repo.

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

`hyde-shell app` is the accepted app lifecycle engine for now. Avoid depending on HyDE restore to manage config files.

## Env Propagation

| Layer | Behavior |
|-------|----------|
| UWSM | Sets session env before Hyprland. These values win. |
| `env.lua` | Uses `env_if_unset()` for most vars, but force-prepends `~/.local/bin` and `~/.local/lib/hyde` to `PATH`. |
| `startup.lua` | Calls `dbus-update-activation-environment` and `systemctl --user import-environment` for Wayland/session vars. |

When changing or wrapping the HyDE engine, preserve env propagation in UWSM or systemd user services can start with missing `WAYLAND_DISPLAY`/desktop variables.

## Risks

| Risk | Impact |
|------|--------|
| Drop or rename `hyde-shell app` while it is the accepted runtime boundary. | Desktop daemons stop starting. |
| Drop UWSM env files too early. | Hyprland may load wrong config path; GPU/Wayland vars missing. |
| Replace `waybar.py` blindly. | Bar still works with `waybar`, but HyDE-specific watch/theme reload behavior is lost. |
| Drop wallpaper service. | Theme/wallbash refresh no longer runs. |
| Leave `PATH` depending on `~/.local/lib/hyde` implicitly. | Scripts work by accident instead of through an explicit engine path/wrapper. |

## Migration Stages

| Stage | Action | Status |
|-------|--------|--------|
| 1 | Copy UWSM env files into chezmoi and verify `HYPRLAND_CONFIG`. | Done: UWSM env is owned and split semantically. |
| 2 | Decide per daemon: keep `hyde-shell app`, wrap it, use `uwsm app`, or create user units. | Done for now: keep `hyde-shell app` as runtime API. |
| 3 | Change `startup.lua` to call only owned decisions: direct commands, wrappers, or accepted HyDE engine calls. | Done for now: startup uses accepted runtime calls. |
| 4 | Remove implicit `~/.local/lib/hyde` PATH reliance only after an explicit engine path/wrapper exists. | Done enough: `hyde-shell` is tracked as explicit runtime entrypoint. |
| 5 | Keep `hyde-config`/`hyde-ipc` until checking which theme/config features depend on them. | Pending. |
