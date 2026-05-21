#!/usr/bin/env fish

alias c='clear'
alias g='git'

alias op='opencode'
alias lgit='lazygit'

alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

if type -q zoxide
    zoxide init fish | source
end

abbr mkdir 'mkdir -p'
