#!/usr/bin/env zsh

# fzf configuration. Fish equivalent: conf.d/30-fzf.fish.
if [[ -r "$HOME/.config/fzf/fzf-config.sh" ]]; then
  source "$HOME/.config/fzf/fzf-config.sh"
fi

if [[ $- == *i* && -o zle && -t 0 ]] && command -v fzf >/dev/null 2>&1 && ! typeset -f __fzfcmd >/dev/null; then
  eval "$(fzf --zsh)"
fi
