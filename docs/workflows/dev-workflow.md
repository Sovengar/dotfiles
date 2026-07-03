# Dev Workflow

> Herramientas instaladas: `show-dev-x`

---

## Terminal & Multiplexing

WezTerm como terminal y multiplexor. Leader = `ALT+Q` (2s timeout).
Los mas importantes:

| Acción | Herramienta | Activación | Notas |
|--------|-------------|------------|-------|
| Abrir terminal | WezTerm | `SUPER+Enter` | Terminal principal |
| Terminal dropdown | pypr | `SUPER+ALT+Enter` | Toggle flotante |
| File picker flotante | fdx | `ALT+F` | pypr toggle fdx-floating, abre fdx en ventana flotante |
| Quick terminal | quickterm | `ALT+T` | Terminal temporal, toggle |
| Layout for dev | Wezterm | `LEADER+D` | - |
| Cambiar tab | WezTerm | `ALT+1-9` | Directo por número |

---

## File Navigation & Search

fdx y rgx son las herramientas principales — combinan fuzzy finding con preview y editor integration.

| Acción | Herramienta | Activación | Notas |
|--------|-------------|------------|-------|
| Buscar archivo por nombre | fdx | `fdx` / `Ctrl+F` en fish / `ALT+F` flotante | fd + fzf + bat preview → nvim |
| Buscar contenido en archivos | rgx | `rgx <pattern>` | rg + fzf + bat preview → nvim |
| File manager TUI | Yazi | `yazi` / `SUPER+Y` | Con cwd tracking (salta al dir navegado) |
| File explorer GUI | Dolphin | `SUPER+E` | $EXPLORER |
| Navegador de dirs | cdx-rs | `cdx` | zoxide + TUI + eza listing |

---

## Editor & IDE

Neovim (LazyVim) como editor primario, VS Code OSS como secundario, OpenCode como AI assistant.

| Acción | Herramienta | Activación | Notas |
|--------|-------------|------------|-------|
| Abrir editor GUI | VS Code OSS | `SUPER+T` | $EDITOR |
| Abrir Neovim | Neovim | `vi` / `nvim` | fish abbr |
| Preguntar a AI sobre selección | OpenCode | `Ctrl+A` en nvim | Ask con contexto de selección |
| Acción de AI | OpenCode | `Ctrl+X` en nvim | Action sobre selección |
| Toggle panel AI | OpenCode | `Ctrl+.` en nvim | Abre/cierra panel |
| Enviar selección a AI | OpenCode | `Alt+A` en nvim | Via snacks picker |
| Operator AI en nvim | OpenCode | `go` / `goo` | Add range/line a prompt |
| OpenCode en terminal | OpenCode | `op` | fish abbr |
| Ver diff en nvim | Diffview | `<leader>gv` | DiffviewOpen |
| Historial de archivo en nvim | Diffview | `<leader>gD` | DiffviewFileHistory % |
| Cerrar Diffview | Diffview | `<leader>gC` | DiffviewClose |

---

## VCS (Version Control)

> Para detalle completo de git workflow, abreviaturas y herramientas → `git-workflow.md`

## AI Help

| Acción | Herramienta | Activación | Notas |
|--------|-------------|------------|-------|
| AI assistant flotante | AI Chat | `SUPER+W` | ChatGPT + Gemini + Claude + Arena |

---

## Containers & Orchestration

| Acción | Herramienta | Activación | Notas |
|--------|-------------|------------|-------|
| Dashboard Docker | LazyDocker | `SUPER+D` / `ldk` | Flotante o terminal |
| Custom aliases | Docker | `dkbuild`, `dkps`, ... | - |

---

## Shell config

| Concepto | Herramienta | Detalle |
|----------|-------------|---------|
| Shell principal | Fish | `~/.config/fish/conf.d/*.fish` se carga automáticamente |
| Vi-mode | fish_vi_key_bindings | `jj` → normal, cursores blink por modo, `fish_escape_delay_ms=10` |
| Prompt | Starship | `$STARSHIP_CONFIG` → `~/.config/starship/starship.toml` |
| Saludo | fastfetch + pokego | 50% pokemon aleatorio, 50% fastfetch |
| Completions | Carapace | `carapace _carapace \| source` autoload |
| Pager | bat | `cat` → `bat --style=plain --paging=never --color auto` |
| | MANPAGER | `~/.local/bin/manpager`, `MANROFFOPT="-c"` |
| File list | eza | `l`/`ls`/`ll`/`la`/`lla`/`lah`/`ld`/`lt` con icons |
| CD con listado | cd function | Al hacer cd, ejecuta `eza --icons --group-directories-first` |
| Navigation | zoxide | `z` + `zi`, init en fish |
| | cdx-rs | `cdx` wrapper que hace cd + eza |
| Dir nav TUI | cdx | vía cdx.fish que parsea `/tmp/cdx-rs-result.txt` |
| Fuzzy finder | fzf | `~/.config/fzf/fzf-config.fish`, funciones en `fish/functions/fzf/` |
| File picker | fdx | `Ctrl+F` bind, fzf + fd + bat preview → nvim |
| Content search | rgx | `rgx <pattern>`, fzf + rg + bat preview → nvim |
| Git picker | fzf-git | `Ctrl+G` + letra: `b`(branches), `f`(files), `h`(hashes), `r`(remotes), `s`(stashes), `t`(tags), `w`(worktrees), etc. |
| History | atuin | Atuin para shell history |
| | `history` function | `builtin history --show-time='%F %T'` |
| Plugins | fisher | `fish_plugins`: `franciscolourenco/done` |
| Notifications | done plugin | Notifica commands >5s si la ventana no está enfocada (vía `notify-send`) |
| Key bindings | Personalizadas | `jj`→normal, `tab`→autosuggest/complete, `!`→prev command, `$`→prev arg, `*`→pipe a fzf, `º`→fzf git ctx, `Ctrl+↑/↓`→inicio/fin |
| | fzf-git | `Ctrl+G` + `?` lista bindings |
| | fdx widget | `Ctrl+F` lanza fdx file widget |
| Overrides | Tool alternativos | `cd`→eza, `du`→dust, `df`→duf, `htop`→btop, `sed`→sd, `cat`→bat |
| | System | `update`→pacman -Syu, `cleanup`→pacman -Rns, `mirror`→cachyos-rate-mirrors |
| | Docker | `dkbuild`, `dkps`, `dkrun`(fzf), `dkexe`(fzf), `dklogs`(fzf) |
| | Kubernetes | `k`, `kgpa`, `kgpo`, `kl`, `kpf`, etc. + `kn` namespace switch |
| | HyDE | `in`, `un`, `up`, `pl`, `pa` (hyde-shell pm) |
| Git abreviaturas | `g` + subcomandos | `g u`=pull rebase, `g p`=push, `g c`=commit, `g sw`=switch, `g st`=status, `g d`=diff, `g h`=log fancy, `g rb`=rebase, `g mg`=merge, `g amend`, `g polish`, `g absorb`, `g pr`/`prw`/`prv`, etc. |
| | FZF en git | `º` expande selector fzf para branch/commit según contexto |
| | `git checkout` | Bloqueado — usar `git switch` o `git restore` |
| Env vars | XDG Base Dir | `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, etc. |
| | Starship cache/config | `$STARSHIP_CACHE`, `$STARSHIP_CONFIG` |
| | Man pages | `MANROFFOPT="-c"`, `MANPAGER` |
| | Kubernetes | `KUBECONFIG` multi-cluster |
| Paths | `fish_add_path` | `~/.local/bin`, brew shellenv, mise shims, go, cargo, depot_tools |
| Runtimes | mise | `~/.local/share/mise/shims`, python 3.12.13 |
| Abreviaturas CLI | `op`=opencode, `vi`=nvim, `http`=xh, `ldk`=lazydocker, `lgit`=lazygit, `lzn`=lazynpm, `gh-dash` |


## Tool Stack

| Dominio | Herramienta | Alternativa |
|---------|-------------|-------------|
| Terminal | WezTerm | kitty (fallback) |
| Shell | Fish | nushell, zsh (LEADER+n/Z) |
| Multiplexor | WezTerm (tabs/panes) | Zellij (disponible) |
| Editor | Neovim (LazyVim) | VS Code OSS |
| AI assistant | OpenCode | — |
| Container TUI | LazyDocker | — |
| File finder | fdx (fd+fzf+bat) | — |
| Content search | rgx (rg+fzf+bat) | — |
| File manager TUI | Yazi | Dolphin (GUI) |
| Dir navigator | cdx | — |


| Completions | carapace | — |
| Shell history | atuin | — |
| Pager | bat | — |
| Lister | eza | — |
| Disk usage | dust | — |
| Disk free | duf | — |
| Find & replace | sd | — |
| HTTP client | xh | — |
| DNS client | dog | — |
| Runtimes | mise | — |
| Packages | pacman + AUR | brew (fallback) |