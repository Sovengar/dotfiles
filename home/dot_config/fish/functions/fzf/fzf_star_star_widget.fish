function fzf_star_star_widget --description "Expand ** with fzf"
    if not type -q fzf
        commandline -f repaint
        return
    end

    set -l token (commandline -ct)
    if not string match -q '*\*\*' -- $token
        commandline -f repaint
        return
    end

    set -l command (commandline -xpc)[1]
    set -l query (string replace -r '\*\*$' '' -- $token)
    set -l fzf_command fzf

    if functions -q __fzfcmd
        set fzf_command (__fzfcmd)
    end

    switch $command
        case kill
            __fzf_star_star_processes $fzf_command $query
        case '*'
            __fzf_star_star_paths $fzf_command $query
    end
end

function __fzf_star_star_processes --argument-names fzf_command query
    set -l selected (ps -eo pid=,user=,comm=,args= \
        | $fzf_command --height 80% --layout reverse --cycle --multi --prompt 'process> ' --query "$query")

    if test -z "$selected"
        commandline -f repaint
        return
    end

    set -l pids
    for line in $selected
        set -a pids (string split -n ' ' -- (string trim -- $line))[1]
    end

    commandline -t -- (string join ' ' $pids)
    commandline -i ' '
    commandline -f repaint
end

function __fzf_star_star_paths --argument-names fzf_command query
    set -l selected

    if type -q fd
        set selected (fd --hidden --follow --exclude .git --exclude node_modules --exclude .cache --exclude .venv \
            | $fzf_command --height 80% --layout reverse --cycle --multi --prompt 'path> ' --query "$query")
    else
        set selected (find . -path ./.git -prune -o -path ./node_modules -prune -o -path ./.cache -prune -o -path ./.venv -prune -o -print 2>/dev/null \
            | $fzf_command --height 80% --layout reverse --cycle --multi --prompt 'path> ' --query "$query")
    end

    if test -z "$selected"
        commandline -f repaint
        return
    end

    commandline -t -- (string join ' ' (string escape -- $selected))
    commandline -i ' '
    commandline -f repaint
end
