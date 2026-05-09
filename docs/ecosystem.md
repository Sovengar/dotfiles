# CLI Ecosystem

## Catalog

### Navigation & Search

| Tool | What |
|---|---|
| **[cdx](docs/cdx.md)** | CD with fzf + zoxide + rg |
| **[zoxide](https://github.com/ajeetdsouza/zoxide)** | Smart `cd` that learns |
| **[fzf](https://github.com/junegunn/fzf)** | Fuzzy finder (Ctrl+T, Ctrl+R, `**<Tab>`) |
| **[ripgrep](https://github.com/BurntSushi/ripgrep)** | Ultra-fast text search |
| **[fd](https://github.com/sharkdp/fd)** | Fast file search (replaces `find`) |
| **[broot](https://dystroy.org/broot)** | Tree explorer + fuzzy |

### File Viewing & Diff

| Tool | What |
|---|---|
| **[bat](https://github.com/sharkdp/bat)** | `cat` with syntax highlighting |
| **[eza](https://github.com/eza-community/eza)** | `ls` replacement with icons, colors, tree |
| **[pastel](https://github.com/sharkdp/pastel)** | Color manipulation CLI |

### Dev Tools

| Tool | What |
|---|---|
| **[opencode](https://opencode.ai)** | AI coding agent — plans, codes, reviews |
| **[mise](https://mise.jdx.dev)** | Runtime version manager (replaces nvm/pyenv/rbenv) |
| **[lazygit](https://github.com/jesseduffield/lazygit)** | Git TUI |
| **[gh](https://cli.github.com)** | GitHub CLI |
| **gh dash** | Dashboard TUI for PRs/issues/CI |
| **gh copilot** ⚠️ | GH CLI AI assistant (NOT INSTALLED) |
| **[snyk](https://snyk.io)** | Security/SAST scanner |
| **[hyperfine](https://github.com/sharkdp/hyperfine)** | Command benchmarking |

### Terminal & Shell

| Tool | What |
|---|---|
| **[wezterm](https://wezfurlong.org/wezterm)** | GPU-accelerated terminal (Lua config) |
| **[starship](https://starship.rs)** | Cross-shell prompt |
| **[Neovim](https://neovim.io) + LazyVim** | Modal editor |
| **[bottom](https://github.com/ClementTsang/bottom)** | System monitor TUI (`btm`) |
| **[yazi](https://yazi-rs.github.io)** | Terminal file manager with previews |
| **[LinuxAliases.ps1](https://github.com/Sovengar/dotfiles/blob/master/home/Documents/PowerShell/LinuxAliases.ps1)** | Linux muscle memory in PS (`ls -la`, `grep`, `touch`, etc.) |

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
| **[snip](https://github.com/anomalyco/snip)** | Synthesize verbose command output |

## Hierarchy

```
opencode (orchestration)
  ├── lazygit + gh (git)
  ├── cdx (zoxide+rg+fzf) + fd + broot (nav)
  ├── mise → node/go/rust/... (runtimes)
  └── nvim + bat + eza + pastel (edit/view)
wezterm + starship + yazi + bottom (shell)
chezmoi (everything versioned)
```

## Installed status

All tools installed except `gh copilot` (run `gh extension install github/gh-copilot`).
