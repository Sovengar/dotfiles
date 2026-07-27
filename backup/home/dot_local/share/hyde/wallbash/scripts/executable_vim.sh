#!/usr/bin/env bash

confDir="${confDir:-${XDG_CONFIG_HOME:-$HOME/.config}}"
vim_colors="${confDir}/vim/colors/wallbash.vim"
nvim_colors="${confDir}/nvim/colors/wallbash.vim"

[ -f "$vim_colors" ] || exit 0
mkdir -p "$(dirname "$nvim_colors")"
cp "$vim_colors" "$nvim_colors"
