#!/usr/bin/env zsh

# Quality-of-life aliases. Fish equivalent: conf.d/40-qol.fish.
alias c='clear'
alias g='git'

alias op='opencode'
alias lgit='lazygit'

alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

alias mkdir='mkdir -p'

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
