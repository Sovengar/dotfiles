# CLI Ecosystem

## Catalog

### Navigation & Search

| Tool | What |
|---|---|
| **[lazygit](https://github.com/jesseduffield/lazygit)** | Git TUI |
| **[git-flow](https://github.com/nvie/gitflow)** | Git branching workflow extension (`git-flow`) |
| **[lazydocker](https://github.com/jesseduffield/lazydocker)** | Docker TUI |
| **[gh](https://cli.github.com)** | GitHub CLI |
| **gh dash** | Dashboard TUI for PRs/issues/CI — [Video guide](https://www.youtube.com/watch?v=Z-3dUHDnkEI) |
| **gh copilot** ⚠️ | GH CLI AI assistant (NOT INSTALLED) |
| **[snyk](https://snyk.io)** | Security/SAST scanner |
| **[hyperfine](https://github.com/sharkdp/hyperfine)** | Command benchmarking |
| **[cdx](https://github.com/Sovengar/cdx)** | Interactive directory navigator built from Rust source |

### Terminal & Shell

| Tool | What |
|---|---|
| **[kitty](https://sw.kovidgoyal.net/kitty/)** | GPU-accelerated terminal used by Hypr/pypr scratchpads |
| **[konsole](https://konsole.kde.org/)** | KDE terminal emulator |
| **[wezterm](https://wezfurlong.org/wezterm)** | GPU-accelerated terminal (Lua config) |
| **[starship](https://starship.rs)** | Cross-shell prompt |
| **[bash-completion](https://github.com/scop/bash-completion)** | Programmable completions for Bash |
| **[nushell](https://www.nushell.sh/)** | Structured shell |
| **[fastfetch](https://github.com/fastfetch-cli/fastfetch)** | System information fetch tool |
| **[Neovim](https://neovim.io) + LazyVim** | Modal editor |
| **[bottom](https://github.com/ClementTsang/bottom)** | System monitor TUI (`btm`) |
| **[gum](https://github.com/charmbracelet/gum)** | TUI dialogs/forms for scripts |
| **[tui-generator.sh](https://github.com/basecamp/omarchy/blob/dev/bin/tui-generator)** | Script to create TUI desktop entries (name, command, tile/float, icon) |
| **[broot](https://dystroy.org/broot/)** | Tree navigator |
| **[hyperfine](https://github.com/sharkdp/hyperfine)** | Command benchmarking |
| **[pastel](https://github.com/sharkdp/pastel)** | Color CLI |
| **[jj](https://github.com/jj-vcs/jj)** | VCS CLI |
| **[jq](https://jqlang.github.io/jq/)** | JSON processor |
| **[hurl](https://hurl.dev/)** | HTTP test CLI |
| **[LinuxAliases.ps1](https://github.com/Sovengar/dotfiles/blob/master/home/Documents/PowerShell/LinuxAliases.ps1)** | Linux muscle memory in PS (`ls -la`, `grep`, `touch`, etc.) |

### Fonts

| Tool | What |
|---|---|
| **JetBrainsMono Nerd Font** | Nerd Font used by terminals/editors |

### Runtimes & Environments

| Tool | What |
|---|---|
| **[mise](https://mise.jdx.dev/)** | Runtime/version manager |
| **Java / OpenJDK** | JVM toolchain |
| **Node.js + npm** | JavaScript runtime and package manager |
| **Go** | Go runtime/toolchain |
| **Rust + Cargo** | Rust runtime/toolchain |

### Agents & IDEs

| Tool | What |
|---|---|
| **[opencode](https://opencode.ai/)** | AI coding agent |
| **[Engram](https://github.com/Gentleman-Programming/engram)** | Memory layer / MCP integration for AI agents |
| **[Gentleman Guardian Angel](https://github.com/Gentleman-Programming/gentleman-guardian-angel)** | Global Git hooks and code guardian (`gga`) |
| **[Codex CLI](https://www.npmjs.com/package/@openai/codex)** | OpenAI coding agent CLI |
| **Google Antigravity** | AI IDE/agent |
| **Visual Studio Code** | Editor |
| **IntelliJ IDEA** | JetBrains IDE |

### Desktop & Dev Apps

| Tool | What |
|---|---|
| **Bruno GUI** | API client GUI |
| **Beekeeper Studio** | Database GUI |
| **DBeaver** | Database GUI |
| **Podman + Podman Desktop** | Container CLI and GUI |
| **JMeter** | Load testing |
| **SoapUI** | SOAP/API testing |
| **JD-GUI** | Java decompiler GUI |
| **VisualVM** | JVM profiling/monitoring |
| **[Handy](https://github.com/cjpais/Handy)** | Offline speech-to-text app |
| **[WebCord](https://github.com/SpacingBat3/WebCord)** | Discord web client wrapper |
| **[OBS Studio](https://obsproject.com/)** | Recording and streaming studio |
| **Steam** | Game launcher |

### File Explorers

| Tool | What |
|---|---|
| **Dolphin** | HyDE GUI file explorer |
| **[yazi](https://yazi-rs.github.io)** | Terminal file manager with previews |

### Desktop System

| Tool | What |
|---|---|
| **PipeWire + WirePlumber** | Audio stack |
| **NetworkManager** | Network management service and tray applet |
| **BlueZ + Blueman** | Bluetooth stack and GUI |
| **grim + slurp + satty + hyprpicker** | Wayland screenshot and color picker tools |
| **cliphist + wl-clip-persist + wl-clipboard** | Wayland clipboard history/persistence |

### Hyprland

| Tool | What |
|---|---|
| **[pyprland](https://github.com/hyprland-community/pyprland)** | Hyprland plugin manager used for scratchpads |

### Cloud Storage

| Tool | What |
|---|---|
| **Dropbox** | Dropbox desktop sync client |
| **[rclone](https://rclone.org/)** | Cloud storage CLI used for Google Drive and OneDrive mounts |

### Node.js Utilities

| Tool | What |
|---|---|
| **[kill-port](https://www.npmjs.com/package/kill-port)** | Kill process on a port |
| **[http-server](https://www.npmjs.com/package/http-server)** | Zero-config static server |
| **[pm2](https://pm2.keymetrics.io)** | Node process manager |
| **[portless](https://portless.dev)** | Localhost without ports (`https://myapp.localhost`) |
| **[@usebruno/cli](https://www.usebruno.com)** | API client CLI (Bruno) |

### Config & Versioning

| Tool | What |
|---|---|
| **[chezmoi](https://chezmoi.io)** | Dotfiles manager |
| **[Git LFS](https://git-lfs.com/)** | Git extension for large files |
| **[yay](https://github.com/Jguer/yay)** | AUR package manager/helper |
| **[snip](https://github.com/anomalyco/snip)** | Synthesize verbose command output |

## Hierarchy

```
opencode (orchestration)
  ├── lazygit + gh (git)
  ├── cdx (zoxide+rg+fzf) + fd + broot (nav)
  ├── mise → node/go/rust/... (runtimes)
  └── nvim + bat + eza + pastel (edit/view)
wezterm + starship + yazi + bottom + gum (shell)
tui-generator.sh (TUI desktop entries via app launcher)
chezmoi (everything versioned)
```

## Installed status

All tools installed except `gh copilot` (run `gh extension install github/gh-copilot`).

Desktop TUIs installed: lazydocker and Gemini via pypr scratchpads. Add more terminal apps via `tui-generator.sh`.
