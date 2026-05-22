#!/usr/bin/env zsh

# Startup greeting. Fish equivalent: the greeting in conf.d/20-prompt.fish.
if [[ $- == *i* && -z ${NO_FAST_FETCH:-} ]]; then
  terminal_columns=${COLUMNS:-0}
  terminal_lines=${LINES:-0}

  if (( terminal_columns >= 50 && terminal_lines >= 28 )); then
    if (( RANDOM % 2 == 0 )); then
      tmp=$(mktemp)
      if command -v pokego >/dev/null 2>&1; then
        pokego --no-title -r 1,2,3,4,5 > "$tmp"
      elif command -v pokemon-colorscripts >/dev/null 2>&1; then
        pokemon-colorscripts --no-title -r 1,2,3,4,5 > "$tmp"
      fi
      if [[ -s "$tmp" ]]; then
        if command -v fastfetch >/dev/null 2>&1; then
          fastfetch --file-raw "$tmp"
        else
          cat "$tmp"
        fi
      else
        if command -v fastfetch >/dev/null 2>&1; then
          fastfetch --logo-type kitty
        fi
      fi
      rm -f "$tmp"
    else
      if command -v fastfetch >/dev/null 2>&1; then
        fastfetch --logo-type kitty
      fi
    fi
  fi
fi