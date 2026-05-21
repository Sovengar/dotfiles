#!/usr/bin/env fish

# CachyOS / Arch Linux specific aliases.

# System maintenance
alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias mirror="sudo cachyos-rate-mirrors"

# Package info
alias big="expac -H M '%m\t%n' | sort -h | nl"
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# System info
alias hw='hwinfo --short'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias jctl="journalctl -p 3 -xb"

# File utilities
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias tb='nc termbin.com 9999'

# Shortcuts
alias please='sudo'
alias apt='man pacman'
alias apt-get='man pacman'
