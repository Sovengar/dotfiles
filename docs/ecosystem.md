# Ecosystem & Dependencies

> Complemento a `docs/hyde-workflow.md`. Catálogo de herramientas instaladas.

### Terminal & Shell
| Tool | Purpose | Install |
|------|---------|---------|
| ghostty | Terminal emulator | system |
| wezterm | Terminal emulator | AUR (nightly bin) |
| kitty | Terminal emulator | system |
| zellij | Terminal multiplexer/workspace | system/cargo |
| starship | Prompt | brew/curl |
| zsh | Shell | system |
| fish | Alt shell | system |
| fisher | Fish plugin manager | curl |
| broot | TUI tree nav | brew/curl |
| yazi | TUI file manager | cargo/brew |
| lazygit | TUI git | brew/curl |
| lazynpm | TUI npm | brew (tap: jesseduffield/lazynpm) |
| lazydocker | TUI docker | brew/curl |
| btm (bottom) | TUI process | brew/curl |
| carapace | Multi-shell completion framework | AUR |
| fastfetch | System info | brew/curl |
| cava | Console audio visualizer | system |
| pokego | Pokémon sprites in terminal | AUR |
| sl | Steam locomotive animation | system |
| cmatrix | Matrix rain animation | system |
| cowsay | Talking cow | system |
| fortune-mod | Fortune cookie quotes | system |
| figlet | ASCII text banners | system |
| toilet | Styled ASCII banners | system |
| lolcat | Rainbow terminal text filter | system |
| asciiquarium | ASCII aquarium | system |
| nyancat | Nyan Cat terminal animation | system |
| pipes.sh | Terminal pipes screensaver | AUR |
| cbonsai | Procedural bonsai | AUR |
| ponysay | Pony cowsay | system |
| hollywood | Fake hacker dashboard | AUR |
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
| worktrunk | Git worktree manager (`wt`) | system |
| jqp | TUI jq playground | go install |
| snip | Token saver | go install |
| dust | Intuitive du (`du-dust`) | cargo |
| sd | Find & replace (s/foo/bar) | cargo |
| dog | DNS client (`dog-dns`) | cargo |
| xh | HTTPie-style HTTP client | cargo |
| atuin | Shell history with search | cargo |
| kill-port | Kill process bound to a port | npm |
| portless | Stable `.localhost` dev domains without ports | npm |
| http-server | Static development server | npm |
| pm2 | Node process manager | npm |
| snyk | Dependency vulnerability scanner | npm |

### Dev Tools
| Tool | Purpose | Install |
|------|---------|---------|
| neovim | Editor | brew/curl |
| code (VS Code) | Editor | winget/brew |
| TheHyDEProject.wallbash | VS Code/Code OSS dynamic Wallbash theme | code extension |
| IntelliJ IDEA | Java IDE | winget |
| Bruno | API client | winget |
| DBeaver | DB client | winget |
| Beekeeper Studio | DB client | winget |
| JMeter | Load testing | manual |
| SoapUI | API testing | winget |
| VisualVM | JVM profiler | manual |
| JD-GUI | Java decompiler | manual |
| depot_tools | Chromium/WebRTC tooling | git clone |
| tree-sitter-cli | Parser generator CLI for editor tooling | npm |

### Hardware & Diagnostics
| Tool | Purpose | Install |
|------|---------|---------|
| nvtop | TUI GPU monitor | system |
| vulkan-tools | Vulkan diagnostics | system |
| qpwgraph | PipeWire/JACK graph GUI | system |
| lshw | Deep hardware inventory | system |
| powertop | Power usage diagnostics | system |
| libinput-tools | Input device diagnostics | system |
| nvme-cli | NVMe drive diagnostics | system |

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
| poppler | PDF utilities (pdftotext, pdfimages) | system |

### Media & Entertainment
| Tool | Purpose | Install |
|------|---------|---------|
| spotify-adblock | Spotify ad blocker | AUR |
| ffmpeg | Video/audio processing | system |
| resvg | SVG rendering | cargo |

### Network
| Tool | Purpose | Install |
|------|---------|---------|
| qbittorrent | BitTorrent client | system |
| hayase-desktop-bin | Anime torrent streaming | AUR |
| jdownloader2 | Download manager | CachyOS repo |

### Docker/Infra
| Tool | Purpose | Install |
|------|---------|---------|
| Docker Desktop | Containers | winget |
| Podman | Rootless containers | winget |
| kubectl | K8s CLI | brew/curl |
| lazydocker | TUI docker | brew/curl |
| devcontainer | Dev Containers CLI | npm |
| Testcontainers Desktop | Local Testcontainers app | manual |

### AI/ML
| Tool | Purpose | Install |
|------|---------|---------|
| opencode | AI CLI | curl |
| codex | AI CLI | npm |
| gh-copilot | GitHub AI | gh ext |
| gh-dash | GitHub PR/issue dashboard | gh ext |

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
| rofi | App launcher | CachyOS repo |
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
| kitty | Terminal | CachyOS repo |
