#!/usr/bin/env zsh

# Startup greeting. Fish equivalent: the greeting in conf.d/20-prompt.fish.
if [[ $- == *i* && -z ${NO_FAST_FETCH:-} ]]; then
  terminal_columns=${COLUMNS:-0}
  terminal_lines=${LINES:-0}

  if (( terminal_columns >= 50 && terminal_lines >= 28 )); then
    if command -v pokego >/dev/null 2>&1; then
      pokego --no-title -r 1,3,6
    elif command -v pokemon-colorscripts >/dev/null 2>&1; then
      pokemon-colorscripts --no-title -r 1,3,6
    elif command -v fastfetch >/dev/null 2>&1; then
      if ! typeset -f do_render >/dev/null || do_render image; then
        fastfetch --logo-type kitty
      fi
    fi
  fi
fi
