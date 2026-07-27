# HyDE — Agent Guide

HyDE (Hyprland Desktop Environment) shell scripts and Python utilities at `~/.local/lib/hyde/`.
All scripts are run through `hyde-shell <name>` (no extension), e.g. `hyde-shell theme.switch`.

## Architecture

Mixed Bash (69 files) / Python (16 files) / Lua (1 file) codebase. No build step.

**Shell init pattern** — every `.sh` script does one of:
- `[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"` (modern)
- `scrDir=$(dirname "$(realpath "$0")"); source "$scrDir/globalcontrol.sh"` (legacy)

**Python** runs via the venv at `python_env/`, managed by `uv`. Python scripts import from `pyutils/` and must use `hyde-shell <script>` which activates the venv automatically.

**State files** — HyDE persists runtime state in:
- `$HYPR_STATE_HOME/hyde.conf` — core state (`HYDE_THEME`, `enableWallDcol`)
- `$HYPR_STATE_HOME/animation.conf` — current animation preset (`HYPR_ANIMATION`)
- `$HYPR_STATE_HOME/workflow.conf` — current workflow (`HYPR_WORKFLOW`)
- `$HYPR_STATE_HOME/hyprlock.conf` — lock screen layout (`HYPRLOCK_LAYOUT`)
- `$HYPR_STATE_HOME/shader.conf` — screen shader (`HYPR_SHADER`)
- `$HYPR_STATE_HOME/weather.conf` — weather preferences (`WEATHER_*`)
- `$WAYBAR_STATE_HOME/staterc` — Waybar layout/style choices

**Config hierarchy** (highest → lowest priority):
1. `~/.config/hyde/` (`$HYDE_CONFIG_HOME`) — user overrides
2. `~/.config/hypr/` — Hyprland config + window rules
3. `~/.local/share/hyde/` (`$HYDE_DATA_HOME`) — themes, wallbash templates, data
4. `~/.cache/hyde/` (`$HYDE_CACHE_HOME`) — dcol cache, thumbs, wallpaper hashes
5. `~/.local/lib/hyde/` (`$LIB_DIR/hyde`) — THIS REPO, the engine

## What to edit for what

| Want to… | Edit files in… |
|---|---|
| Change theming pipeline (colors from wallpaper) | `wallbash.sh`, `color/` (`color.set.sh`, `color/dconf.sh`, `color/hypr.sh`), `wallpaper/cache.sh` |
| Add/modify wallpaper backends | `wallpaper.sh`, `wallpaper/` (`core.sh`, `select.sh`, `help.sh`, `cache.sh`) |
| Add wallpaper backend (swww, hyprpaper, etc.) | Create `wallpaper.<backend>.sh` (see `wallpaper.swww.sh`, `wallpaper.mpvpaper.sh` as templates) |
| Modify theme switching / variable loading | `theme.switch.sh`, `themeselect.sh`, `themeswitch.sh`, `globalcontrol.sh` |
| Add theme import sources | `theme.import.py` (gallery), `theme.select.sh`, `theme.patch.sh` |
| Change waybar layout/style selection | `waybar.py`, `wbarconfgen.sh`, `wbarstylegen.sh` |
| Modify media player widget | `mediaplayer.py` |
| Change bar/control keybinds hints | `keybinds_hint.sh`, `keybinds/hint-hyprland.py` |
| Add game launcher backends (steam, lutris) | `gamelauncher/` (`steam.py`, `lutris.py`, `catalog.py`) and `gamelauncher.sh` |
| Change screenshot/clipboard/OCR behavior | `screenshot.sh`, `screenshot/grimblast`, `cliphist.sh`, `cliphist.image.py`, `shutils/ocr.sh`, `shutils/qr.sh` |
| Modify session save/restore | `session.py`, `session/` (`manager.py`, `compositor/`, `plugins/`) |
| Add compositor backend (hyprland, niri) | `session/compositor/` — implement `SessionBackend` protocol, add to `detect()` |
| Add session plugin (brave, code, kitty) | `session/plugins/` — see existing plugin pattern |
| Change volume/brightness controls | `volumecontrol.sh`, `brightnesscontrol.sh` |
| Modify notifications | `notifications.py` |
| Change lockscreen/logout behavior | `lockscreen.sh`, `logoutlaunch.sh`, `hyprlock.sh` |
| Add package manager support | `pm.py` + `pm/` (one file per manager: `pacman.py`, `apt.py`, `dnf.py`, etc.) |
| Change GPU info display | `amdgpu.py` (AMD), `gpuinfo.sh` (generic) |
| Modify system monitor/update | `system.monitor.sh`, `system.update.sh`, `sysmonlaunch.sh` |
| Change window management helpers | `window.pin.sh`, `window.mute.py`, `hypr.unbind.sh`, `hypr.altab.lua` |
| Add rofi menus | `rofi.bookmarks.sh`, `rofi.websearch.sh`, `rofiselect.sh`, `rofilaunch.sh` |
| Change weather applet | `weather.py` |
| Configure hyprsunset/eye care | `hyprsunset.sh`, `shaders.sh` |
| Add Bash CLI arg parsing | `shutils/argparse.sh` (shared parser for all `.sh` scripts) |
| Add Python utility modules | `pyutils/` (`compositor.py`, `logger.py`, `python_env.py`, `xdg_base_dirs.py`, `wrapper/`) |
| Add Python GUI tools | `pygui/` (currently `color.shuffle.py`) |
| Modify Lua runtime | `luautils/require.lua`, `hypr.altab.lua` |
| Change app launching / MIME handling | `open.sh`, `app2unit.sh`, `xdg-terminal-exec` |
| Font handling | `font.sh` |
| Fastfetch config | `fastfetch.sh` |
| CPU/sensors info | `cpuinfo.sh`, `sensorsinfo.py` |
| Battery notifications | `batterynotify.sh`, `battery.sh` |

## Shell conventions

- **Indent**: 4 spaces (per `.editorconfig`), NOT tabs
- **`set -eu`** on pure POSIX `.sh` scripts (e.g. `pm.sh`)
- **Init guard**: `[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"` at top
- **Logging**: `print_log -sec "tag" -stat "label" "message"` or `print_log -err "ERROR:" "msg"`
- **Notifications**: `send_notifs` or `notify-send -a "HyDE Alert" ...`
- **Config reads**: `get_hyprConf VAR` reads `$VAR` from theme file; falls back to `hyq` if installed
- **State persistence**: `set_conf "VAR" "value"` → routes to per-domain file via `state_file_for_var()`
- **Deprecated scripts**: `swwwallpaper.sh` (→ `wallpaper.sh`), `hyde-launch.sh` (→ `open.sh`) — don't edit these

## Python conventions

- **Python ≥3.11** required
- **Package manager**: `uv` (not pip)
- **Venv**: `python_env/` — never edit directly; use `hyde-shell pyinit` or `hyde-shell uv install <pkg>`
- **Imports from this repo**: `from pyutils.logger import get_logger`, `from pyutils.xdg_base_dirs import ...`, `from pyutils.wrapper.rofi import rofi_dmenu`, `from pyutils.wrapper.fzf import ...`
- **Optional deps**: use `python_env.v_import("package", extra="amd")` to lazy-import with optional extras
- **Linting**: `ruff` with `line-length = 100`, `indent-width = 4` (defined in `pyproject.toml`)
- **Python scripts are called** via `hyde-shell <name>` which sets up the venv and `PYTHONPATH`

## Key environment variables

Set by `hyde-shell init` / `globalcontrol.sh`:
- `HYDE_THEME`, `HYDE_THEME_DIR` — active theme name and path
- `HYDE_CONFIG_HOME` (`~/.config/hyde`)
- `HYDE_DATA_HOME` (`~/.local/share/hyde`)
- `HYDE_CACHE_HOME` (`~/.cache/hyde`)
- `HYDE_STATE_HOME` (`~/.local/state/hypr`)
- `HYDE_ENGINE_HOME` / `scrDir` / `LIB_DIR` — all point to `~/.local/lib/hyde`
- `enableWallDcol` — wallbash mode: 0=off, 1=auto, 2=dark, 3=light
- `WALLBASH_DIRS` — wallbash template search paths

## Common hyde-shell commands

| Command | Action |
|---------|--------|
| `hyde-shell themeselect` | Theme selector (rofi) |
| `hyde-shell theme.switch -n` | Next theme |
| `hyde-shell theme.switch -p` | Previous theme |
| `hyde-shell wallpaper` | Change wallpaper |
| `hyde-shell wallpaper --select` | Wallpaper selector (rofi) |
| `hyde-shell wallpaper --select --backend <be>` | Selector for specific backend |
| `hyde-shell wallbashtoggle -m` | Toggle dark/light/auto wallbash mode |
| `hyde-shell animations --select` | Animation preset selector |
| `hyde-shell workflows --select` | Workflow overlay selector |
| `hyde-shell hyprlock --select` | Lock screen preset selector |
| `hyde-shell wbarconfgen <n>` | Regenerate waybar config for N monitors |
| `hyde-shell waybar --select` | Waybar layout+style selector |
| `hyde-shell app <cmd>` | Run app with systemd scope / uwsm |
| `hyde-shell lock-session` | Lock session (delegates to loginctl/hyprlock) |
| `hyde-shell logout` | Logout (uwsm-aware) |
| `hyde-shell screenshot s` | Screenshot selection (grim+slurp) |
| `hyde-shell screenshot sq` | Screenshot + QR decode |
| `hyde-shell cliphist -scan-image` | OCR on last clipboard image |
| `hyde-shell session save` | Save named session snapshot |
| `hyde-shell session restore` | Restore last session |
| `hyde-shell pyinit` | Initialize/rebuild Python venv |
| `hyde-shell uv install <pkg>` | Install Python dep into venv |
| `hyde-shell pm <cmd>` | Package manager wrapper |
| `hyde-shell testrunner --verbose` | Dump theme/wallbash state |
| `hyde-shell wallbash.print.colors` | Print current wallbash colors as swatches |

## hyde-shell vs direct replacement

Commands that are thin wrappers around lower-level tools. Useful when replacing HyDE or calling from outside:

| hyde-shell call | What it wraps / direct replacement |
|----------------|-------------------------------------|
| `hyde-shell app <cmd>` | `systemd-run --user --scope` / `uwsm app` — lifecycle management |
| `hyde-shell wallpaper` | `swww img` / `hyprctl hyprpaper` / backend-specific |
| `hyde-shell lock-session` | `loginctl lock-session` |
| `hyde-shell screenshot s` | `grim` + `slurp` + `swappy`/`satty` |
| `hyde-shell window.pin` | `hyprctl dispatch pin` — thin wrapper |
| `hyde-shell volumecontrol` | `wpctl set-volume @DEFAULT_AUDIO_SINK@` / `pamixer` |
| `hyde-shell brightnesscontrol` | `brightnessctl set` |
| `hyde-shell hyprsunset` | `hyprsunset` with HyDE config integration |
| `hyde-shell open <mime>` | `xdg-mime` + `xdg-terminal-exec` |

## Testing

No formal test suite. Verify manually:
- Shell: `hyde-shell <script> --help` (most scripts support `--help` via `argparse.sh`)
- Python: `hyde-shell pyinit && hyde-shell <script> --help`
- Full theme cycle: `hyde-shell theme.switch -n` / `hyde-shell theme.switch -p`
- `testrunner.sh` — verbose theme/wallbash state dump (`testrunner.sh --verbose`)

## Caveats

- `hyde-launch.sh` and `swwwallpaper.sh` are deprecated redirects — do NOT edit, fix the target instead
- Wallbash templates live in `$HYDE_DATA_HOME/wallbash` (user) and `/usr/share/hyde/wallbash` (system), NOT in this repo
- Theme dirs are at `$HYDE_CONFIG_HOME/themes/<name>/` with a `wall.set` symlink pointing to the wallpaper
- `globalcontrol.sh` is sourced by legacy scripts directly; modern scripts use `hyde-shell init` — both must stay in sync
- The `python_env/` directory is a generated venv — never commit changes inside it
- `grimblast` in `screenshot/` is a fork/external utility, not HyDE code