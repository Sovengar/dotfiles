function vop {
  local session_file=/tmp/vop3-kitty-session.conf
  local cwd=${(q)PWD}

  printf 'layout tall\nlaunch --cwd=%s nvim .\nlaunch --cwd=%s opencode\n' "$cwd" "$cwd" >| "$session_file"
  kitty --detach --session "$session_file" >/tmp/vop3-kitty.log 2>&1
}

function connect {
  case "$1" in
    jon)
      wezterm connect jon
      ;;
    *)
      echo "Unknown target: $1"
      return 1
      ;;
  esac
}

function rgf {
  rg --line-number --no-heading --color=always "$@" \
    | fzf --ansi \
      --delimiter ':' \
      --preview 'line={2}; start=$((line > 20 ? line - 20 : 1)); bat --style=numbers --color=always --line-range "$start:" --highlight-line "$line" {1}' \
      --preview-window='right:70%:wrap' \
      --phony \
      --bind 'enter:execute(nvim +{2} {1} < /dev/tty)' \
      --multi
}
