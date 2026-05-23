# Runtime Scripts And CLI Migration

> Goal: know what `hyde-shell` actually does so owned config can call it intentionally, wrap it, or rename it without letting HyDE dictate `.config` content.

`hyde-shell` is allowed to remain as a runtime engine. Migration here means turning implicit HyDE ownership into an explicit API boundary.

## Entry Points

| Command | File | Migration note |
|---------|------|----------------|
| `hyde-shell` | `Configs/.local/bin/hyde-shell` | Bash dispatcher tracked by chezmoi. Most subcommands delegate to scripts under `~/.local/lib/hyde`. |
| `hydectl` | `Configs/.local/bin/hydectl` | Precompiled ELF in repo; source not visible in HyDE tree. Treat as opaque. |
| `hyde-ipc` | `Configs/.local/bin/hyde-ipc` | Precompiled ELF; likely IPC bridge. Treat as opaque until proven unused. |
| `globalcontrol.sh` | `Configs/.local/lib/hyde/globalcontrol.sh` | Runtime source of XDG dirs, theme paths, helpers, package checks, notifications. |

`HYDE_SCRIPTS_PATH` resolves scripts from user config and HyDE library paths. If appropriating `hyde-shell`, keep that lookup as part of the engine contract or wrap it behind your own command name.

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

These are the HyDE calls that are intentionally inside the runtime boundary. They do not need to disappear while `hyde-shell` remains the chosen engine.

| Current call | Replacement direction |
|--------------|-----------------------|
| `hyde-shell app -T` | Keep as engine API, or replace with terminal command such as `kitty`, `wezterm`, `ghostty`, or `uwsm app -- terminal`. |
| `hyde-shell open --fall ...` | Direct browser/editor/file-manager command. |
| `hyde-shell logout` | `uwsm stop`, `hyprctl dispatch exit`, or session-specific script. |
| `hyde-shell lock-session` | `loginctl lock-session` or `hyprlock`. |
| `hyde-shell window.pin` | `hyprctl dispatch pin`. |
| `hyde-shell wallpaper ...` | Keep as HyDE engine call, or wrap with owned wallpaper selector/backend. |
| `hyde-shell themeselect` | Keep as HyDE engine call, or wrap with owned theme selector. |
| `hyde-shell wallbashtoggle -m` | Keep as HyDE engine call, or wrap with owned mode toggle plus color refresh. |
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

For this dotfiles repo, `hyde-shell pm` remains because `hyde-shell` is the accepted runtime engine. The problem is ambiguous ownership, not the HyDE name alone.

## Opaque Binaries

| Binary | Risk |
|--------|------|
| `hydectl` | Source not found in HyDE tree; treat as opaque engine surface unless replaced or wrapped. |
| `hyde-ipc` | Source not found in HyDE tree; verify runtime dependency before changing it. |
| `hyde-config` | Runs from startup; likely parses `~/.config/hyde/config.toml` into state. Keep while theme/config engine depends on it. |

## Migration Stages

| Stage | Action | Status |
|-------|--------|--------|
| 1 | Grep all `hyde-shell` calls in chezmoi. | Done: calls remain across Hyprland startup, keybindings, shell aliases, hypridle, wlogout, fastfetch, and Hyprlock. |
| 2 | Classify each call as engine API, wrapper candidate, or replacement candidate. | Done for now: `hyde-shell` is the accepted runtime API. |
| 3 | Keep or rename shell aliases using `hyde-shell pm`. | Done: keep aliases because they target the accepted runtime. |
| 4 | Keep theme/wallpaper subcommands until `theme-wallbash.md` ownership stages are done. | Active. |
| 5 | Stop relying on `~/.local/lib/hyde` being injected into PATH by shell startup. | Done enough: `hyde-shell` is tracked as explicit runtime entrypoint. |
| 6 | Change `hydectl`, `hyde-ipc`, `hyde-config` only after their engine role is known. | Pending. |
