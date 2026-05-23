#!/usr/bin/env zsh

# Completion setup before owned completion snippets are sourced.
fpath=("$ZDOTDIR/completions" $fpath)

autoload -Uz compinit
setopt EXTENDED_GLOB
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+${HYDE_ZSH_COMPINIT_CHECK:-1}) ]]; then
  compinit
else
  compinit -C
fi

_comp_options+=(globdots)

for file in "$ZDOTDIR"/completions/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done
