#!/usr/bin/env zsh

# Command overrides (functions, not aliases). Fish equivalent: conf.d/40-overrides.fish.

if command -v btop >/dev/null 2>&1; then
  alias htop='btop'
fi

if command -v dust >/dev/null 2>&1; then
  alias du='dust'
fi

if command -v duf >/dev/null 2>&1; then
  alias df='duf'
fi

if command -v sd >/dev/null 2>&1; then
  alias sed='sd'
fi

if command -v eza >/dev/null 2>&1; then
  function cd {
    builtin cd "$@" || return
    [[ $PWD == "$HOME" ]] && return 0
    command eza --icons --group-directories-first 2>/dev/null || true
  }
fi

function history {
  builtin history -i
}
