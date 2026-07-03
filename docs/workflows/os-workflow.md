# OS Workflow

> Acciones del sistema operativo — ventanas, workspaces, lanzadores, clipboard, audio, screenshots, theming.

---

## Window Management

Hyprland como compositor. Mod principal = `SUPER`.

### Ventanas

| Acción | Activación | Notas |
|--------|------------|-------|
| Toggle floating | `SUPER+F` | — |
| Pin ventana | `SUPER+SHIFT+F` | Fija en workspace |
| Toggle split | `SUPER+J` | Horizontal ↔ vertical |
| Float + resize con mouse | `SUPER+RMB` | Flotar y redimensionar |

### Workspaces

| Acción | Activación | Notas |
|--------|------------|-------|
| Ir a workspace 1-9 | `SUPER+1-9` | Directo |
| Mover ventana a ws 1-9 | `SUPER+F1-F9` | — |
| Next/prev ws relativo | `SUPER+CTRL+←/→` | — |
| Toggle scratchpad | `SUPER+S` | — |
| Mover a scratchpad | `SUPER+SHIFT+S` | — |
| Workspace overview | `SUPER+F10` | hyprexpose |

### Clipboard (universal)

| Acción | Activación | Notas |
|--------|------------|-------|
| Universal copy | `SUPER+C` | CTRL+Insert — funciona en terminal y GUI |
| Universal paste | `SUPER+V` | SHIFT+Insert |
| Universal cut | `SUPER+X` / `SUPER+SHIFT+X` | CTRL+X |
| Copy (GUI apps) | `SUPER+SHIFT+C` | CTRL+C — para apps que no responden a Insert |
| Paste (GUI apps) | `SUPER+SHIFT+V` | CTRL+V |
| Clipboard manager | `SUPER+SHIFT+V` | cliphist rofi |
| Clipboard browser | `SUPER+CTRL+V` | cliphist rofi (otro modo) |
| Paste primary selection | `SUPER+SHIFT+Insert` | — |

---

## Quick Launchers

| Acción | Herramienta | Activación | Notas |
|--------|-------------|------------|-------|
| App launcher | Rofi | `SUPER+A` | drun |
| Window switcher | Rofi | `SUPER+TAB` | Window list |
| File finder | Rofi | `SUPER+SHIFT+E` | File search |
| Select rofi mode | Rofi | `SUPER+SHIFT+A` | Elegir tipo de launcher |
| Emoji picker | Rofi | `SUPER+,` | — |
| Glyph picker | Rofi | `SUPER+.` | — |
| Keybind hint | Rofi | `SUPER+/` / `SUPER+K` | Muestra todos los keybinds |
| System monitor | btop | `CTRL+SHIFT+Esc` | — |
| Logout menu | hyde-shell | `CTRL+ALT+Delete` | — |
| Kill session | hyde-shell | `SUPER+Delete` | Mata Hyprland |

---

## Audio & Media

| Acción | Activación | Notas |
|--------|------------|-------|
| Toggle mute salida | `F10` / `XF86AudioMute` | Funciona con screen lock |
| Bajar volumen | `F11` / `XF86AudioLowerVolume` | Funciona con screen lock |
| Subir volumen | `F12` / `XF86AudioRaiseVolume` | Funciona con screen lock |
| Toggle mute micrófono | `XF86AudioMicMute` | — |
| Play/Pause | `XF86AudioPlay` / `XF86AudioPause` | playerctl, funciona con screen lock |
| Next/Prev track | `XF86AudioNext` / `XF86AudioPrev` | playerctl, funciona con screen lock |
| Toggle mute ventana | `SUPER+CTRL+M` | Mutea solo la ventana activa |
| Subir brillo | `XF86MonBrightnessUp` | Funciona con screen lock |
| Bajar brillo | `XF86MonBrightnessDown` | Funciona con screen lock |

---

## Screenshots

| Acción | Activación | Notas |
|--------|------------|-------|
| Screenshot región | `Print` | grim + slurp + swappy |
| Freeze + snip región | `SUPER+CTRL+P` | Congela pantalla, luego snip |
| Screenshot monitor actual | `SUPER+ALT+P` | — |
| Screenshot todos los monitors | `SUPER+P` | — |

---

## Theming & Wallpaper

La mayoria de apps cambian de theme junto con el del SO

| Acción | Activación | Notas |
|--------|------------|-------|
| Seleccionar wallpaper | `SUPER+SHIFT+W` | Rofi selector |
| Wallbash mode selector | `SUPER+SHIFT+R` | Rofi selector |
| Seleccionar theme | `SUPER+SHIFT+T` | Rofi selector |
| Seleccionar animaciones | `SUPER+SHIFT+Y` | Rofi selector |
| Seleccionar hyprlock layout | `SUPER+SHIFT+U` | Rofi selector |

---

## Shell Utilities (Modern Replacements)

Reemplazos automáticos — solo se activan si la herramienta está instalada.

| Acción | Original | Reemplazo | Alias |
|--------|----------|-----------|-------|
| Listar archivos | `ls` | eza | `l`, `ls`, `ll`, `la`, `lla`, `lah`, `ld`, `lt` |
| Ver archivo | `cat` | bat | `cat` → bat plain |
| Buscar y reemplazar | `sed` | sd | `sed` → sd |
| Disk usage | `du` | dust | `du` → dust |
| Disk free | `df` | duf | `df` → duf |
| Process monitor | `htop` | btop | `htop` → btop |
| HTTP requests | `curl` | xh | `http` → xh |
| File download | `wget` | wget -c | Auto-resume |
| System info | fastfetch | fastfetch --logo kitty | Kitty image |
| DNS lookup | `dig` | dog | dog DNS client |
| Tar create | — | `tarnow` | tar -acf |
| Tar extract | — | `untar` | tar -zxvf |
| Paste bin | — | `tb` | nc termbin.com 9999 |
| Backup file | — | `backup` | cp file file.bak |
| Smart copy | — | `copy` | cp -r para dirs, cp para archivos |
| Directory up | `cd ..` | `..`, `..2`-`..8` | Navegación rápida |
| Home directory | `cd ~` | `...` | cd /home/buble |
| Make directory | `mkdir` | `mkdir -p` | Auto -p |
| Reload fish | — | `reload` | source config.fish |
| Sudo | `sudo` | `please` | Alias |
| HTTP client (TUI) | — | posting | Cliente HTTP interactivo |
| JSON playground | — | jqp | TUI para jq |
| Shell history | — | atuin | Historial sincronizable y buscable |

### Fish Key Bindings

| Binding | Modos | Acción |
|---------|-------|--------|
| `jj` | insert | Salir a modo normal (vi mode) |
| `!!` | insert | Expandir a comando anterior |
| `!$` | insert | Expandir a último argumento anterior |
| `Tab` | ambos | Aceptar autosuggestion o completar |
| `Ctrl+↑` | insert | Inicio de línea |
| `Ctrl+↓` | insert | Fin de línea |
| `Ctrl+F` | ambos | Abrir fdx file widget |

---

## System & Package Management

CachyOS (Arch) con pacman + AUR + mise + brew (fallback).

| Acción | Herramienta | Activación | Notas |
|--------|-------------|------------|-------|
| Actualizar sistema | pacman | `update` | sudo pacman -Syu |
| Limpiar huérfanos | pacman | `cleanup` | sudo pacman -Rns (orphans) |
| Reparar pacman lock | pacman | `fixpacman` | sudo rm /var/lib/pacman/db.lck |
| Mirror rate | CachyOS | `mirror` | sudo cachyos-rate-mirrors |
| Paquetes por tamaño | expac | `big` | Sorted por tamaño |
| Paquetes git count | pacman | `gitpkg` | Count of -git packages |
| Últimos instalados | expac | `rip` | Últimos 200, sorted por fecha |
| Hardware info | hwinfo | `hw` | hwinfo --short via snip |
| Journal errors | journalctl | `jctl` | journalctl -p 3 via snip |
| Procesos por mem | ps | `psmem` / `psmem10` | Top 10 por memoria |
| Instalar runtime | mise | `mise use -g <tool>` | Gestiona node/go/java/rust/python |
| Game mode | hyde-shell | `SUPER+ALT+G` | Toggle game mode |
| Game launcher | hyde-shell | `SUPER+SHIFT+G` | Rofi game launcher |
| Color picker | hyprpicker | `SUPER+SHIFT+P` | Copia color al portapapeles |

---

## Utility Launchers (Hyprland)

| Acción | Herramienta | Activación | Notas |
|--------|-------------|------------|-------|
| File explorer GUI | Dolphin | `SUPER+E` | $EXPLORER |
| File manager TUI | Yazi | `SUPER+Y` | wezterm -e yazi |
| Browser | zen-browser | `SUPER+B` | $BROWSER |
| Apps launchers | rofi | `SUPER+A` | - |

---

## Virtualization

| Acción | Activación | Notas |
|--------|------------|-------|
| Instalar Windows 11 VM | `winapps-vm install` | Crea VM con dockurr/windows para Office 365 |
| Abrir Windows VM | `winapps-vm launch` o `winapps-launch` | RDP fullscreen, auto-stop al cerrar |
| Abrir Windows VM (persistente) | `winapps-vm launch -k` | VM sigue corriendo tras cerrar RDP |
| Detener VM | `winapps-vm stop` | Apaga contenedor |
| Estado | `winapps-vm status` | — |
| Logs | `winapps-vm logs` | — |

> Carpeta compartida: `~/WinApps/shared/` ↔ `C:\shared\` en Windows