# fzf extra functions (sourced by fzf-config.sh)

# rg + fzf + bat preview + nvim jump
rgf() {
    rg --line-number --no-heading --color=always "$@" \
        | fzf --ansi \
            --delimiter ':' \
            --preview 'line={2}; start=$((line > 20 ? line - 20 : 1)); bat --style=numbers --color=always --line-range "$start:" --highlight-line "$line" {1}' \
            --preview-window='right:70%:wrap' \
            --phony \
            -q "$(echo "$1" | sed 's/ /\\ /g')" \
            --bind 'enter:execute(nvim +{2} {1} < /dev/tty)' \
            --multi
}

# Alt+F → append "| fzf" and execute
fzf-pipe() {
    if [[ -n "$BUFFER" ]]; then
        BUFFER="$BUFFER | fzf"
        zle accept-line
    fi
}
zle -N fzf-pipe
bindkey '^[f' fzf-pipe

