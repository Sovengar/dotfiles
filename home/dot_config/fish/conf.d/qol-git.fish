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
        end
    end
    command git $argv
end


# Cumulative abbreviations: expand subcommand only after "git"
abbr g git  # "g" → "git", abrevia todos los comandos

# Birth
    abbr i --command git init  # crea nuevo repo git
    abbr cl --command git clone  # clona repo remoto

# Diff
    # Here we delete +/- since we use diff-so-fancy
    abbr diff --command git --function __abbr_diff  # "diff" expande después de "git" y activa contexto para "staged"
    abbr d --command git --function __abbr_diff  # "d" es alias de "diff -w"
        abbr staged --command git --function __abbr_staged  # "staged" solo expande después de "diff"
        abbr s --command git --function __abbr_s  # "s" → --staged, solo después de "diff"

    abbr releasediff --command git 'hist --first-parent latest..HEAD'  # diff desde latest hasta HEAD (mismo formato que hist)

# Fetch & Merge
    abbr pl --command git pull  # fetch + merge (trae cambios remotos)
    abbr me --command git merge  # fusiona rama en la actual
    abbr fe --command git 'fetch --prune --all'  # fetch + poda ramas remotas eliminadas
    abbr rb --command git rebase  # reescribe historial, reaplica commits sobre otra base

    abbr mofo --command git 'merge origin/master --ff-only'  # merge rapido con origin/master, falla si no es fast-forward

    abbr u --command git 'pull --rebase --autostash'  # pull con rebase + autostash
    abbr update --command git 'pull --rebase --autostash'  # pull con rebase + autostash

# Push
    abbr p --command git push  # sube commits al remoto
    abbr pu --command git push  # sube commits al remoto
    
    abbr puf --command git 'push --force-with-lease --force-if-includes'  # force push seguro, usar después de amend/rebase/squash
    #Not needed with auto-setup-remote
    #abbr pushup --command git --function __abbr_pushup  # push + upstream en ramas nuevas

# Branching
    abbr sw --command git switch  # cambia de rama
    abbr create --command git 'switch -c'  # crear rama nueva y cambiarse

# Working directory, Staging
    abbr a --command git 'add'  # stage one change (new, modified, deleted)
    abbr aa --command git 'add -A'  # stage all changes (new, modified, deleted)
    abbr ai --command git 'add --patch'  # stage changes interactively (new, modified, deleted)

    abbr rs --command git restore  # restaura archivos del working tree
    abbr re --command git reset  # resetea HEAD (--soft, --mixed, --hard)
    abbr undo --command git 'revert --no-edit HEAD'  # deshace el ultimo commit (seguro, crea commit inverso)
    abbr rollback --command git --function __abbr_rollback --set-cursor=!  # g rollback <commit> (revierte commit especifico)
    
    abbr nuke --command git 'reset --hard HEAD'  # descarta todos los cambios locales, vuelve al último commit
    abbr unstage --command git 'restore --staged'  # deshace stage de archivos
    abbr discard --command git --function __abbr_discard --set-cursor=!  # g discard . (o g discard file.txt)

# Commit
    abbr c --command git 'commit -m ""'  # commit con mensaje
    abbr co --command git 'commit -m ""'  # commit con mensaje
    abbr cp --command git cherry-pick  # aplica commits específicos sobre HEAD

# Compaction
    abbr amend --command git 'commit -a --amend --no-edit'  # agrega cambios al último commit sin editar mensaje
    abbr abort --command git 'rebase --abort'  # aborta rebase en curso
    abbr fuse --command git --function __abbr_fuse --set-cursor=!  # Fusiona(Pick, Squash, Delete) los ultimos ! commits.

# State
    abbr br --command git branch -a  # lista ramas (locales + remotas)
    abbr st --command git status --short  # status corto (porcelain)
    abbr sta --command git status  # status completo
    abbr ls --command git ls-files  # lista archivos trackeados por git
    
    # Fancy log: git hist → ~/.local/bin/git-hist (parents solo en merge commits)
    abbr mergeds --command git 'branch --merged'  # lista ramas ya fusionadas (limpieza)
    abbr sh --command git --function __abbr_sh  # "sh" → "show -w HEAD", activa contexto

# Others
    abbr aliases --command git "config --get-regexp '^alias\.'"  # lista todos los alias de git



# Code Review (usar después de rebase)
abbr review --command git --function __abbr_review --set-cursor=!  # g review 3 → reset --soft HEAD~3
abbr uncommit --command git --function __abbr_review --set-cursor=!  # g uncommit 3 → reset --soft HEAD~3
abbr review-end --command git 'reset ORIG_HEAD'  # deshace review





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

alias gsw='git switch'  # cambia de rama
alias gswc='git switch -c'  # crea y cambia a nueva rama
alias gswd='git switch - develop'  # cambia a develop
alias gswm='git switch - main'  # cambia a main

alias gup='git pull --rebase'  # pull con rebase
alias gupa='git pull --rebase --autostash'  # pull rebase + autostash
alias gupav='git pull --rebase --autostash -v'  # igual, verbose
alias gupom='git pull --rebase origin main'  # pull rebase desde origin/main
alias gupomi='git pull --rebase=interactive origin main'  # pull rebase interactivo desde origin/main
alias gupv='git pull --rebase -v'  # pull rebase verbose

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

function abbrv  # lista abbrv definidos en qol-git.fish
    string match -r '^\s*abbr\s+\w+' <~/.config/fish/conf.d/qol-git.fish | string trim | sort
end

# Functions
function _git_abbrv_list
    set -l file ~/.config/fish/conf.d/qol-git.fish
    set -l sections 'Birth|Diff|Fetch & Merge|Push|Branching|Working directory|Staging|Commit|Compaction|State|Others|Code Review'
    set -l skip_sections 'Git|Checkout|Cumulative|Fancy|Functions|Here|Birth'
    set -l show 0
    while read -l line
        if string match -rq '^\s*#\s+\w+' -- $line
            set -l trimmed (string trim -c '# ' -- (string trim -- $line))
            if string match -rq -- $sections -- $trimmed; and not string match -rq -- $skip_sections -- $trimmed
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
            printf "  %-12s\n" $name[2]
        end
    end <$file
    echo ""
end
function __abbr_fuse; echo 'rebase -i HEAD~!'; end
function __abbr_review; echo 'reset --soft HEAD~!'; end
function __abbr_discard; echo 'restore !'; end
function __abbr_rollback; echo 'revert --no-edit !'; end
function __clear_ctx --on-event fish_prompt
    set -e __ctx_diff __ctx_show 2>/dev/null
end
function __abbr_sh
    set -g __ctx_show
    echo "show -w HEAD"
end
function __abbr_diff
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
function __abbr_pushup
    set -l branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    test -n "$branch"; and echo "push --set-upstream origin $branch"
end
