#!/usr/bin/env fish

if type -q btop
    alias htop='btop'
end

if type -q dust
    alias du='dust'
end

if type -q duf
    alias df='duf'
end

if type -q eza
    function cd --description "Change directory and list contents"
        if not builtin cd $argv
            return 1
        end
        test "$PWD" = "$HOME" && return 0
        eza --icons --group-directories-first 2>/dev/null
    end
end

function history
    builtin history --show-time='%F %T '
end

