function fzf_expand_pipe_trigger --description 'Expand *** to | fzf'
    if test (commandline -t) = '**'
        commandline -t '| fzf'
        commandline -f repaint
    else
        commandline -i '*'
    end
end
