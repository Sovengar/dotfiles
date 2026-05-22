#!/usr/bin/env fish

function fish_greeting
    set -l terminal_columns 0
    set -l terminal_lines 0

    set -q COLUMNS; and set terminal_columns $COLUMNS
    set -q LINES; and set terminal_lines $LINES

    if set -q NO_GREETING; or test "$terminal_columns" -lt 50; or test "$terminal_lines" -lt 28
        return
    end

    if test (random) -le 16384
        set -l tmp (mktemp)
        if type -q pokego
            pokego --no-title -r 1,3,6 > $tmp
        else if type -q pokemon-colorscripts
            pokemon-colorscripts --no-title -r 1,3,6 > $tmp
        end
        if test -s $tmp
            type -q fastfetch; and fastfetch --file-raw $tmp; or cat $tmp
        else
            type -q fastfetch; and fastfetch --logo-type kitty
        end
        rm -f $tmp
    else
        type -q fastfetch; and fastfetch --logo-type kitty
    end
end

if type -q starship
    starship init fish | source
    set -gx STARSHIP_CACHE $XDG_CACHE_HOME/starship
    set -gx STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml
end

set fish_pager_color_prefix cyan
set fish_color_autosuggestion brblack
