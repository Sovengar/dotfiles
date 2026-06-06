#!/usr/bin/env zsh

# Quality-of-life aliases. Fish equivalent: conf.d/40-qol.fish.
alias cl='clear'
alias g='git'

alias op='opencode'
alias lgit='lazygit'
alias ldk='lazydocker'
alias lzn='lazynpm'

alias gco='git checkout'
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gb='git branch'
alias gd='git diff'
alias gl='git log'
alias gp='git push'

alias ..='cd ..'
alias ...='cd /home/buble'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'
alias ..6='cd ../../../../../..'
alias ..7='cd ../../../../../../..'
alias ..8='cd ../../../../../../../..'

alias mkdir='mkdir -p'
alias vi='nvim'

# NOTE: zoxide provides `z` and `zi` for navigation — don't alias those.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
