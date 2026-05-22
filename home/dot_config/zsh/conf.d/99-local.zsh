#!/usr/bin/env zsh

# Machine-local values live here. Do not commit secrets from this file.
# Put private exports in ~/.config/zsh/local.zsh; this file is a tracked loader.
if [[ -r "$ZDOTDIR/local.zsh" ]]; then
  source "$ZDOTDIR/local.zsh"
fi
