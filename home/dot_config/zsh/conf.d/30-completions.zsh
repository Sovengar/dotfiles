#!/usr/bin/env zsh

fpath=("$ZDOTDIR/completions" $fpath)

if (( ! ${+_comps} )); then
  autoload -Uz compinit

  if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+${ZSH_COMPINIT_CHECK_HOURS:-1}) ]]; then
    compinit
  else
    compinit -C
  fi
fi

for file in "$ZDOTDIR"/completions/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done

_comp_options+=(globdots)
