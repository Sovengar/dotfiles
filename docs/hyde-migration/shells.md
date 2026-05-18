# Shells Migration

> Goal: make zsh/fish independent from HyDE while keeping useful UX pieces.

## Zsh Source Files

| File | Role |
|------|------|
| `Configs/.zshenv` | Sets `ZDOTDIR=$XDG_CONFIG_HOME/zsh` and sources `$ZDOTDIR/.zshenv`. |
| `Configs/.config/zsh/.zshenv` | Sources every `conf.d/*.zsh`. |
| `Configs/.config/zsh/conf.d/00-hyde.zsh` | Sources `hyde/env.zsh`; sources `hyde/terminal.zsh` only for interactive shells. |
| `Configs/.config/zsh/conf.d/hyde/env.zsh` | XDG dirs, `PATH`, app env redirects, `HYPRLAND_CONFIG`. |
| `Configs/.config/zsh/conf.d/hyde/terminal.zsh` | Main engine: user config, compinit, OMZ/plugin loading, prompt, functions, completions, aliases. |
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

`~/.zshrc` is deliberately late and mostly empty. HyDE owns the real zsh startup through `ZDOTDIR` and `conf.d/hyde/terminal.zsh`.

## Fish Source Files

| File | Role |
|------|------|
| `Configs/.config/fish/config.fish` | Empty user entry. |
| `Configs/.config/fish/conf.d/hyde.fish` | XDG vars, PATH, starship, duf override, history bind, aliases. |
| `Configs/.config/fish/user.fish` | User settings, `EDITOR`, `aurhelper`, alias examples. |
| `Configs/.config/fish/functions/bind_M_n_history.fish` | Alt+number history insertion. |
| `Configs/.config/fish/functions/fzf/*.fish` | fzf navigation/edit helpers. |
| `Configs/.config/fish/completions/hyde-shell.fish` | HyDE CLI completions. |

Fish is much simpler than zsh. HyDE logic mostly lives in one `conf.d/hyde.fish` file.

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
| `command_not_found_handler` | `error-handlers.zsh`, but replace `hyde-shell pm`. |
| starship prompt | `conf.d/hyde/prompt.zsh`, `hyde.fish`, `starship.toml`. |

## Coupled Pieces To Replace

| Piece | Why replace |
|-------|-------------|
| `in`, `un`, `up`, `pl`, `pa` aliases | They call `hyde-shell pm`. Replace with `paru`, `yay`, `pacman`, or your own wrapper. |
| `hyde-shell` / `hydectl` completions | Dead weight after HyDE removal. |
| OMZ install and plugin cloning | `restore_shl.sh` owns this and can mutate files outside chezmoi. |
| Powerlevel10k fallback | Optional; starship is cross-shell and already present. |
| `pokego` / `pokemon-colorscripts` startup art | Not migration-critical. |
| `conf.d/hyde/terminal.zsh` | Most complexity exists for OMZ/deferred loading. Replace with a small owned loader. |

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

The dotfiles repo already contains HyDE zsh/fish files under `home/dot_config/zsh` and `home/dot_config/fish`. This means chezmoi can become the owner, but HyDE restore can still overwrite matching target files unless the restore pipeline is no longer used.

## Migration Stages

| Stage | Action |
|-------|--------|
| 1 | Decide default shell ownership: zsh, fish, or both. |
| 2 | Keep `ZDOTDIR`, but replace `conf.d/hyde/terminal.zsh` with an owned loader. |
| 3 | Replace `hyde-shell pm` aliases with native package commands. |
| 4 | Remove HyDE completions. |
| 5 | Keep useful functions by copying them into neutral paths. |
| 6 | Move `HYPRLAND_CONFIG` and Wayland vars out of shell files and into UWSM env. |
| 7 | Stop running `restore_shl.sh` or any HyDE restore that syncs shell dirs. |
