# Ecosystem & Dependencies

When adding a new tool/dependency/package to any install script, **must also add it to this file** under the appropriate category.

## Tool Categories

### Terminal & Shell
| Tool | Purpose | Install |
|------|---------|---------|
| ghostty | Terminal emulator | system |
| wezterm | Terminal emulator | nightly |
| starship | Prompt | brew/curl |
| zsh | Shell | system |
| fish | Alt shell (HyDE) | system |
| fisher | Fish plugin manager | curl |
| PowerShell 7 | Windows shell | winget |
| broot | TUI tree nav | brew/curl |
| yazi | TUI file manager | cargo/brew |
| lazygit | TUI git | brew/curl |
| lazydocker | TUI docker | brew/curl |
| btm (bottom) | TUI process | brew/curl |
| fastfetch | System info | brew/curl |
| cava | Console audio visualizer | system |
| pokego | Pokémon sprites in terminal | AUR |
| sl | Steam locomotive ASCII animation | system |
| cmatrix | Matrix-style rain animation | system |
| cowsay | Talking cow ASCII text | system |
| fortune-mod | Fortune cookie quotes (`fortune`) | system |
| figlet | Large ASCII text banners | system |
| toilet | Styled ASCII text banners | system |
| lolcat | Rainbow terminal text filter | system |
| asciiquarium | Animated ASCII aquarium | system |
| nyancat | Nyan Cat terminal animation | system |
| pipes.sh | Animated terminal pipes screensaver | AUR |
| cbonsai | Procedural terminal bonsai | AUR |
| ponysay | Pony-themed cowsay alternative | system |
| hollywood | Fake hacker terminal dashboard | AUR |
| aalib | ASCII fire demo (`aafire`) | system |

### CLI Tools
| Tool | Purpose | Install |
|------|---------|---------|
| sed (GNU) | Stream editor | system |
| gawk (GNU Awk) | Text processing | system |
| fd | File search | brew/curl |
| rg (ripgrep) | Text search | brew/curl |
| fzf | Fuzzy finder | brew/curl |
| zoxide | Smarter cd | brew/curl |
| bat | Cat with syntax | brew/curl |
| eza | Modern ls | brew/curl |
| jq | JSON processor | brew/curl |
| hurl | HTTP CLI | brew/curl |
| hyperfine | Benchmark | brew/curl |
| pastel | Color swatches | brew/curl |
| mise | Dev env manager | brew/curl |
| jj | Git-compat VCS | brew/curl |
| jqp | TUI playground for jq | go install |
| snip | Token saver | go install |

### Dev Tools
| Tool | Purpose | Install |
|------|---------|---------|
| neovim | Editor | brew/curl |
| code (VS Code) | Editor | winget/brew |
| IntelliJ IDEA | Java IDE | winget |
| Bruno | API client | winget |
| DBeaver | DB client | winget |
| Beekeeper Studio | DB client | winget |
| JMeter | Load testing | manual |
| SoapUI | API testing | winget |
| VisualVM | JVM profiler | manual |
| JD-GUI | Java decompiler | manual |
| depot_tools | Chromium/WebRTC development tooling | git clone |

### Hardware & Diagnostics
| Tool | Purpose | Install |
|------|---------|---------|
| nvtop | TUI GPU monitor | system |
| vulkan-tools | Vulkan diagnostics (`vulkaninfo`) | system |
| qpwgraph | PipeWire/JACK graph GUI | system |
| lshw | Deep hardware inventory | system |
| powertop | Power usage diagnostics | system |
| libinput-tools | Input device diagnostics (`libinput`) | system |
| nvme-cli | NVMe drive diagnostics (`nvme`) | system |

### Gaming
| Tool | Purpose | Install |
|------|---------|---------|
| steam | Game store | system |
| heroic-games-launcher | Epic/GOG/Amazon launcher | CachyOS repo |
| lutris | Open Gaming Platform | system |
| wine | Windows compat layer | system |
| proton-cachyos | Steam Play (CachyOS) | CachyOS repo |

### Office
| Tool | Purpose | Install |
|------|---------|---------|
| onlyoffice-bin | Office suite | CachyOS repo |

### Media & Entertainment
| Tool | Purpose | Install |
|------|---------|---------|
| spotify-adblock | Spotify ad blocker | AUR |

### Network
| Tool | Purpose | Install |
|------|---------|---------|
| qbittorrent | BitTorrent client | system |
| hayase-desktop-bin | Anime torrent streaming | AUR |
| jdownloader2 | Download manager (JDownloader) | CachyOS repo |

### Docker/Infra
| Tool | Purpose | Install |
|------|---------|---------|
| Docker Desktop | Containers | winget |
| Podman | Rootless containers | winget |
| kubectl | K8s CLI | brew/curl |
| lazydocker | TUI docker | brew/curl |

### AI/ML
| Tool | Purpose | Install |
|------|---------|---------|
| opencode | AI CLI | curl |
| codex | AI CLI | npm |
| gh-copilot | GitHub AI | gh ext |

### Security
| Tool | Purpose | Install |
|------|---------|---------|
| KeePassXC | Password mgr | winget |
| age | Encryption | winget |
| SOPS | Secrets mgr | winget |
| Malwarebytes | AV | winget |

### HyDE Dependencies — Core
| Tool | Purpose | Notes |
|------|---------|-------|
| hyprland | WM (Linux) | CachyOS repo |
| uwsm | Wayland session manager | system |
| awww | Wallpaper daemon | CachyOS repo |
| waybar | Status bar | CachyOS repo |
| rofi | Application launcher | CachyOS repo |
| dunst | Notification daemon | CachyOS repo |
| swaync | Notification center | system |
| hyprlock | Lock screen | CachyOS repo |
| hypridle | Idle daemon | CachyOS repo |
| hyprsunset | Blue-light filter | CachyOS repo |
| wlogout | Logout menu | CachyOS repo |
| pypr | Hyprland helper | aur/pip |

### HyDE Dependencies — Theming & Display
| Tool | Purpose | Notes |
|------|---------|-------|
| nwg-look | GTK settings editor | CachyOS repo |
| nwg-displays | Output management | system |
| qt5ct/qt6ct | Qt config tool | system |
| kvantum | Qt theme engine | system |
| qt5-wayland/qt6-wayland | Qt Wayland support | system |
| wallust | Color gen (wallbash) | aur/pip |
| imagemagick | Image processing | system |

### HyDE Dependencies — Utilities
| Tool | Purpose | Notes |
|------|---------|-------|
| hyprpolkitagent | Polkit auth agent | CachyOS repo |
| xdg-desktop-portal-hyprland | Hyprland portal backend | CachyOS repo |
| xdg-desktop-portal-gtk | GTK file picker portal | system |
| hyprquery | Config query CLI | chaotic-aur |
| swayosd-git | On-screen display | chaotic-aur |
| wf-recorder | Wlroots screen recorder | system |
| kitty | Terminal (fallback) | CachyOS repo |
