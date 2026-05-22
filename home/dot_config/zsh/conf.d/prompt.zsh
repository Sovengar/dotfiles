#!/usr/bin/env zsh

function terminal_supports_images {
  local current_terminal="${TERM_PROGRAM:-$(ps -o comm= -p "$(ps -o ppid= -p $$)")}"
  local image_terminals=(kitty konsole ghostty WezTerm)

  [[ " ${image_terminals[*]} " == *" $current_terminal "* ]]
}

function terminal_is_large_enough {
  local columns=${COLUMNS:-0}
  local lines=${LINES:-0}

  (( columns >= 50 && lines >= 28 ))
}

function render_greeting {
  [[ -n ${NO_GREETING:-} ]] && return
  terminal_is_large_enough || return

  local choices=()
  command -v fastfetch >/dev/null 2>&1 && choices+=(fastfetch)
  command -v pokego >/dev/null 2>&1 && choices+=(pokego)
  command -v pokemon-colorscripts >/dev/null 2>&1 && choices+=(pokemon-colorscripts)

  (( ${#choices[@]} > 0 )) || return

  local selected=${choices[$(( RANDOM % ${#choices[@]} + 1 ))]}
  case $selected in
    fastfetch)
      if terminal_supports_images; then
        fastfetch --logo-type kitty
      else
        fastfetch
      fi
      ;;
    pokego)
      pokego --no-title -r 1,3,6
      ;;
    pokemon-colorscripts)
      pokemon-colorscripts --no-title -r 1,3,6
      ;;
  esac
}

if [[ $- == *i* ]]; then
  render_greeting
fi

if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CACHE="$XDG_CACHE_HOME/starship"
  export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
  eval "$(starship init zsh)"
fi
