function vop {
  local session_file=/tmp/vop3-kitty-session.conf
  local cwd=${(q)PWD}
  local terminal=${TERMINAL}

  case "$(basename "$terminal")" in
    wezterm)
      command "$terminal" start --cwd "$PWD" -- bash -lc 'wezterm cli split-pane --right --cwd "$PWD" -- opencode >/dev/null; exec nvim .'
      ;;
    kitty)
      printf 'layout tall\nlaunch --cwd=%s nvim .\nlaunch --cwd=%s opencode\n' "$cwd" "$cwd" >| "$session_file"
      command "$terminal" --detach --session "$session_file" >/tmp/vop3-kitty.log 2>&1
      ;;
    *)
      command "$terminal" -e nvim .
      ;;
  esac
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

function __zsh_picker_in_cmdsubst {
  [[ ":$ZSH_EVAL_CONTEXT:" == *:cmdsubst:* ]]
}

function __zsh_picker_print_unique {
  local -a unique_files
  local -A seen_files
  local file

  for file in "$@"; do
    if [[ -n "$file" && -z "${seen_files[$file]}" ]]; then
      unique_files+=("$file")
      seen_files[$file]=1
    fi
  done

  print -rn -- "${(F)unique_files}"
}

function __rgx_preview_zsh {
  local pattern="$1"
  local file="$2"
  local line="$3"

  [[ -f "$file" ]] || return
  [[ "$line" =~ '^[0-9]+$' ]] || line=1

  local start=$(( line > 200 ? line - 200 : 1 ))
  local end=$(( line + 200 ))
  local header_color=$'\033[36m'
  local line_color=$'\033[90m'
  local exact_match_color=$'\033[1;30;43m'
  local folded_match_color=$'\033[1;30;106m'
  local reset_color=$'\033[0m'
  local current_file_line=0
  local content

  printf '%s%s:%s%s\n\n' "$header_color" "$file" "$line" "$reset_color"

  if command -v bat >/dev/null 2>&1; then
    bat --color=always --style=numbers --paging=never --line-range "$start:$end" --highlight-line "$line" --theme='RGX Muted' "$file" \
      | RGX_HIGHLIGHT="$pattern" \
          RGX_EXACT_COLOR="$exact_match_color" \
          RGX_FOLDED_COLOR="$folded_match_color" \
          RGX_RESET_COLOR="$reset_color" \
          perl -CS -pe '
            BEGIN {
              $h = $ENV{RGX_HIGHLIGHT};
              $exact = $ENV{RGX_EXACT_COLOR};
              $folded = $ENV{RGX_FOLDED_COLOR};
              $reset = $ENV{RGX_RESET_COLOR};
              $quoted = quotemeta($h);
            }
            s/($quoted)/($1 eq $h ? "$exact$1$reset" : "$folded$1$reset")/gie if $h ne "";
          '
    return
  fi

  while IFS= read -r content; do
    (( current_file_line++ ))

    (( current_file_line < start )) && continue
    (( current_file_line > end )) && break

    if [[ -n "$pattern" ]]; then
      content=$(RGX_HIGHLIGHT="$pattern" \
        RGX_EXACT_COLOR="$exact_match_color" \
        RGX_FOLDED_COLOR="$folded_match_color" \
        RGX_RESET_COLOR="$reset_color" \
        perl -CS -pe '
          BEGIN {
            $h = $ENV{RGX_HIGHLIGHT};
            $exact = $ENV{RGX_EXACT_COLOR};
            $folded = $ENV{RGX_FOLDED_COLOR};
            $reset = $ENV{RGX_RESET_COLOR};
            $quoted = quotemeta($h);
          }
          s/($quoted)/($1 eq $h ? "$exact$1$reset" : "$folded$1$reset")/gie if $h ne "";
        ' <<< "$content")
    fi

    printf '%s%6d%s  %s\n' "$line_color" "$current_file_line" "$reset_color" "$content"
  done < "$file"
}

function __rgx_search_zsh {
  local state_file="$1"
  local hidden=0 line key value arg row file match_line rest match_text name dir git_root git_root_name cache_key preview_start preview_scroll
  local -a rg_args
  local -A root_name_by_dir

  while IFS='=' read -r key value; do
    case "$key" in
      hidden) hidden="$value" ;;
    esac
  done < "$state_file"

  local hidden_label=OFF
  [[ "$hidden" == 1 ]] && hidden_label=ON
  printf 'Status --> Show Hidden Files:%s\t\t\n' "$hidden_label"

  rg_args=(--line-number --no-heading --color=never -i)
  [[ "$hidden" == 1 ]] && rg_args+=(--hidden)

  if [[ -n "$RGX_ARGS_FILE" && -f "$RGX_ARGS_FILE" ]]; then
    while IFS= read -r arg; do
      [[ -n "$arg" ]] || continue
      [[ "$arg" == --hidden || "$arg" == -H ]] && continue
      rg_args+=("$arg")
    done < "$RGX_ARGS_FILE"
  fi

  rg "${rg_args[@]}" | while IFS= read -r row; do
    IFS=':' read -r file match_line rest <<< "$row"

    if [[ -n "$file" && "$match_line" =~ '^[0-9]+$' ]]; then
      preview_start=$(( match_line > 200 ? match_line - 200 : 1 ))
      preview_scroll=$(( match_line - preview_start + 3 ))
      match_text="$rest"
      match_text="${match_text//$'\t'/ }"
      match_text="${match_text#${match_text%%[![:space:]]*}}"
      match_text="${match_text%${match_text##*[![:space:]]}}"
      (( ${#match_text} > 70 )) && match_text="${match_text[1,70]}"

      name="${file:t}"
      dir="${file:h}"
      git_root_name="${root_name_by_dir[$dir]}"

      if [[ ! -v root_name_by_dir[$dir] ]]; then
        git_root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)
        [[ -n "$git_root" ]] && git_root_name="${git_root:t}"
        root_name_by_dir[$dir]="$git_root_name"
      fi

      (( ${#name} > 35 )) && name="${name[1,33]}.."

      if [[ -n "$git_root_name" ]]; then
        printf '%s || %s:%s --> %s\t%s\t%s\t%s\n' "$git_root_name" "$name" "$match_line" "$match_text" "$file" "$match_line" "$preview_scroll"
      else
        printf '%s:%s --> %s\t%s\t%s\t%s\n' "$name" "$match_line" "$match_text" "$file" "$match_line" "$preview_scroll"
      fi
    fi
  done
}

function __rgx_toggle_hidden_zsh {
  local state_file="$1"
  local tmp_file="${state_file}.tmp"
  local key value

  while IFS='=' read -r key value; do
    case "$key" in
      hidden) printf 'hidden=%s\n' $(( 1 - value )) ;;
      *) printf '%s=%s\n' "$key" "$value" ;;
    esac
  done < "$state_file" >| "$tmp_file"

  mv -f "$tmp_file" "$state_file"
}

function rgx {
  for arg in "$@"; do
    case "$arg" in
      --help|-h)
        echo "Usage: rgx [OPTIONS] PATTERN"
        echo ""
        echo "rg + fzf + bat preview — fuzzy file content search with editor launch"
        echo ""
        echo "Options:"
        echo "  --hidden, -H    Include hidden files"
        echo "  --help, -h      Show this help"
        echo ""
        echo "Any other arguments are passed through to rg (ripgrep)."
        echo ""
        echo "Keybindings:"
        echo "  Enter        Open in editor at matching line"
        echo "  Ctrl-P       Paste selected paths"
        echo "  Ctrl-Y       Yank paths to clipboard"
        echo "  Ctrl-Space   Toggle preview"
        echo "  Tab          Select multiple rows"
        echo "  Alt-H        Toggle hidden files"
        echo "  ←/→          Scroll preview up/down"
        echo "  Ctrl-D/U     Scroll preview page"
        echo ""
        echo "Examples:"
        echo "  rgx foo"
        echo "  rgx --hidden foo"
        echo "  rgx -g '*.py' foo"
        echo "  rgx -t js foo"
        return 0
        ;;
    esac
  done

  local pattern=""
  local initial_hidden=0
  local arg

  for arg in "$@"; do
    case "$arg" in
      --help|-h)
        continue
        ;;
      --hidden|-H)
        initial_hidden=1
        continue
        ;;
    esac

    if [[ "$arg" != -* ]]; then
      pattern="$arg"
      break
    fi
  done

  local state_file args_file
  state_file=$(mktemp -t rgx-state.XXXXXX)
  args_file=$(mktemp -t rgx-args.XXXXXX)
  printf 'hidden=%s\n' "$initial_hidden" >| "$state_file"
  printf '%s\n' "$@" >| "$args_file"

  export RGX_PATTERN="$pattern"
  export RGX_ARGS_FILE="$args_file"

  local header=$'Enter: nvim/print path | Ctrl+P: Paste path | Ctrl+Y: Yank path  |\nCtrl+Space: Preview    | Tab: Select row   | Alt+H: Hidden      | ←/→: Preview scroll'
  local -a selection rows files nvim_args
  local key row display file match_line

  selection=("${(@f)$(__rgx_search_zsh "$state_file" \
    | fzf \
      --delimiter $'\t' \
      --with-nth=1 \
      --nth=1 \
      --expect=enter,ctrl-p,ctrl-y \
      --header="$header" \
      --header-lines=1 \
      --preview 'zsh -c '\''source "${ZDOTDIR:-$HOME/.config/zsh}/functions/user-tools.zsh"; __rgx_preview_zsh "$@"'\'' -- "$RGX_PATTERN" {2} {3}' \
      --preview-window='up:60%:wrap:+{4}-/2' \
      --bind 'right:preview-down,left:preview-up,ctrl-d:preview-page-down,ctrl-u:preview-page-up,ctrl-space:toggle-preview' \
      --bind "alt-h:reload(zsh -c 'source \"\${ZDOTDIR:-\$HOME/.config/zsh}/functions/user-tools.zsh\"; __rgx_toggle_hidden_zsh \"\$1\"; __rgx_search_zsh \"\$1\"' -- '$state_file')" \
      --multi)}")

  key="${selection[1]}"
  rows=("${selection[@]:1}")
  rm -f "$state_file" "$args_file"

  [[ ${#rows[@]} -gt 0 ]] || return

  for row in "${rows[@]}"; do
    IFS=$'\t' read -r display file match_line <<< "$row"

    if [[ -n "$file" && "$match_line" =~ '^[0-9]+$' ]]; then
      files+=("$file")
      nvim_args+=("+$match_line" "$file")
    fi
  done

  case "$key" in
    ctrl-p)
      __zsh_picker_print_unique "${files[@]}"
      ;;
    ctrl-y)
      __zsh_picker_print_unique "${files[@]}" | wl-copy
      ;;
    enter|'')
      if __zsh_picker_in_cmdsubst; then
        __zsh_picker_print_unique "${files[@]}"
        return
      fi

      nvim "${nvim_args[@]}"
      ;;
  esac
}

function __fdx_preview_zsh {
  local file="$1"
  local pattern="$FDX_PATTERN"
  local header_color=$'\033[36m'
  local match_color=$'\033[1;30;43m'
  local reset_color=$'\033[0m'

  if [[ ! -f "$file" ]]; then
    if [[ -d "$file" ]]; then
      eza --icons --group-directories-first "$file" 2>/dev/null || ls --color=auto "$file"
    fi

    return
  fi

  printf '%s%s%s\n\n' "$header_color" "$file" "$reset_color"

  if ! command -v bat >/dev/null 2>&1; then
    cat -- "$file"
    return
  fi

  if [[ -z "$pattern" ]]; then
    bat --color=always --style=numbers --paging=never "$file"
    return
  fi

  FDX_HIGHLIGHT="$pattern" FDX_MATCH_COLOR="$match_color" FDX_RESET_COLOR="$reset_color" \
    bat --color=always --style=numbers --paging=never "$file" \
      | perl -CS -pe '
          BEGIN {
            $h = $ENV{FDX_HIGHLIGHT};
            $match = $ENV{FDX_MATCH_COLOR};
            $reset = $ENV{FDX_RESET_COLOR};
            $quoted = quotemeta($h);
          }
          s/($quoted)/$match$1$reset/gie if $h ne "";
        '
}

function __fdx_search_zsh {
  local state_file="$1"
  local hidden=0 type_filter=f root_dir=. key value arg file name dir git_root git_root_name
  local -a fd_args
  local skip_next_type_value=false

  [[ -n "$FDX_ROOT_DIR" ]] && root_dir="$FDX_ROOT_DIR"

  while IFS='=' read -r key value; do
    case "$key" in
      hidden) hidden="$value" ;;
      type) type_filter="$value" ;;
    esac
  done < "$state_file"

  local hidden_label=OFF
  [[ "$hidden" == 1 ]] && hidden_label=ON
  local type_label='Files only'
  case "$type_filter" in
    d) type_label='Directories only' ;;
    all) type_label='Files and Directories' ;;
  esac
  printf 'Status --> Show Hidden Files:%s | Type:%s\t\n' "$hidden_label" "$type_label"

  fd_args=(--color=never)
  [[ "$hidden" == 1 ]] && fd_args+=(--hidden)
  [[ "$type_filter" != all ]] && fd_args+=(--type "$type_filter")

  if [[ -n "$FDX_ARGS_FILE" && -f "$FDX_ARGS_FILE" ]]; then
    while IFS= read -r arg; do
      if [[ "$skip_next_type_value" == true ]]; then
        skip_next_type_value=false
        continue
      fi

      [[ -n "$arg" ]] || continue
      [[ "$arg" == --hidden || "$arg" == -H ]] && continue

      if [[ "$arg" == -t || "$arg" == --type ]]; then
        skip_next_type_value=true
        continue
      fi

      [[ "$arg" == --type=* || "$arg" == -t?* ]] && continue
      fd_args+=("$arg")
    done < "$FDX_ARGS_FILE"
  fi

  if [[ "$root_dir" == . ]]; then
    fd "${fd_args[@]}"
  else
    fd "${fd_args[@]}" . "$root_dir"
  fi | while IFS= read -r file; do
    [[ "$type_filter" == f && ! -f "$file" ]] && continue
    [[ "$type_filter" == d && ! -d "$file" ]] && continue

    name="${file:t}"
    dir="${file:h}"
    local display="$file"
    git_root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)
    [[ -n "$git_root" ]] && display="${git_root:t}/$name"
    (( ${#display} > 55 )) && display="${display[1,53]}.."

    printf '%s\t%s\n' "$display" "$file"
  done
}

function __fdx_toggle_hidden_zsh {
  local state_file="$1"
  local tmp_file="${state_file}.tmp"
  local key value

  while IFS='=' read -r key value; do
    case "$key" in
      hidden) printf 'hidden=%s\n' $(( 1 - value )) ;;
      *) printf '%s=%s\n' "$key" "$value" ;;
    esac
  done < "$state_file" >| "$tmp_file"

  mv -f "$tmp_file" "$state_file"
}

function __fdx_cycle_type_zsh {
  local state_file="$1"
  local tmp_file="${state_file}.tmp"
  local key value next_type

  while IFS='=' read -r key value; do
    case "$key" in
      type)
        case "$value" in
          f) next_type=d ;;
          d) next_type=all ;;
          *) next_type=f ;;
        esac
        printf 'type=%s\n' "$next_type"
        ;;
      *) printf '%s=%s\n' "$key" "$value" ;;
    esac
  done < "$state_file" >| "$tmp_file"

  mv -f "$tmp_file" "$state_file"
}

function fdx {
  local pattern=""
  local root_dir=.
  local widget_mode=false
  local initial_hidden=0
  local initial_type=f
  local skip_next_type_value=false
  local skip_next_query_value=false
  local skip_next_dir_value=false
  local -a fd_args
  local arg

  for arg in "$@"; do
    case "$arg" in
      --help|-h)
        echo "Usage: fdx [OPTIONS] [PATTERN]"
        echo ""
        echo "fd + fzf + bat preview — fuzzy file/directory finder with editor launch"
        echo ""
        echo "Options:"
        echo "  --query, -q <pattern>       Initial search pattern"
        echo "  --query=<pattern>            (alternative form)"
        echo "  --dir, -d <path>             Root directory (default: .)"
        echo "  --dir=<path>                 (alternative form)"
        echo "  --type, -t <f|d|all>         Filter by file type (default: f)"
        echo "  --type=f|d|all, -t[f|d]     (shorthand)"
        echo "  --hidden, -H                 Include hidden files"
        echo "  --widget                     Output-only mode (no editor)"
        echo "  --help, -h                   Show this help"
        echo ""
        echo "Keybindings:"
        echo "  Enter        Open in editor (or print path in command substitution)"
        echo "  Ctrl-P       Paste selected paths"
        echo "  Ctrl-Y       Yank paths to clipboard"
        echo "  Ctrl-Space   Toggle file preview"
        echo "  Tab          Select multiple rows"
        echo "  Ctrl-H       Toggle hidden files"
        echo "  Ctrl-T       Cycle file type (f → d → all)"
        echo "  ←/→          Scroll preview"
        echo ""
        echo "Examples:"
        echo "  fdx"
        echo "  fdx somefile"
        echo "  fdx --hidden --type d"
        echo "  fdx --dir ~/projects"
        echo "  nvim (fdx --widget)"
        return 0
        ;;
    esac
  done

  for arg in "$@"; do
    if [[ "$skip_next_query_value" == true ]]; then
      pattern="$arg"
      skip_next_query_value=false
      continue
    fi

    if [[ "$skip_next_dir_value" == true ]]; then
      root_dir="$arg"
      skip_next_dir_value=false
      continue
    fi

    if [[ "$skip_next_type_value" == true ]]; then
      case "$arg" in
        f|file) initial_type=f ;;
        d|dir|directory) initial_type=d ;;
        all|any) initial_type=all ;;
      esac

      skip_next_type_value=false
      continue
    fi

    case "$arg" in
      --hidden|-H)
        initial_hidden=1
        continue
        ;;
      --widget)
        widget_mode=true
        continue
        ;;
      --query)
        skip_next_query_value=true
        continue
        ;;
      --query=*)
        pattern="${arg#--query=}"
        continue
        ;;
      --dir)
        skip_next_dir_value=true
        continue
        ;;
      --dir=*)
        root_dir="${arg#--dir=}"
        continue
        ;;
      --type|-t)
        skip_next_type_value=true
        continue
        ;;
      --type=f|--type=file|-tf)
        initial_type=f
        continue
        ;;
      --type=d|--type=dir|--type=directory|-td)
        initial_type=d
        continue
      ;;
    esac

    fd_args+=("$arg")

    if [[ "$arg" != -* ]]; then
      pattern="$arg"
    fi
  done

  local state_file args_file
  state_file=$(mktemp -t fdx-state.XXXXXX)
  args_file=$(mktemp -t fdx-args.XXXXXX)
  printf 'hidden=%s\n' "$initial_hidden" >| "$state_file"
  printf 'type=%s\n' "$initial_type" >> "$state_file"
  printf '%s\n' "${fd_args[@]}" >| "$args_file"

  export FDX_PATTERN="$pattern"
  export FDX_ARGS_FILE="$args_file"
  export FDX_ROOT_DIR="$root_dir"

  local -a selection rows files
  local key row display file

  selection=("${(@f)$(__fdx_search_zsh "$state_file" \
    | fzf \
      --ansi \
      --delimiter $'\t' \
      --with-nth=1 \
      --nth=1 \
      --expect=enter,ctrl-p,ctrl-y \
      --header=$'Editor: Enter/print path | Ctrl+P: Paste path   | Ctrl+Y: Yank path\nCtrl+Space: Preview      | Tab: Select row      |\nCtrl+H: Hidden           | Ctrl+T: Type f/d/all | ←/→: Preview scroll' \
      --header-lines=1 \
      --preview 'zsh -c '\''source "${ZDOTDIR:-$HOME/.config/zsh}/functions/user-tools.zsh"; __fdx_preview_zsh "$@"'\'' -- {2}' \
      --preview-window='right:60%:wrap' \
      --bind 'right:preview-down,left:preview-up,ctrl-space:toggle-preview' \
      --bind "ctrl-h:reload(zsh -c 'source \"\${ZDOTDIR:-\$HOME/.config/zsh}/functions/user-tools.zsh\"; __fdx_toggle_hidden_zsh \"\$1\"; __fdx_search_zsh \"\$1\"' -- '$state_file')" \
      --bind "ctrl-t:reload(zsh -c 'source \"\${ZDOTDIR:-\$HOME/.config/zsh}/functions/user-tools.zsh\"; __fdx_cycle_type_zsh \"\$1\"; __fdx_search_zsh \"\$1\"' -- '$state_file')" \
      --multi)}")

  key="${selection[1]}"
  rows=("${selection[@]:1}")
  rm -f "$state_file" "$args_file"

  [[ ${#rows[@]} -gt 0 ]] || return

  for row in "${rows[@]}"; do
    IFS=$'\t' read -r display file <<< "$row"
    [[ -n "$file" ]] && files+=("$file")
  done

  case "$key" in
    ctrl-p)
      __zsh_picker_print_unique "${files[@]}"
      ;;
    ctrl-y)
      __zsh_picker_print_unique "${files[@]}" | wl-copy
      ;;
    enter|'')
      if __zsh_picker_in_cmdsubst && [[ "$widget_mode" == false ]]; then
        __zsh_picker_print_unique "${files[@]}"
        return
      fi

      nvim "${files[@]}"
      ;;
  esac
}

function __fdx_parse_commandline_zsh {
  local token="${LBUFFER##*[[:space:]]}"
  local query="$token"
  local prefix=""
  local dir="."
  local path_query path_dir base_dir

  if [[ "$LBUFFER" != *' -- '* && "$token" =~ '^(-[^[:space:]=]+=|-[^-])' ]]; then
    prefix="$MATCH"
    query="${token#$prefix}"
  fi

  if [[ -n "$query" ]]; then
    path_query="${query/#\~/$HOME}"
    [[ "$path_query" != /* ]] && path_query="$PWD/$path_query"
    path_dir="$path_query"

    while [[ ! -d "$path_dir" && "$path_dir" != / ]]; do
      path_dir="${path_dir:h}"
    done

    if [[ -d "$path_dir" ]]; then
      dir="$path_dir"
      base_dir="$dir"
      [[ "$base_dir" != */ ]] && base_dir="$base_dir/"
      query="${path_query#$base_dir}"
    fi
  fi

  print -r -- "$dir"
  print -r -- "$query"
  print -r -- "$prefix"
  print -r -- "$token"
}

function fdx_file_widget_zsh {
  local -a parsed result
  local dir query prefix token replacement

  parsed=("${(@f)$(__fdx_parse_commandline_zsh)}")
  dir="${parsed[1]:-.}"
  query="${parsed[2]:-}"
  prefix="${parsed[3]:-}"
  token="${parsed[4]:-}"
  result=("${(@f)$(fdx --widget --dir "$dir" --query "$query")}")

  if (( ${#result[@]} )); then
    replacement="${prefix}${(j: :)${(q)result}} "
    LBUFFER="${LBUFFER[1,$(( ${#LBUFFER} - ${#token} ))]}$replacement"
  fi

  zle reset-prompt
}
