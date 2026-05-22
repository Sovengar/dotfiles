#!/usr/bin/env zsh

[[ ${ZSH_NO_PLUGINS:-0} == 1 ]] && return

for zsh_path in /usr/share/oh-my-zsh /usr/local/share/oh-my-zsh "$HOME/.oh-my-zsh"; do
  if [[ -d $zsh_path ]]; then
    export ZSH="$zsh_path"
    break
  fi
done

[[ -r $ZSH/oh-my-zsh.sh ]] || return

ZSH_THEME=""
plugins=(
  git
  sudo
  zsh-256color
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"
