function __fzf_git_prefix
    commandline -f repaint
    echo -n -s (set_color --bold brgreen) 'G' (set_color normal)
    set -l key (read -n 1 -s -p '')
    switch "$key"
        case f
            __fzf_git_sh files
        case b
            __fzf_git_sh branches
        case t
            __fzf_git_sh tags
        case h
            __fzf_git_sh hashes
        case s
            __fzf_git_sh stashes
        case r
            __fzf_git_sh remotes
        case l
            __fzf_git_sh lreflogs
        case e
            __fzf_git_sh each_ref
        case w
            __fzf_git_sh worktrees
        case '?'
            __fzf_git_list_bindings
        case '*'
            echo -n (set_color red)'?'(set_color normal)
    end
    commandline -f repaint
end

function __fzf_git_list_bindings
    echo ''
    echo (set_color brgreen)'CTRL-G f'(set_color normal)  '_files'
    echo (set_color brgreen)'CTRL-G b'(set_color normal)  ' _branches'
    echo (set_color brgreen)'CTRL-G t'(set_color normal)  ' _tags'
    echo (set_color brgreen)'CTRL-G r'(set_color normal)  ' _remotes'
    echo (set_color brgreen)'CTRL-G h'(set_color normal)  ' _commit hashes'
    echo (set_color brgreen)'CTRL-G s'(set_color normal)  ' _stashes'
    echo (set_color brgreen)'CTRL-G l'(set_color normal)  ' _reflogs'
    echo (set_color brgreen)'CTRL-G e'(set_color normal)  ' _each ref'
    echo (set_color brgreen)'CTRL-G w'(set_color normal)  ' _worktrees'
    echo (set_color brgreen)'CTRL-G ?'(set_color normal)  ' _this list'
    commandline -f repaint
end