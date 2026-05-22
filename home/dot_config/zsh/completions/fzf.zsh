# Ctrl-R fzf completion/keybindings. Requires ZLE, so skip zsh -i -c shells.
if [[ $- == *i* && -o zle && -t 0 ]] && command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi
