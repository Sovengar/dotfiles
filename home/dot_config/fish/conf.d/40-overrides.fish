#!/usr/bin/env fish

set -l os_id
if test -r /etc/os-release
    set os_id (string match -r '^ID=.*' </etc/os-release | string replace -r '^ID="?([^"]*)"?$' '$1')
end

if type -q duf
    function df -d "Run duf with last argument if valid, else run duf"
        if set -q argv[-1] && test -e $argv[-1]
            duf $argv[-1]
        else
            duf
        end
    end
end

if type -q eza
    alias l='eza -lh --icons=auto'
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lla='eza -la --icons --group-directories-first'
    alias lah='eza -lah --icons --group-directories-first'
    alias ld='eza -lhD --icons=auto'
    alias lt='eza -aT --color=always --group-directories-first --icons'

    function cd --description "Change directory and list contents"
        if not builtin cd $argv
            return 1
        end
        test "$PWD" = "$HOME" && return 0
        eza --icons --group-directories-first 2>/dev/null
    end
end

if type -q fastfetch
    alias fastfetch='fastfetch --logo-type kitty'
end

set -gx MANROFFOPT "-c"
if test -x $HOME/.local/bin/manpager
    set -gx MANPAGER $HOME/.local/bin/manpager
end

function history
    builtin history --show-time='%F %T '
end

if test "$os_id" = cachyos
    alias wget='wget -c '
end
