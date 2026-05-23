#!/usr/bin/env zsh

# Prompt setup. Fish equivalent: conf.d/20-prompt.fish.
if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/starship"
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
  eval "$(starship init zsh)"
elif [[ -r "$HOME/.p10k.zsh" || -r "$ZDOTDIR/.p10k.zsh" ]]; then
  POWERLEVEL10K_TRANSIENT_PROMPT=same-dir
  P10K_THEME=${P10K_THEME:-/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme}
  [[ -r "$P10K_THEME" ]] && source "$P10K_THEME"
  [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
  [[ -r "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"
fi
