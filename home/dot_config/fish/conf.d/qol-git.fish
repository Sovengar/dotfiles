#!/usr/bin/env fish

# Git abbreviations, aliases, and functions.
# Checkout deshabilitado — usar git switch (ramas) o git restore (archivos)
function git --wraps git
    if set -q argv[1]
        switch $argv[1]
            case checkout
                echo "Use git switch (branches) or git restore (files) instead of checkout" >&2
                return 1
            case commands
                _git_abbrv_list
                return
            case br-nuke
                br-nuke
                return
        end
    end
    command git $argv
end

#######################################
function gst  # gst → git status (con snip para paginación)
    snip run -- git status $argv
end

function gd  # gd → git diff (con snip)
    snip run -- git diff $argv
end

alias gstall='git stash --all'  # stash de todo (incluye no trackeados)
alias gstc='git stash clear'  # borra todos los stashes
alias gstd='git stash drop'  # elimina el último stash
alias gstl='git stash list'  # lista stashes guardados
alias gstp='git stash pop'  # restaura y elimina el último stash
function gsts  # gsts → git stash show (con snip)
    snip run -- git stash show --text $argv
end

alias gupom='git pull --rebase origin main'  # pull rebase desde origin/main
alias gupomi='git pull --rebase=interactive origin main'  # pull rebase interactivo desde origin/main

function gtl  # gtl → git tag list (filtrado por patrón, con snip)
    snip run -- git tag --sort=-v:refname -n -l "$argv[1]*"
end
alias gts='git tag -s'  # crea tag firmado
alias gtv='git tag | sort -V'  # lista tags ordenados por versión
alias gunignore='git update-index --no-assume-unchanged'  # reactiva tracking de archivos
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1 || echo "No WIP commit found."'  # deshace el último wip commit
alias gsu='git submodule update'  # actualiza submódulos
function gwch  # gwch → git whatchanged (qué cambió entre commits, con snip)
    snip run -- git whatchanged -p --abbrev-commit --pretty=medium $argv
end
alias gwip='git add -A; git rm (git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'  # commit temporal de trabajo en progreso
#######################################



# Cumulative abbreviations: expand subcommand only after "git"
abbr g git  # "g" → "git", abrevia todos los comandos

# Birth
    abbr i --command git init  # Initializes a new Git repository in the current directory.
    abbr cl --command git clone  # Clones a repository into a new directory.

# Diff
    abbr diff --command git --function __abbr_diff  # Diff without whitespace changes.
    abbr d --command git --function __abbr_diff  # Diff without whitespace changes.
        abbr staged --command git --function __abbr_staged  # Adds --staged (Only expands after "diff" or "d")
        abbr s --command git --function __abbr_s  # Adds --staged (Only expands after "diff" or "d")

    abbr releasediff --command git 'h --first-parent latest..HEAD'  # Diff between latest and HEAD (same format as h)

# Pull
    # No pull abbr to enforce usage of "u" (pull --rebase --autostash) or "sync" (rebase onto selected branch)    
    abbr fe --command git 'fetch --prune --all'  # Fetch + Delete remote branches that have been deleted in any remote.
    abbr rb --command git --function __abbr_rb  # [Default] rebase. Use º for fzf branch selector.

# Update working branch (feat/login) with latest remote changes
    abbr u --command git 'pull --rebase --autostash'  # Updates your branch putting newer remote commits on top, then append your LOCAL commits.

# Foreign branch -> Current branch
    # Merge 2 random branches 
    abbr mg --command git --function __abbr_mg  # Merge commits from another branch onto your current branch. Use º for fzf branch selector.
    abbr ffmg --command git --function __abbr_ffmg  # Fast-forward only merge, use º for fzf branch selector.
    abbr smg --command git --function __abbr_smg  # Squash merge, use º for fzf branch selector.

# Sync working branch fetching foreign branch (main, develop, deploy, ...)
    abbr sync --command git --function __abbr_sync  # [Safe] rebase your current branch with selected branch. Use º for fzf branch selector.
    abbr isync --command git --function __abbr_isync  # Interactive rebase against selected branch (º = fzf branch selector).

# Push
    abbr p --command git push  # Push commits to remote branch (default: origin current-branch)
    abbr fp --command git 'push --force-with-lease --force-if-includes'  # Force push with security (doesn't override if are new remote commits), use by default after a secured ammend/rebase.

# Branching
    abbr swbr --command git --function __abbr_swbr  # Switch to Branch, use º for fzf.
    abbr cbr --command git 'switch -c'  # Create and switch to a new branch.
    abbr dbr --command git --function __abbr_dbr  # Branch deleter, use º for fzf.

# Working directory, Staging
    abbr a --command git 'add'  # Add one change to stage area (new, modified, deleted)
    abbr aa --command git 'add -A'  # Add all changes to stage area (new, modified, deleted)
    abbr ia --command git 'add --patch'  # Add changes interactively to stage area (new, modified, deleted)

    abbr rs --command git restore  # [Default] Restore *** from working directory 
    abbr re --command git reset  # [Default] Resets HEAD (--soft, --mixed, --hard)
    
    abbr undo --command git 'revert --no-edit HEAD'  # Undo last commit by creating an inverse commit. [Safe]
    abbr rollback --command git --function __abbr_rollback  # Rollback <commit> by creating an inverse commit. Use º for fzf commit selector. [Safe]
    abbr uncommit --command git --function __abbr_review --set-cursor=!  # uncommit 3 → reset --soft HEAD~3    
    abbr clear --command git 'reset --hard HEAD'  # Descarta todos los cambios del working directory, vuelve al último local commit.
    abbr nuke --command git --set-cursor=! 'reset --hard HEAD~!'  # Descarta todos los cambios del working directory y de los ultimos ! commits, sean locales o remotos. Usar con commits locales o commits remotos que no hayan sido consumidos aun.
    abbr unstage --command git 'restore --staged'  # deshace stage de archivos
    abbr discard --command git --function __abbr_discard --set-cursor=!  # Descarta cambios en el archivo especificado, sean staged o unstaged.

# Commit
    abbr c --command git 'commit -m ""'  # commit con mensaje
    abbr co --command git 'commit -m ""'  # commit con mensaje
    abbr cp --command git cherry-pick  # aplica commits específicos sobre HEAD

# Compaction
    abbr amend --command git 'commit -a --amend --no-edit'  # Agrega cambios al último commit sin editar mensaje. Usar con commits locales o commits remotos que no hayan sido consumidos aun.
    abbr abort --command git 'rebase --abort'  # Aborta rebase en curso
    abbr polish --command git --function __abbr_polish --set-cursor=!  # Rebase -i de los ultimos ! commits. Usar con commits locales o commits remotos que no hayan sido consumidos aun. 
    abbr local-polish --command git --function __abbr_local_polish   # Rebase -i de tus commits locales.

# State
    abbr br --command git branch -a  # lista ramas (locales + remotas)
    abbr st --command git status --short  # status corto (porcelain)
    abbr sta --command git status  # status completo
    abbr ls --command git ls-files  # lista archivos trackeados por git
    
    # Fancy log: git h → ~/.local/bin/git-h (parents solo en merge commits)
    abbr mergeds --command git 'branch --merged'  # lista ramas ya fusionadas (limpieza)
    abbr sh --command git --function __abbr_sh  # "sh" → "show -w HEAD", activa contexto
    abbr archives --command git reflog  # muestra el registro de referencias (reflog)

# Code Review (usar después de rebase)
    abbr review --command git --function __abbr_review --set-cursor=!  # g review 3 → reset --soft HEAD~3
    abbr review-end --command git 'reset ORIG_HEAD'  # deshace review

# Pull Requests
    abbr pr --function __abbr_pr  # Create PR/MR with auto fill (detects GitHub/GitLab)
    abbr prw --function __abbr_prw  # Create PR/MR and open in browser for review
    abbr prv --function __abbr_prv  # View current PR/MR in browser

# Others
    abbr aliases --command git "config --get-regexp '^alias\.'"  # lista todos los alias de git

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

function __clear_ctx --on-event fish_prompt
    set -e __ctx_diff __ctx_show __ctx_dbr __ctx_swbr __ctx_mg __ctx_ffmg __ctx_smg __ctx_rb __ctx_rollback 2>/dev/null
end

function __abbr_sh
    set -g __ctx_show
    echo "show -w HEAD"
end

function __abbr_diff
    # Here we delete +/- since we use diff-so-fancy
    set -g __ctx_diff
    echo "diff -w --output-indicator-new=' ' --output-indicator-old=' '"
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

function br-nuke  # borra ramas locales merged, excluye main/master/develop (multi-select con fzf)
    git branch --merged | grep -v -E '^\s*\*|^\s*(main|master|develop|deploy)$' | fzf --multi | xargs -n 1 git branch -d
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
    echo "fetch --prune --all; and rebase"
end

function __abbr_isync
    set -g __ctx_rb
    echo "pull --rebase=interactive --autostash"
end

function __fish_brd_fzf
    if set -q __ctx_dbr
        set -e __ctx_dbr
        set -l branch (git branch --merged 2>/dev/null \
            | awk '{print $1}' \
            | grep -v -E '^(main|master|develop|deploy|\*)$' \
            | fzf --prompt="Branch: ")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_swbr
        set -e __ctx_swbr
        set -l branch (git branch --all --format='%(refname:short)' 2>/dev/null \
            | grep -v 'origin/HEAD' \
            | fzf --prompt="Switch to: ")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_mg
        set -e __ctx_mg
        set -l branch (git branch --all --format='%(refname:short)' 2>/dev/null \
            | grep -v 'origin/HEAD' \
            | fzf --prompt="Merge: ")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_ffmg
        set -e __ctx_ffmg
        set -l branch (git branch --all --format='%(refname:short)' 2>/dev/null \
            | grep -v 'origin/HEAD' \
            | fzf --prompt="Merge --ff-only: ")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_smg
        set -e __ctx_smg
        set -l branch (git branch --all --format='%(refname:short)' 2>/dev/null \
            | grep -v 'origin/HEAD' \
            | fzf --prompt="Squash merge: ")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_rb
        set -e __ctx_rb
        set -l branch (git branch --all --format='%(refname:short)' 2>/dev/null \
            | grep -v 'origin/HEAD' \
            | fzf --prompt="Rebase onto: ")
        if test -n "$branch"
            commandline -i -- $branch
        end
    else if set -q __ctx_rollback
        set -e __ctx_rollback
        set -l commit (git log --oneline -50 2>/dev/null \
            | fzf --prompt="Commit: ")
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

bind º __fish_brd_fzf
bind -M insert º __fish_brd_fzf

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