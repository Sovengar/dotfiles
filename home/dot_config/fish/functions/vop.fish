function vop --description 'OpenCode + Neovim'
    #nvim -c 'lua Snacks.explorer()' -c 'wincmd l' -c 'terminal opencode' -c 'startinsert'

    set -l session_file /tmp/vop3-kitty-session.conf
    set -l cwd (string escape -- "$PWD")
    set -l terminal $TERMINAL

    switch (basename "$terminal")
        case wezterm
            command "$terminal" start --cwd "$PWD" -- bash -lc 'wezterm cli split-pane --right --cwd "$PWD" -- opencode >/dev/null; exec nvim .'
        case kitty
            printf 'layout tall\nlaunch --cwd=%s nvim .\nlaunch --cwd=%s opencode\n' $cwd $cwd >$session_file
            command "$terminal" --detach --session "$session_file" >/tmp/vop3-kitty.log 2>&1
        case '*'
            command "$terminal" -e nvim .
    end
end
