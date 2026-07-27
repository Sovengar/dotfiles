#!/usr/bin/env fish

# Quality-of-life aliases and abbreviations.
# All alias and abbr definitions belong here, organized by section.

# General
alias cl='clear'


# Tools
abbr op opencode
alias gh-dash='gh dash'
abbr lgit lazygit
abbr ldk lazydocker
abbr lzn lazynpm
abbr http xh
function dkbuild
    snip run -- docker build $argv
end
alias dkps='docker ps'

# Docker: run container from image (fzf picker)
function dkrun
    docker run -d (docker images --format '{{.Repository}}:{{.Tag}}' | fzf) $argv
end

# Docker: exec into container (fzf picker)
function dkexe
    docker exec -it (docker ps --format '{{.Names}}' | fzf) sh $argv
end

# Docker: tail logs of container (fzf picker)
function dklogs
    docker logs -f (docker ps --format '{{.Names}}' | fzf) $argv
end

# Navigation & Listing
alias ..='cd ..'
alias ...='cd /home/buble'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'
alias ..6='cd ../../../../../..'
alias ..7='cd ../../../../../../..'
alias ..8='cd ../../../../../../../..'

if type -q eza
    alias l='eza -lh --icons=auto'
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lla='eza -la --icons --group-directories-first'
    alias lah='eza -lah --icons --group-directories-first'
    alias ld='eza -lhD --icons=auto'
    alias lt='eza -aT --color=always --group-directories-first --icons'
end

# CachyOS / Arch
alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias mirror="sudo cachyos-rate-mirrors"

alias big="expac -H M '%m\t%n' | sort -h | nl"
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

function hw
    snip run -- hwinfo --short $argv
end
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
function jctl
    snip run -- journalctl -p 3 -xb $argv
end

alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias tb='nc termbin.com 9999'

alias please='sudo'
alias apt='man pacman'
alias apt-get='man pacman'

# Overrides (conditional aliases)
if type -q fastfetch
    alias fastfetch='fastfetch --logo-type kitty'
end

set -l os_id
if test -r /etc/os-release
    set os_id (string match -r '^ID=.*' </etc/os-release | string replace -r '^ID="?([^"]*)"?$' '$1')
end
if test "$os_id" = cachyos
    alias wget='wget -c '
end

if type -q bat
    alias cat='bat --style=plain --paging=never --color auto'
end

if type -q sd
    alias sed='sd'
end

# Abbreviations
abbr reload 'source ~/.config/fish/config.fish'
abbr mkdir 'mkdir -p'
abbr vi nvim

# Kubernetes
abbr k kubectl

function kgpa
    snip run -- kubectl get pods --all-namespaces $argv
end
function kgpall
    snip run -- kubectl get pods --all-namespaces -o wide $argv
end
function kgpo
    snip run -- kubectl get pod $argv
end
function kgpvc
    snip run -- kubectl get pvc $argv
end
function kgpvca
    snip run -- kubectl get pvc --all-namespaces $argv
end
function kgrs
    snip run -- kubectl get replicaset $argv
end
function kgs
    snip run -- kubectl get svc $argv
end
function kgsa
    snip run -- kubectl get svc --all-namespaces $argv
end
function kgsec
    snip run -- kubectl get secret $argv
end
function kgseca
    snip run -- kubectl get secret --all-namespaces $argv
end
function kgss
    snip run -- kubectl get statefulset $argv
end
function kgssa
    snip run -- kubectl get statefulset --all-namespaces $argv
end

function kl
    snip run -- kubectl logs $argv
end
function kl1h
    snip run -- kubectl logs --since=1h $argv
end
function kl1m
    snip run -- kubectl logs --since=1m $argv
end
function kl1s
    snip run -- kubectl logs --since=1s $argv
end

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

# Hyde
alias in='hyde-shell pm install'
alias un='hyde-shell pm remove'
alias up='hyde-shell pm upgrade'
alias pl='hyde-shell pm search installed'
alias pa='hyde-shell pm search all'