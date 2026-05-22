#!/usr/bin/env fish

function fish_greeting
    set -l terminal_columns 0
    set -l terminal_lines 0

    set -q COLUMNS; and set terminal_columns $COLUMNS
    set -q LINES; and set terminal_lines $LINES

    if set -q NO_GREETING; or not type -q fastfetch; or test "$terminal_columns" -lt 50; or test "$terminal_lines" -lt 28
        return
    end

    fastfetch --logo-type kitty
end

if type -q starship
    starship init fish | source
    set -gx STARSHIP_CACHE $XDG_CACHE_HOME/starship
    set -gx STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml
end

set fish_pager_color_prefix cyan
set fish_color_autosuggestion brblack
