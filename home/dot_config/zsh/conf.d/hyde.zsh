#!/usr/bin/env zsh

# HyDE package-manager aliases. Fish equivalent: conf.d/90-hyde.fish.
PM_COMMAND=(hyde-shell pm)

function __package_manager {
  ${PM_COMMAND[@]} "$@"
}

alias in='hyde-shell pm install'
alias un='hyde-shell pm remove'
alias up='hyde-shell pm upgrade'
alias pl='hyde-shell pm search installed'
alias pa='hyde-shell pm search all'
