function rgf --description "rg + fzf + bat preview + nvim jump"
    rg --line-number --no-heading --color=always $argv \
        | fzf --ansi \
            --delimiter ':' \
            --preview 'set line {2}; set start (math "max(1, $line - 20)"); bat --style=numbers --color=always --line-range $start: --highlight-line $line {1}' \
            --preview-window='right:70%:wrap' \
            --phony \
            --bind 'enter:execute(nvim +{2} {1} < /dev/tty)' \
            --multi
end
