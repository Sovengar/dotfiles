# Ecosystem & Dependencies

When adding a new tool/dependency/package to any install script, **must also add it to this file** under the appropriate category.

## Tool Categories

### Terminal & Shell
| Tool | Purpose | Install |
|------|---------|---------|
| wezterm | Terminal emulator | nightly |
| starship | Prompt | brew/curl |
| zsh | Shell | system |
| fish | Alt shell (HyDE) | system |
| PowerShell 7 | Windows shell | winget |
| broot | TUI tree nav | brew/curl |
| yazi | TUI file manager | cargo/brew |
| lazygit | TUI git | brew/curl |
| lazydocker | TUI docker | brew/curl |
| btm (bottom) | TUI process | brew/curl |
| fastfetch | System info | brew/curl |

### CLI Tools
| Tool | Purpose | Install |
|------|---------|---------|
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

### HyDE Dependencies
| Tool | Purpose | Notes |
|------|---------|-------|
| hyprland | WM (Linux) | CachyOS repo |
| hyprpaper/hyprlock/hypridle | Hypr utils | CachyOS repo |
| waybar | Bar | CachyOS repo |
| rofi | Launcher | CachyOS repo |
| dunst | Notifications | CachyOS repo |
| kitty | Terminal (fallback) | CachyOS repo |
| wlogout | Logout menu | CachyOS repo |
| pypr | Hyprland helper | aur/pip |
| wallust | Color gen (wallbash) | aur/pip |
| imagemagick | Image processing | system |
