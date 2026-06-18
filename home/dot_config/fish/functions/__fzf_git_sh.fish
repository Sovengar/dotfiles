function __fzf_git_sh
    set -l fzf_git (command -v fzf-git.sh)
    or begin
        echo "fzf-git.sh not found in PATH" >&2
        return 1
    end

    set --function result (SHELL=bash bash $fzf_git --run $argv | string join ' ')

    if status is-command-substitution && test -n "$result"
        echo -- $result
    else
        commandline --insert $result
        commandline -f repaint
    end
end

function __fzf_git_files
    __fzf_git_sh files
end

function __fzf_git_branches
    __fzf_git_sh branches
end

function __fzf_git_tags
    __fzf_git_sh tags
end

function __fzf_git_remotes
    __fzf_git_sh remotes
end

function __fzf_git_hashes
    __fzf_git_sh hashes
end

function __fzf_git_stashes
    __fzf_git_sh stashes
end

function __fzf_git_lreflogs
    __fzf_git_sh lreflogs
end

function __fzf_git_each_ref
    __fzf_git_sh each_ref
end

function __fzf_git_worktrees
    __fzf_git_sh worktrees
end

function __fzf_git_list_bindings
    echo "CTRL-G ?    Show this list"
    echo "CTRL-G CTRL-F    Files"
    echo "CTRL-G CTRL-B    Branches"
    echo "CTRL-G CTRL-T    Tags"
    echo "CTRL-G CTRL-R    Remotes"
    echo "CTRL-G CTRL-H    Commit Hashes"
    echo "CTRL-G CTRL-S    Stashes"
    echo "CTRL-G CTRL-L    Reflogs"
    echo "CTRL-G CTRL-W    Worktrees"
    echo "CTRL-G CTRL-E    Each ref (git for-each-ref)"
end