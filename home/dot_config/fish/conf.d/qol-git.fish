#!/usr/bin/env fish

# Git abbreviations, aliases, and functions.
# Checkout deshabilitado — usar git switch (ramas) o git restore (archivos)
function git --wraps git
    if set -q argv[1]
        switch $argv[1]
            case checkout
                echo "Use git switch (branches) or git restore (files) instead of checkout" >&2
                return 1
            case '?'
                _git_abbrv_list
                return
            case sync isync
                if test (count $argv) -lt 2
                    echo "Usage: git $argv[1] <branch>" >&2
                    return 1
                end
                if test $argv[1] = sync
                    command git pull --rebase --autostash origin $argv[2]
                else
                    command git pull --rebase=interactive --autostash origin $argv[2]
                end
                return
        end
    end
    command git $argv
end

# Cumulative abbreviations: expand subcommand only after "git"
abbr g git  # "g" → "git", abrevia todos los comandos

# Pull
    # No pull abbr to enforce usage of "u" (pull --rebase --autostash)    
    abbr fe --command git 'fetch --prune --all'  # Fetch all branches + Delete remote branches that have been deleted in any remote. Defaults to remote origin if it only exists one.
    abbr rb --command git --function __abbr_rb  # [Default] rebase. Use º for fzf branch selector.

# Update working branch (feat/login) with latest remote changes
    abbr u --command git 'pull --rebase --autostash'  # Updates your branch putting newer remote commits on top, then append your LOCAL commits.
    abbr iu --command git 'pull --rebase=interactive --autostash'  # Interactively Updates your branch putting newer remote commits on top, then append your LOCAL commits.

# Foreign branch -> Current branch
    abbr mg --command git --function __abbr_mg  # Merge commits from another branch onto your current branch. Use º for fzf branch selector.
    abbr ffmg --command git --function __abbr_ffmg  # Fast-forward only merge, use º for fzf branch selector.
    abbr smg --command git --function __abbr_smg  # Squash merge, use º for fzf branch selector.

# Sync working branch fetching foreign branch (main, develop, deploy, ...)
    abbr sync --command git --function __abbr_sync  # pull --rebase --autostash origin <branch>. Uses º for fzf.
    abbr isync --command git --function __abbr_isync  # pull --rebase=interactive --autostash origin <branch>. Uses º.

# Push
    abbr p --command git push  # Push commits to remote branch (default: origin current-branch)
    abbr fp --command git 'push --force-with-lease --force-if-includes'  # Force push with security (doesn't override if are new remote commits), use by default after a secured ammend/rebase.

# Branching
    abbr br --command git branch # [Default] Branch command
    abbr sw --command git --function __abbr_swbr  # Switch to Branch, use º for fzf.
    abbr cbr --command git 'switch -c'  # Create and switch to a new branch.
    abbr dbr --command git --function __abbr_dbr  # Delete branch, type º for fzf.

# Move between Working Directory, Staging area, Local branch
    abbr a --command git 'add'  # Add one change to stage area (new, modified, deleted)
    abbr aa --command git 'add -A'  # Add all changes to stage area (new, modified, deleted)
    abbr ia --command git 'add --patch'  # Add changes interactively to stage area (new, modified, deleted)
    abbr us --command git 'restore --staged'  # Undo Stage of a file.
    abbr c --command git --set-cursor=! 'commit -m "!"'  # Commit.

    abbr uc --command git --set-cursor=! 'reset --soft HEAD~!'  # Undo last n commits. Use with local commits or remote commits not pulled by anyone.
    abbr ulc --command git --function __abbr_ulc  # Undo all local commits.

# Compaction
    abbr amend --command git 'commit -a --amend --no-edit'  # Amends last commit with staged files rewritting history. Use with local commits or remote commits not pulled by anyone.
    abbr polish --command git --function __abbr_polish --set-cursor=!  # Rebase -i of the last n commits. Use with local commits or remote commits not pulled by anyone.
    abbr local-polish --command git --function __abbr_local_polish   # Rebase -i of the last local commits.
    abbr absorb --command git 'absorb'  # Absorbs changes on fixup commits automatically.

# Deletion, Clear, Discard
    abbr cl --command git 'restore --source=HEAD --staged --worktree .' # Clears the working directory and staging area. 
    abbr cl-wd --command git 'restore --source=HEAD --worktree .' # Clears the working directory.
    abbr cl-sa --command git 'restore --source=HEAD --staged' # Clears the staging area. 
    abbr da --command git --set-cursor=! 'reset --hard HEAD~!'  # Deletes all (Working directory, Staging, commits) of the last ! commits. Use with local commits or remote commits not pulled by anyone.
    abbr discard --command git --function __abbr_discard --set-cursor=!  # Discard changes in the specified file, staged or unstaged. 

# Revert changes safely
    abbr undo --command git 'revert --no-edit HEAD'  # Undo last commit by creating an inverse commit. [Safe]
    abbr rollback --command git --function __abbr_rollback  # Rollback <commit> by creating an inverse commit. Use º for fzf commit selector. [Safe]

# State
    abbr st --command git status --short  # Status (porcelain)
    abbr sta --command git status  # Status of all
    abbr sh --command git --function __abbr_sh  # Show <file/commit/branch>
    abbr sh-hunk 'hunk show'  # Review commit with hunk TUI
    abbr wc --command git 'whatchanged -p --abbrev-commit --pretty=medium' #Shows what changed since last commit

    abbr d --command git --function __abbr_diff  # Diff without whitespace changes.
    abbr d-hunk 'hunk diff'  # Review working tree with hunk TUI
    abbr show-hunk 'hunk show'  # Review commit with hunk TUI
        abbr s --command git --function __abbr_s  # Adds --staged (Only expands after "diff" or "d")
    abbr releasediff --command git 'h --first-parent latest..HEAD'  # Diff between latest and HEAD (same format as h)
    
# Lists
    abbr lsbr --command git --function __abbr_lsbr  # List and switch branches with fzf preview
    abbr lsmbr --command git 'branch --merged'  # Lists merged branches (To cleanup them)
    abbr lsft --command git ls-files  # Lists files tracked by git.
    abbr lsrl --command git reflog  # Lists the reflog.
    # Fancy log: git h → ~/.local/bin/git-h (parents solo en merge commits)

# Pull Requests
    abbr pr --function __abbr_pr  # Create PR/MR with auto fill (detects GitHub/GitLab)
    abbr prw --function __abbr_prw  # Create PR/MR and open in browser for review
    abbr prv --function __abbr_prv  # View current PR/MR in browser

# Tags
    abbr tl --command git 'snip run -- git tag --sort=-v:refname -n -l'
    abbr ts --command git 'git tag -s'
    abbr tv --command git 'git tag | sort -V'

# Code Review (usar después de rebase)
    abbr review --command git --function __abbr_review --set-cursor=!  # g review 3 → reset --soft HEAD~3
    abbr review-end --command git 'reset ORIG_HEAD'  # deshace review

# Stash
    abbr stasha --command git 'stash --include-untracked' # Moves WD and SA to the vault.
    abbr stashs --command git 'stash show --text'

# Others
    abbr i --command git init  # Initializes a new Git repository in the current directory.
    abbr cl --command git clone  # Clones a repository into a new directory.
    abbr cp --command git cherry-pick  # Cherry pick an specific commit and apply it above HEAD.
    abbr re --command git reset  # [Default] Resets HEAD (--soft, --mixed, --hard)
    abbr rs --command git restore  # [Default] Swift knive -> Restore a file to an older state, restore WD, restore SA, ...

    abbr arb --command git 'rebase --abort'  # Aborts current rebase.
    abbr amg --command git 'merge --abort'  # Aborts current merge.
    
    abbr aliases --command git "config --get-regexp '^alias\.'"  # lista todos los alias de git
    abbr mzt --command git machete  # Git machete: Multipurpose command
    abbr usmod --command git 'submodule update'
    abbr unignore --command git 'update-index --no-assume-unchanged'

# WIP — replaced by git-wip (refs/wip/* with history, auto-save, undo)
    # abbr wip --command git 'add -A; git rm (git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
    # abbr unwip --command git 'log -n 1 | grep -q -c "--wip--" && git reset HEAD~1 || echo "No WIP commit found."'

# Functions
function _git_abbrv_list
    set -l file ~/.config/fish/conf.d/qol-git.fish
    set -l skip_re 'Git abbreviations|Checkout deshabilitado|Cumulative|Fancy log|Code Review|Functions|Birth'
    set -l show 0
    while read -l line
        if string match -rq '^\s*#\s+\w' -- $line
            set -l trimmed (string trim -c '# ' -- (string trim -- $line))
            set -l word_count (count (string split " " -- $trimmed))
            if string match -rq -- $skip_re -- $trimmed
                set show 0
            else if test "$word_count" -le 4
                set show 1
                echo ""
                set_color brblue
                echo "  ── $trimmed ──"
                set_color normal
            end
            continue
        end
        if test "$show" -eq 0; continue; end
        if not string match -rq '^\s*abbr ' -- $line; continue; end
        set -l trim (string trim -- $line)
        set -l name (string match -r 'abbr (\S+)' -- $trim)
        if not set -q name[2]; continue; end
        set -l comment (string match -r '# (.+)' -- $trim)
        if set -q comment[2]
            printf "  %-12s %s\n" $name[2] "$comment[2]"
        else
            printf "  %-12s %s\n" $name[2] ""
        end
    end <$file
    echo ""
end

function __abbr_review; echo 'reset --soft HEAD~!'; end
function __abbr_discard; echo 'restore !'; end
function __abbr_rollback
    set -g __ctx_rollback
    echo "revert --no-edit"
end
function __abbr_polish; echo 'rebase -i HEAD~!'; end
function __abbr_local_polish
    set -l branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    or begin; echo "error: not a git repo" >&2; return 1; end
    echo "rebase -i origin/$branch"
end

function __abbr_ulc
    set -l branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    or begin; echo "error: not a git repo" >&2; return 1; end
    echo "reset --soft origin/$branch"
end

function __clear_ctx --on-event fish_prompt
    set -e __ctx_diff __ctx_show __ctx_dbr __ctx_swbr __ctx_mg __ctx_ffmg __ctx_smg __ctx_rb __ctx_rollback 2>/dev/null
end

function __abbr_sh
    set -g __ctx_show
    echo "show -w HEAD"
end

function __abbr_diff
    set -g __ctx_diff
    echo "diff -w"
end

function __abbr_staged
    if set -q __ctx_diff
        set -e __ctx_diff
        echo "--staged -w"
    end
end

function __abbr_s
    if set -q __ctx_diff
        echo "--staged"
    end
end

function __abbr_dbr
    set -g __ctx_dbr
    echo "branch -d"
end

function __abbr_swbr
    set -g __ctx_swbr
    echo "switch"
end

function __abbr_mg
    set -g __ctx_mg
    echo "merge"
end

function __abbr_ffmg
    set -g __ctx_ffmg
    echo "merge --ff-only"
end

function __abbr_smg
    set -g __ctx_smg
    echo "merge --squash"
end

function __abbr_rb
    set -g __ctx_rb
    echo "rebase"
end

function __abbr_sync
    set -g __ctx_rb
    echo sync
end

function __abbr_isync
    set -g __ctx_rb
    echo isync
end

function __abbr_lsbr
    set -l ptr \uf126
    set -l branch (git branch --format='%(refname:short)' --sort=-committerdate 2>/dev/null \
        | fzf --prompt=" Branch: " \
              --pointer=$ptr \
              --header="Recent branches first" \
              --preview="git --no-pager diff --stat --color=always HEAD..{1}; echo; git --no-pager log --oneline --color=always {1} -5")
    if test -n "$branch"
        echo $branch
    end
end

function __fish_ctx_fzf
    set -l ptr \uf126
    set -l diff_stat "git --no-pager diff --stat --color=always HEAD..{1}; echo; git --no-pager log --oneline --graph --color=always {1} -5"
    set -l show_commit "git --no-pager show --color=always {1} | delta --paging=never --features="

    if set -q __ctx_dbr
        set -e __ctx_dbr
        set -l branch (git branch --merged 2>/dev/null \
            | awk '{print $1}' \
            | grep -v -E '^(main|master|develop|deploy|\*)$' \
            | fzf --multi \
                  --prompt=" Delete: " \
                  --pointer=$ptr \
                  --header="Delete merged branches (TAB for multi)" \
                  --preview="git --no-pager log --oneline --color=always {1} -10")
        if test -n "$branch"
            set -l joined (string join ' ' $branch)
            commandline -i -- "branch -d $joined"
        end
    else if set -q __ctx_swbr
        set -e __ctx_swbr
        set -l branch (git branch --format='%(refname:short)' 2>/dev/null \
            | fzf --prompt=" Switch: " \
                  --pointer=$ptr \
                  --header="Switch to branch" \
                  --preview="$diff_stat")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_mg
        set -e __ctx_mg
        set -l branch (git branch --all --format='%(refname:short)' 2>/dev/null \
            | grep -v 'origin/HEAD' \
            | fzf --prompt=" Merge: " \
                  --pointer=$ptr \
                  --header="Merge branch into current" \
                  --preview="$diff_stat")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_ffmg
        set -e __ctx_ffmg
        set -l branch (git branch --all --format='%(refname:short)' 2>/dev/null \
            | grep -v 'origin/HEAD' \
            | fzf --prompt=" FF Merge: " \
                  --pointer=$ptr \
                  --header="Fast-forward merge" \
                  --preview="$diff_stat")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_smg
        set -e __ctx_smg
        set -l branch (git branch --all --format='%(refname:short)' 2>/dev/null \
            | grep -v 'origin/HEAD' \
            | fzf --prompt=" Squash: " \
                  --pointer=$ptr \
                  --header="Squash merge branch" \
                  --preview="$diff_stat")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_rb
        set -e __ctx_rb
        set -l branch (git branch --all --format='%(refname:short)' 2>/dev/null \
            | grep -v 'origin/HEAD' \
            | fzf --prompt=" Rebase: " \
                  --pointer=$ptr \
                  --header="Rebase onto branch" \
                  --preview="$diff_stat")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_rollback
        set -e __ctx_rollback
        set -l commit (git log --oneline -50 2>/dev/null \
            | fzf --prompt=" Commit: " \
                  --pointer=$ptr \
                  --header="Revert commit" \
                  --preview="$show_commit")
        if test -n "$commit"
            commandline -i -- (echo $commit | awk '{print $1}')
        end
    else
        commandline -i -- 'º'
        commandline -f repaint
        return
    end
    commandline -f repaint
end

bind º __fish_ctx_fzf
bind -M insert º __fish_ctx_fzf

function __abbr_pr
    if not command -v gh >/dev/null; and not command -v glab >/dev/null
        echo "echo 'Error: gh (GitHub CLI) or glab (GitLab CLI) required'"
        return
    end

    set -l url (git config --get remote.origin.url 2>/dev/null)
    if string match -rq 'github.com' -- $url
        echo "gh pr create --fill"
    else if string match -rq 'gitlab.com' -- $url
        echo "glab mr create --fill -y"
    else
        echo "echo 'Error: No compatible remote found (GitHub or GitLab)'"
    end
end

function __abbr_prw
    if not command -v gh >/dev/null; and not command -v glab >/dev/null
        echo "echo 'Error: gh (GitHub CLI) or glab (GitLab CLI) required'"
        return
    end

    set -l url (git config --get remote.origin.url 2>/dev/null)
    if string match -rq 'github.com' -- $url
        echo "gh pr create --fill --web"
    else if string match -rq 'gitlab.com' -- $url
        echo "glab mr create --fill --web -y"
    else
        echo "echo 'Error: No compatible remote found (GitHub or GitLab)'"
    end
end

function __abbr_prv
    if not command -v gh >/dev/null; and not command -v glab >/dev/null
        echo "echo 'Error: gh (GitHub CLI) or glab (GitLab CLI) required'"
        return
    end

    set -l url (git config --get remote.origin.url 2>/dev/null)
    if string match -rq 'github.com' -- $url
        echo "gh pr view --web"
    else if string match -rq 'gitlab.com' -- $url
        echo "glab mr view --web"
    else
        echo "echo 'Error: No compatible remote found (GitHub or GitLab)'"
    end
end

function abbrv  # lista abbrv definidos en qol-git.fish
    string match -r '^\s*abbr\s+\w+' <~/.config/fish/conf.d/qol-git.fish | string trim | sort
end