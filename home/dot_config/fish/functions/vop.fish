function vop --description 'OpenCode + Neovim'
    #nvim -c 'lua Snacks.explorer()' -c 'wincmd l' -c 'terminal opencode' -c 'startinsert'

    set -l session_file /tmp/vop3-kitty-session.conf
    set -l cwd (string escape -- "$PWD")

    printf 'layout tall\nlaunch --cwd=%s nvim .\nlaunch --cwd=%s opencode\n' $cwd $cwd >$session_file
    kitty --detach --session "$session_file" >/tmp/vop3-kitty.log 2>&1
end
