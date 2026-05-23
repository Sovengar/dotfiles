# Shells Migration

> Goal: make zsh/fish config ownership independent from HyDE restore files while allowing `hyde-shell` to remain as a runtime engine command.

Using `hyde-shell` from a shell alias is not automatically a problem. The blocker is HyDE dictating shell startup files under `~/.config/fish` or `~/.config/zsh`.

## Current Status

| Shell | Status | What is owned | What still needs a decision |
|-------|--------|---------------|-----------------------------|
| Fish | Owned startup | `config.fish`, `conf.d/*.fish`, functions, plugins, and theme README live in chezmoi. | `90-hyde.fish` aliases and `hyde-shell.fish` completion intentionally target the allowed runtime. |
| Zsh | Owned startup | Root `.zshenv`, ZDOTDIR `.zshenv`, `.zshrc`, prompt, completions, functions, and `conf.d/*.zsh` are owned. | `70-hyde.zsh` and `hydectl.zsh` intentionally target the allowed runtime. |

## Zsh Source Files

| File | Role |
|------|------|
| `home/dot_zshenv` | Sets `ZDOTDIR=$XDG_CONFIG_HOME/zsh` and sources `$ZDOTDIR/.zshenv`. |
| `home/dot_config/zsh/dot_zshenv` | Minimal non-interactive XDG env only. |
| `home/dot_config/zsh/dot_zshrc` | Interactive loader for owned `conf.d/*.zsh`; loads `local.zsh` last. |
| `home/dot_config/zsh/conf.d/00-env-hyprland.zsh` | Owned shell/session env baseline; avoids relying on HyDE env for XDG/path values. |
| `home/dot_config/zsh/conf.d/10-paths.zsh` | Owned PATH, Homebrew, mise, Go, depot_tools setup. |
| `home/dot_config/zsh/conf.d/20-prompt.zsh` | Owned Starship/p10k prompt loader. |
| `home/dot_config/zsh/conf.d/30-completions.zsh` | Owned compinit and completions loader. |
| `home/dot_config/zsh/conf.d/31-functions.zsh` | Owned functions loader. |
| `home/dot_config/zsh/conf.d/15-history.zsh` | Owned history behavior. |
| `home/dot_config/zsh/conf.d/25-greeting.zsh` | Owned fastfetch/pokego startup greeting. |
| `home/dot_config/zsh/conf.d/35-fzf.zsh` | Owned fzf integration. |
| `home/dot_config/zsh/conf.d/37-keybindings.zsh` | Owned interactive keybindings. |
| `home/dot_config/zsh/conf.d/40-overrides.zsh` | Owned command overrides and aliases. |
| `home/dot_config/zsh/conf.d/50-qol.zsh` | Owned quality-of-life aliases. |
| `home/dot_config/zsh/conf.d/70-hyde.zsh` | Deliberate HyDE runtime package aliases (`hyde-shell pm`). Keep while `hyde-shell` is the runtime boundary. |
| `home/dot_config/zsh/conf.d/99-local.zsh` | Tracked local loader, sourced last by `.zshrc`. |
| `home/dot_config/zsh/functions/*.zsh` | Owned helper functions. |
| `home/dot_config/zsh/completions/*.zsh` | Owned completions. |

## Zsh Load Order

```
~/.zshenv
  -> ~/.config/zsh/.zshenv   # minimal non-interactive env
  -> ~/.config/zsh/.zshrc    # interactive shell only
    -> conf.d/*.zsh          # owned modules
    -> conf.d/local.zsh      # explicit final override hook
```

`~/.zshenv` is minimal and `.zshrc` owns the interactive startup. This matches fish's philosophy: the shell loads small owned modules, not a HyDE startup manager.

## Fish Source Files

| File | Role |
|------|------|
| `home/dot_config/fish/config.fish` | Minimal entry; fish auto-loads `conf.d/*.fish`. |
| `home/dot_config/fish/conf.d/00-xdg.fish` | Owned XDG/env baseline. |
| `home/dot_config/fish/conf.d/10-paths.fish` | Owned PATH, Homebrew, mise, Go, depot_tools setup. |
| `home/dot_config/fish/conf.d/20-prompt.fish` | Owned greeting and starship setup. |
| `home/dot_config/fish/conf.d/30-fzf.fish` | Owned fzf setup. |
| `home/dot_config/fish/conf.d/40-overrides.fish` | Owned command overrides. |
| `home/dot_config/fish/conf.d/40-qol.fish` | Owned quality-of-life aliases. |
| `home/dot_config/fish/conf.d/50-keybindings.fish` | Owned keybindings. |
| `home/dot_config/fish/conf.d/90-hyde.fish` | Deliberate HyDE runtime package aliases (`hyde-shell pm`). Keep while `hyde-shell` is the runtime boundary. |
| `home/dot_config/fish/functions/*.fish` | Owned functions. |
| `home/dot_config/fish/functions/fzf/*.fish` | Owned fzf navigation/edit helpers. |
| `home/dot_config/fish/completions/hyde-shell.fish` | HyDE CLI completion; acceptable while `hyde-shell` remains engine API. |

Fish is user-owned. The old HyDE-style single `conf.d/hyde.fish` ownership model has been split into small owned modules.

## Environment Variables

| Variable group | Source | Keep? |
|----------------|--------|-------|
| XDG base dirs | zsh `env.zsh`, fish `hyde.fish` | Yes, but centralize in shell-neutral env/UWSM. |
| XDG user dirs | zsh uses `xdg-user-dir`; fish has fixed defaults | Keep if wanted, but avoid duplication. |
| `PATH=$HOME/.local/bin:$PATH` | zsh/fish/UWSM | Yes, but do it once. |
| `LESSHISTFILE`, `PARALLEL_HOME`, `SCREENRC` | zsh/fish/UWSM | Keep if you use those tools. |
| `TERMINFO`, `TERMINFO_DIRS`, `WGETRC`, `PYTHON_HISTORY` | zsh only | Keep only if useful. |
| `HYPRLAND_CONFIG` | shell and UWSM | Move to UWSM/session env, not shell-specific startup. |

Under UWSM, shell env does not control the compositor session. Treat shell env as terminal UX only.

## Useful UX To Keep

| Feature | Files |
|---------|-------|
| `eza` list aliases | `functions/eza.zsh`, `hyde.fish`. |
| `df` -> `duf` wrapper | `functions/duf.zsh`, `hyde.fish`. |
| `bat` cat/help behavior | `functions/bat.zsh`. |
| fzf helpers `ffcd`, `ffe`, `ffec`, `ffch` | `functions/fzf.zsh`, `fish/functions/fzf/*`. |
| Alt+1..9 history insertion | `bind_M_n_history.zsh`, `bind_M_n_history.fish`. |
| slow zsh load warning | `error-handlers.zsh`. |
| `command_not_found_handler` | `error-handlers.zsh`; keep, wrap, or rename its `hyde-shell pm` integration deliberately. |
| starship prompt | `conf.d/prompt.zsh`, fish `conf.d/20-prompt.fish`, `starship.toml`. |

## Coupled Pieces To Decide

| Piece | Decision |
|-------|----------|
| `in`, `un`, `up`, `pl`, `pa` aliases | Accepted because `hyde-shell pm` is inside the permitted runtime boundary. |
| `hyde-shell` / `hydectl` completions | Acceptable while those commands remain engine APIs. Remove only if the commands are dropped or renamed. |
| OMZ install and plugin cloning | `restore_shl.sh` can mutate files outside chezmoi; zsh now only owns the loader/list. |
| Powerlevel10k fallback | Optional; starship is cross-shell and already present. |
| `pokego` / `pokemon-colorscripts` startup art | Not migration-critical. |

## Install And Restore Risks

| Source | Risk |
|--------|------|
| `Scripts/restore_shl.sh` | Installs/updates OMZ, clones plugins, can run `chsh`. |
| `Scripts/restore_zsh.lst` | Plugin list: git, zsh-256color, autosuggestions, syntax highlighting. |
| `Scripts/restore_cfg.psv` | Uses `S` for many shell dirs, so restore overwrites them from HyDE. |
| `Scripts/pkg_core.lst` | Installs `starship` conditionally with `zsh`/`fish`. |
| `Scripts/pkg_extra.lst` | Adds `bat`, `eza`, `duf` conditionally for zsh/fish. |

Shell entries in `restore_cfg.psv` show the real ownership model: `config.fish`, `starship.toml`, zsh `.zshrc`, `user.zsh`, `prompt.zsh`, `plugin.zsh`, `.p10k.zsh` are preserved, but zsh/fish `conf.d`, functions, completions and top-level `.zshenv` are sync-overwritten.

## Current Chezmoi Note

The dotfiles repo contains zsh/fish files under `home/dot_config/zsh` and `home/dot_config/fish`. Both shells now use owned startup modules. Zsh and fish still intentionally expose HyDE package-manager aliases, but those are runtime calls, not startup ownership.

HyDE restore can still overwrite matching target files unless the restore pipeline is no longer used. This is more important than whether shell aliases call `hyde-shell`.

## Migration Stages

| Stage | Action | Status |
|-------|--------|--------|
| 1 | Decide default shell ownership: zsh, fish, or both. | Done: both are tracked by chezmoi. |
| 2 | Keep `ZDOTDIR`, but replace or adopt `conf.d/hyde/terminal.zsh`. | Done: HyDE terminal loader removed from zsh startup. |
| 3 | Decide whether `hyde-shell pm` aliases stay, are renamed, or are wrapped. | Done: aliases stay because they target the permitted runtime. |
| 4 | Decide whether HyDE completions stay, are renamed, or are removed. | Not blocking. Current completion is acceptable. |
| 5 | Keep useful functions by copying/adopting them into owned paths. | Done for current shell startup needs. |
| 6 | Move `HYPRLAND_CONFIG` and Wayland vars out of shell files and into UWSM env. | Done: UWSM env is split by semantic responsibility. |
| 7 | Stop running `restore_shl.sh` or any HyDE restore that syncs shell dirs. | Pending; highest-risk ownership item. |
