# Shells Migration

> Goal: make zsh/fish config ownership independent from HyDE restore files while allowing `hyde-shell` to remain as a runtime engine command.

Using `hyde-shell` from a shell alias is not automatically a problem. The blocker is HyDE dictating shell startup files under `~/.config/fish` or `~/.config/zsh`.

## Current Status

| Shell | Status | What is owned | What still needs a decision |
|-------|--------|---------------|-----------------------------|
| Fish | Mostly owned | `config.fish`, `conf.d/*.fish`, functions, plugins, and theme README live in chezmoi. | `90-hyde.fish` aliases and `hyde-shell.fish` completion can stay, be renamed, or be wrapped later. |
| Zsh | Partial | Env/path/fzf/history/QoL/keybinding/greeting modules exist as owned `conf.d/*.zsh`. | `00-hyde.zsh` still sources `conf.d/hyde/env.zsh` and `conf.d/hyde/terminal.zsh`; this still lets HyDE define the main interactive startup flow. |

## Zsh Source Files

| File | Role |
|------|------|
| `Configs/.zshenv` | Sets `ZDOTDIR=$XDG_CONFIG_HOME/zsh` and sources `$ZDOTDIR/.zshenv`. |
| `Configs/.config/zsh/.zshenv` | Sources every `conf.d/*.zsh`. |
| `home/dot_config/zsh/conf.d/00-env-hyprland.zsh` | Owned shell/session env baseline; avoids relying only on HyDE env for XDG/path values. |
| `home/dot_config/zsh/conf.d/10-paths.zsh` | Owned PATH, Homebrew, mise, Go, depot_tools setup. |
| `home/dot_config/zsh/conf.d/15-history.zsh` | Owned history behavior. |
| `home/dot_config/zsh/conf.d/25-greeting.zsh` | Owned startup greeting. |
| `home/dot_config/zsh/conf.d/35-fzf.zsh` | Owned fzf integration. |
| `home/dot_config/zsh/conf.d/37-keybindings.zsh` | Owned interactive keybindings. |
| `home/dot_config/zsh/conf.d/40-overrides.zsh` | Owned command overrides and aliases. |
| `home/dot_config/zsh/conf.d/50-qol.zsh` | Owned quality-of-life aliases. |
| `home/dot_config/zsh/conf.d/70-hyde.zsh` | Deliberate HyDE engine aliases (`hyde-shell pm`). Rename/wrap later if wanted. |
| `home/dot_config/zsh/conf.d/00-hyde.zsh` | Transitional loader that still sources HyDE's zsh engine. |
| `home/dot_config/zsh/conf.d/hyde/env.zsh` | Legacy HyDE env compatibility. Should shrink or disappear once owned env is sufficient. |
| `home/dot_config/zsh/conf.d/hyde/terminal.zsh` | Remaining main coupling: compinit, OMZ/plugin loading, prompt, functions, completions, aliases. |
| `Configs/.config/zsh/user.zsh` | User overrides for prompt/plugins/startup art. |
| `Configs/.config/zsh/plugin.zsh` | Disabled by default; example zinit setup. |
| `Configs/.config/zsh/prompt.zsh` | Disabled by default; custom prompt hook. |
| `Configs/.config/zsh/functions/*.zsh` | bat, duf, eza, fzf, history bind, help keybind, error handlers. |
| `Configs/.config/zsh/completions/*.zsh` | fzf, hydectl, hyde-shell completions. |

## Zsh Load Order

```
~/.zshenv
  -> ~/.config/zsh/.zshenv
    -> conf.d/*.zsh
      -> 00-hyde.zsh
        -> hyde/env.zsh
        -> hyde/terminal.zsh for interactive shells
          -> user.zsh
          -> compinit
          -> plugin.zsh or oh-my-zsh
          -> prompt.zsh or hyde/prompt.zsh
          -> functions/*.zsh
          -> completions/*.zsh
          -> .zshrc
```

`~/.zshrc` is deliberately late and mostly empty. The remaining ownership problem is not that zsh can call `hyde-shell`; it is that `conf.d/hyde/terminal.zsh` still owns too much of the interactive startup flow.

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
| `home/dot_config/fish/conf.d/90-hyde.fish` | Deliberate HyDE engine aliases (`hyde-shell pm`). Rename/wrap later if wanted. |
| `home/dot_config/fish/functions/*.fish` | Owned functions. |
| `home/dot_config/fish/functions/fzf/*.fish` | Owned fzf navigation/edit helpers. |
| `home/dot_config/fish/completions/hyde-shell.fish` | HyDE CLI completion; acceptable while `hyde-shell` remains engine API. |

Fish is now mostly user-owned. The old HyDE-style single `conf.d/hyde.fish` ownership model has been split into small owned modules.

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
| starship prompt | `conf.d/hyde/prompt.zsh`, `hyde.fish`, `starship.toml`. |

## Coupled Pieces To Decide

| Piece | Decision |
|-------|----------|
| `in`, `un`, `up`, `pl`, `pa` aliases | Acceptable if `hyde-shell pm` remains the chosen package-manager engine. Rename/wrap only for branding or control. |
| `hyde-shell` / `hydectl` completions | Acceptable while those commands remain engine APIs. Remove only if the commands are dropped or renamed. |
| OMZ install and plugin cloning | `restore_shl.sh` owns this and can mutate files outside chezmoi. |
| Powerlevel10k fallback | Optional; starship is cross-shell and already present. |
| `pokego` / `pokemon-colorscripts` startup art | Not migration-critical. |
| `conf.d/hyde/terminal.zsh` | Main remaining zsh ownership problem. Replace with a small owned loader or explicitly adopt it into this repo. |

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

The dotfiles repo contains zsh/fish files under `home/dot_config/zsh` and `home/dot_config/fish`. Fish is already split into owned modules. Zsh is halfway there: many owned modules exist, but the HyDE terminal loader still controls important interactive behavior.

HyDE restore can still overwrite matching target files unless the restore pipeline is no longer used. This is more important than whether shell aliases call `hyde-shell`.

## Migration Stages

| Stage | Action | Status |
|-------|--------|--------|
| 1 | Decide default shell ownership: zsh, fish, or both. | Done: both are tracked by chezmoi. |
| 2 | Keep `ZDOTDIR`, but replace or adopt `conf.d/hyde/terminal.zsh`. | Partial: owned modules exist, HyDE terminal loader remains. |
| 3 | Decide whether `hyde-shell pm` aliases stay, are renamed, or are wrapped. | Not blocking. Current aliases are acceptable. |
| 4 | Decide whether HyDE completions stay, are renamed, or are removed. | Not blocking. Current completion is acceptable. |
| 5 | Keep useful functions by copying/adopting them into owned paths. | Mostly done for fish; partial for zsh. |
| 6 | Move `HYPRLAND_CONFIG` and Wayland vars out of shell files and into UWSM env. | Pending. |
| 7 | Stop running `restore_shl.sh` or any HyDE restore that syncs shell dirs. | Pending; highest-risk ownership item. |
