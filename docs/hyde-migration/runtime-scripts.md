# Runtime Scripts And CLI Migration

> Goal: know what `hyde-shell` actually does before replacing commands in keybindings and startup.

## Entry Points

| Command | File | Migration note |
|---------|------|----------------|
| `hyde-shell` | `Configs/.local/bin/hyde-shell` | Bash dispatcher. Most subcommands delegate to scripts under `~/.local/lib/hyde`. |
| `hydectl` | `Configs/.local/bin/hydectl` | Precompiled ELF in repo; source not visible in HyDE tree. Treat as opaque. |
| `hyde-ipc` | `Configs/.local/bin/hyde-ipc` | Precompiled ELF; likely IPC bridge. Treat as opaque until proven unused. |
| `globalcontrol.sh` | `Configs/.local/lib/hyde/globalcontrol.sh` | Runtime source of XDG dirs, theme paths, helpers, package checks, notifications. |

`HYDE_SCRIPTS_PATH` resolves scripts from user config and HyDE library paths. If replacing `hyde-shell`, either preserve that lookup temporarily or replace every call with direct commands.

## Script Groups

| Group | Files | What to replace with |
|-------|-------|----------------------|
| Wallpaper | `wallpaper*.sh`, `wallpaper/` | Direct `swww`, `hyprpaper`, or owned selector. |
| Theme/wallbash | `theme.*.sh`, `wallbash*.sh`, `color/*.sh` | Area-specific generator scripts. |
| App lifecycle | `app2unit.sh` | `uwsm app`, `systemd-run --user`, or user units. |
| Screenshot | `screenshot.sh`, `screenshot/` | Direct `grim`, `slurp`, `swappy`/`satty`. |
| Audio/brightness | `volumecontrol.sh`, `brightnesscontrol.sh` | Direct `pamixer`, `wpctl`, `brightnessctl`. |
| Rofi utilities | `rofilaunch.sh`, `rofiselect.sh`, `rofi.*.sh` | Own rofi/fuzzel/fzf launchers. |
| Clipboard | `cliphist.sh` | Direct `cliphist` plus `wl-paste` services. |
| Lock/session | `lockscreen.sh`, `hyprlock.sh`, logout scripts | Direct `hyprlock`, `loginctl`, `uwsm stop`. |
| Waybar | `waybar.py`, `wbarconfgen.sh`, `wbarstylegen.sh` | Direct waybar plus owned config selector. |
| Package manager | `pm.sh`, `pm.py`, `pm/*` | Native package manager or a single owned wrapper. |
| Python/Lua env | `pyutils/*`, `pyinit`, `luainit` | Drop unless `pypr`, `hyde-ipc`, or HyDE Python tools remain. |

## Keybinding Command Surface

These are the HyDE calls that must be removed or replaced before deleting `hyde-shell`.

| Current call | Replacement direction |
|--------------|-----------------------|
| `hyde-shell app -T` | Terminal command, e.g. `kitty`, `wezterm`, `ghostty`, or `uwsm app -- terminal`. |
| `hyde-shell open --fall ...` | Direct browser/editor/file-manager command. |
| `hyde-shell logout` | `uwsm stop`, `hyprctl dispatch exit`, or session-specific script. |
| `hyde-shell lock-session` | `loginctl lock-session` or `hyprlock`. |
| `hyde-shell window.pin` | `hyprctl dispatch pin`. |
| `hyde-shell wallpaper ...` | Owned wallpaper selector/backend. |
| `hyde-shell themeselect` | Owned theme selector. |
| `hyde-shell wallbashtoggle -m` | Owned mode toggle plus color refresh. |
| `hyde-shell animations --select` | Copy selected animation preset and reload Hyprland. |
| `hyde-shell hyprlock --select` | Own lock preset selector. |
| `hyde-shell wbarconfgen n/p` | Own waybar layout switch. |
| `hyde-shell screenshot s/sf/m/p` | `grim`/`slurp` command variants. |
| `hyde-shell volumecontrol ...` | `wpctl`/`pamixer` commands. |
| `hyde-shell brightnesscontrol ...` | `brightnessctl` or `light`. |
| `hyde-shell cliphist` | Direct `cliphist` wrapper. |
| `hyde-shell keybinds_hint` | Own parser or drop. |
| `hyde-shell emoji-picker`, `glyph-picker` | Rofi/fzf picker scripts. |
| `hyde-shell system.monitor` | `btop`, `htop`, or terminal wrapper. |

## Package Manager Wrapper

| File | Behavior |
|------|----------|
| `Configs/.local/lib/hyde/pm.sh` | Shell wrapper for pacman/yay/paru/apt/dnf/zypper/apk/brew/scoop/flatpak. |
| `Configs/.local/lib/hyde/pm.py` | Python rewrite with modular backends. |
| Shell aliases | `in`, `un`, `up`, `pl`, `pa` call `hyde-shell pm`. |
| Install scripts | `Scripts/global_fn.sh` uses `pm.sh` as `pacmanCmd`. |

For this dotfiles repo, prefer direct `paru`/`pacman` or one owned wrapper. Keeping both `pm.sh` and `pm.py` adds unnecessary migration surface.

## Opaque Binaries

| Binary | Risk |
|--------|------|
| `hydectl` | Source not found in HyDE tree; do not depend on it in new code. |
| `hyde-ipc` | Source not found in HyDE tree; verify runtime dependency before removal. |
| `hyde-config` | Runs from startup; likely parses `~/.config/hyde/config.toml` into state. Drop only after theme/config pipeline is replaced. |

## Migration Stages

| Stage | Action |
|-------|--------|
| 1 | Grep all `hyde-shell` calls in chezmoi. |
| 2 | Replace app/session/keybinding commands before theme commands. |
| 3 | Replace shell aliases using `hyde-shell pm`. |
| 4 | Keep theme/wallpaper subcommands until `theme-wallbash.md` stages are done. |
| 5 | Remove `~/.local/lib/hyde` from PATH and fix anything that breaks. |
| 6 | Remove `hydectl`, `hyde-ipc`, `hyde-config` only after no service/keybinding/script calls them. |
