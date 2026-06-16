#!/usr/bin/env zsh

# Quality-of-life aliases. All alias definitions belong here, organized by section.

# General
alias cl='clear'
alias dkps='docker ps'

# Docker: build (with snip)
function dkbuild {
    snip run -- docker build "$@"
}

# Docker: exec into container (fzf picker)
function dkexe {
    docker exec -it $(docker ps --format '{{.Names}}' | fzf) sh "$@"
}

# Docker: tail logs of container (fzf picker)
function dklogs {
    docker logs -f $(docker ps --format '{{.Names}}' | fzf) "$@"
}

# Docker: run container from image (fzf picker)
function dkrun {
    docker run -d $(docker images --format '{{.Repository}}:{{.Tag}}' | fzf) "$@"
}

# Git
alias g='git'
alias gco='git checkout'
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gb='git branch'
alias gd='git diff'
alias gl='git log'
alias gp='git push'

alias gstall='git stash --all'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'

alias gsw='git switch'
alias gswc='git switch -c'
alias gswd='git switch ${git_develop_branch:-develop}'
alias gswm='git switch ${git_main_branch:-main}'

alias gup='git pull --rebase'
alias gupa='git pull --rebase --autostash'
alias gupav='git pull --rebase --autostash -v'
alias gupom='git pull --rebase origin ${git_main_branch:-main}'
alias gupomi='git pull --rebase=interactive origin ${git_main_branch:-main}'
alias gupv='git pull --rebase -v'

alias gtl='gtl(){ git tag --sort=-v:refname -n -l "${1}*" }; noglob gtl'
alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gunignore='git update-index --no-assume-unchanged'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1 || echo "No WIP commit found."'
alias gsu='git submodule update'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
function gwch {
    snip run -- git whatchanged -p --abbrev-commit --pretty=medium "$@"
}

# Kubernetes
alias k='kubectl'

alias kgpa='kubectl get pods --all-namespaces'
alias kgpall='kubectl get pods --all-namespaces -o wide'

alias kgpo='kubectl get pod'

alias kgpvc='kubectl get pvc'
alias kgpvca='kubectl get pvc --all-namespaces'

alias kgrs='kubectl get replicaset'
alias kgs='kubectl get svc'
alias kgsa='kubectl get svc --all-namespaces'

alias kgsec='kubectl get secret'
alias kgseca='kubectl get secret --all-namespaces'

alias kgss='kubectl get statefulset'
alias kgssa='kubectl get statefulset --all-namespaces'

alias kl='kubectl logs'
alias kl1h='kubectl logs --since=1h'
alias kl1m='kubectl logs --since=1m'
alias kl1s='kubectl logs --since=1s'
alias klf='kubectl logs -f'
alias klf1h='kubectl logs -f --since=1h'
alias klf1m='kubectl logs -f --since=1m'
alias klf1s='kubectl logs -f --since=1s'

alias kpf='kubectl port-forward'
alias krh='kubectl rollout history'
alias krsd='kubectl rollout status deployment'
alias krss='kubectl rollout status statefulset'
alias kru='kubectl rollout undo'
alias ksd='kubectl scale deployment'
alias ksss='kubectl scale statefulset'

# Tools
alias op='opencode'
alias gh-dash='gh dash'
alias lgit='lazygit'
alias ldk='lazydocker'
alias lzn='lazynpm'
alias http='xh'

# Navigation
alias ..='cd ..'
alias ...='cd /home/buble'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'
alias ..6='cd ../../../../../..'
alias ..7='cd ../../../../../../..'
alias ..8='cd ../../../../../../../..'

# Files / listing
if command -v eza >/dev/null 2>&1; then
    alias l='eza -lh --icons=auto'
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lla='eza -la --icons --group-directories-first'
    alias lah='eza -lah --icons --group-directories-first'
    alias ld='eza -lhD --icons=auto'
    alias lt='eza -aT --color=always --group-directories-first --icons'
fi

# Bat overrides
if command -v bat >/dev/null 2>&1; then
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain --paging=never --color always'
    alias cat='bat --style=plain --paging=never --color auto'
fi

# CachyOS / Arch
alias grubup='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias fixpacman='sudo rm /var/lib/pacman/db.lck'
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
alias mirror='sudo cachyos-rate-mirrors'

alias big="expac -H M '%m\t%n' | sort -h | nl"
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

alias hw='hwinfo --short'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias jctl='journalctl -p 3 -xb'

alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias tb='nc termbin.com 9999'

alias please='sudo'
alias apt='man pacman'
alias apt-get='man pacman'

# Hyde
alias in='hyde-shell pm install'
alias un='hyde-shell pm remove'
alias up='hyde-shell pm upgrade'
alias pl='hyde-shell pm search installed'
alias pa='hyde-shell pm search all'

# Fzf
alias ffec='_fuzzy_edit_search_file_content'
alias ffcd='_fuzzy_change_directory'
alias ffe='_fuzzy_edit_search_file'
alias ffch='_fuzzy_search_cmd_history'

# Overrides (conditional aliases)
if command -v fastfetch >/dev/null 2>&1; then
  alias fastfetch='fastfetch --logo-type kitty'
fi





# Abbreviations
alias mkdir='mkdir -p'
alias vi='nvim'
