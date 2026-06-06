#!/usr/bin/env fish

alias cl='clear'
alias g='git'
alias gco='git checkout'
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gb='git branch'
alias gd='git diff'
alias gl='git log'
alias gp='git push'

alias op='opencode'
alias lgit='lazygit'
alias ldk='lazydocker'
alias lzn='lazynpm'

alias ..='cd ..'
alias ...='cd /home/buble'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'
alias ..6='cd ../../../../../..'
alias ..7='cd ../../../../../../..'
alias ..8='cd ../../../../../../../..'

# NOTE: zoxide provides `z` and `zi` for navigation — don't alias those.
if type -q zoxide
    zoxide init fish | source
end

abbr mkdir 'mkdir -p'
abbr vi nvim
