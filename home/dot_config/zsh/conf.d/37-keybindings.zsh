#!/usr/bin/env zsh

# Key bindings. Fish equivalent: conf.d/50-keybindings.fish.
function _expand_bang_history {
  if [[ $LBUFFER == *'!' ]]; then
    LBUFFER="${LBUFFER%?}${history[$((HISTCMD - 1))]}"
  else
    LBUFFER+='!'
  fi
}

function _expand_last_argument {
  if [[ $LBUFFER == *'!' ]]; then
    local -a previous_words
    previous_words=(${(z)history[$((HISTCMD - 1))]})
    LBUFFER="${LBUFFER%?}${previous_words[-1]}"
  else
    LBUFFER+='$'
  fi
}

function _history_by_digit {
  local n=${KEYS[-1]}
  local selected=${history[$((HISTCMD - n))]}

  if [[ -n $selected ]]; then
    BUFFER=$selected
    CURSOR=${#BUFFER}
  fi
}

function _expand_pipe_fzf_trigger {
  if [[ $LBUFFER =~ '(^|[[:space:]])\*\*$' ]]; then
    LBUFFER="${LBUFFER%??}| fzf"
  else
    LBUFFER+='*'
  fi
}

if [[ $- == *i* && -o zle && -t 0 ]]; then
  zle -N expand-bang-history _expand_bang_history
  zle -N expand-last-argument _expand_last_argument
  zle -N history-by-digit _history_by_digit
  zle -N expand-pipe-fzf-trigger _expand_pipe_fzf_trigger

  bindkey '!' expand-bang-history
  bindkey '$' expand-last-argument
  bindkey '*' expand-pipe-fzf-trigger

  for n in {1..9}; do
    bindkey "^[${n}" history-by-digit
  done

  bindkey '^[[H' beginning-of-line
  bindkey '^[[F' end-of-line
fi
