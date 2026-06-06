#!/usr/bin/env zsh

# Command overrides. Fish equivalent: conf.d/40-overrides.fish.
if command -v duf >/dev/null 2>&1; then
  function df {
    if [[ $# -ge 1 && -e "${@: -1}" ]]; then
      duf "${@: -1}"
    else
      duf
    fi
  }
fi

if command -v eza >/dev/null 2>&1; then
  alias l='eza -lh --icons=auto'
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first'
  alias la='eza -a --icons --group-directories-first'
  alias lla='eza -la --icons --group-directories-first'
  alias lah='eza -lah --icons --group-directories-first'
  alias ld='eza -lhD --icons=auto'
  alias lt='eza -aT --color=always --group-directories-first --icons'

  function cd {
    builtin cd "$@" || return
    [[ $PWD == "$HOME" ]] && return 0
    command eza --icons --group-directories-first 2>/dev/null || true
  }
fi

if command -v fastfetch >/dev/null 2>&1; then
  alias fastfetch='fastfetch --logo-type kitty'
fi

if command -v bat >/dev/null 2>&1; then
  alias -g -- --help='--help 2>&1 | bat --language=help --style=plain --paging=never --color always'
  alias cat='bat --style=plain --paging=never --color auto'
fi

export MANROFFOPT='-c'
if [[ -x "$HOME/.local/bin/manpager" ]]; then
  export MANPAGER="$HOME/.local/bin/manpager"
fi

function history {
  builtin history -i
}
