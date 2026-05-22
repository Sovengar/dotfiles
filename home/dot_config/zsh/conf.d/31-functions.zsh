#!/usr/bin/env zsh

for file in "$ZDOTDIR"/functions/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done
