#!/usr/bin/env zsh

# Load owned zsh functions after completion setup.
for file in "$ZDOTDIR"/functions/*.zsh; do
  [[ -r "$file" ]] && source "$file"
done
