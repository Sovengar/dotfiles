#!/usr/bin/env zsh

# PATH configuration. Fish equivalent: conf.d/10-paths.fish.
typeset -U path

path=("$HOME/.local/bin" $path)

if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

path=("$HOME/.local/share/mise/shims" "$HOME/go/bin" $path)

if [[ -d "$HOME/Applications/depot_tools" ]]; then
  path=("$HOME/Applications/depot_tools" $path)
fi

export PATH
