function fdx --description "fd + fzf + bat preview + nvim/path output"
    set -l pattern
    set -l root_dir .
    set -l widget_mode false
    set -l floating_mode false
    set -l opencode_mode false
    set -l initial_hidden 0
    set -l initial_type f
    set -l skip_next_type_value false
    set -l skip_next_query_value false
    set -l skip_next_dir_value false
    set -l fd_args

    for arg in $argv
        switch $arg
            case --help -h
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
                echo "  --floating                   Floating window mode"
                echo "  --opencode                   OpenCode prompt bridge integration"
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
                echo "Environment:"
                echo "  FDX_EDITOR   Custom editor command (default: nvim)"
                echo ""
                echo "Examples:"
                echo "  fdx"
                echo "  fdx somefile"
                echo "  fdx --hidden --type d"
                echo "  fdx --dir ~/projects"
                echo "  fdx --floating --opencode"
                echo "  nvim (fdx --widget)"
                return 0
        end
    end

    for index in (seq (count $argv))
        set -l arg $argv[$index]

        if test $skip_next_query_value = true
            set pattern $arg
            set skip_next_query_value false
            continue
        end

        if test $skip_next_dir_value = true
            set root_dir $arg
            set skip_next_dir_value false
            continue
        end

        if test $skip_next_type_value = true
            switch $arg
                case f file
                    set initial_type f
                case d dir directory
                    set initial_type d
                case all any
                    set initial_type all
            end

            set skip_next_type_value false
            continue
        end

        switch $arg
            case --hidden -H
                set initial_hidden 1
                continue
            case --widget
                set widget_mode true
                continue
            case --floating
                set floating_mode true
                continue
            case --opencode
                set opencode_mode true
                continue
            case --query
                set skip_next_query_value true
                continue
            case '--query=*'
                set pattern (string replace -- '--query=' '' -- $arg)
                continue
            case --dir
                set skip_next_dir_value true
                continue
            case '--dir=*'
                set root_dir (string replace -- '--dir=' '' -- $arg)
                continue
            case --type -t
                set skip_next_type_value true
                continue
            case --type=f --type=file -tf
                set initial_type f
                continue
            case --type=d --type=dir --type=directory -td
                set initial_type d
                continue
        end

        set -a fd_args $arg

        if test -z "$pattern"; and not string match -q -- '-*' $arg
            set pattern $arg
        end
    end

    set -l tab (printf '\t')
    set -l state_file (mktemp -t fdx-state.XXXXXX)
    set -l args_file (mktemp -t fdx-args.XXXXXX)

    printf "hidden=%s\n" $initial_hidden > $state_file
    printf "type=%s\n" $initial_type >> $state_file
    printf "%s\n" $fd_args > $args_file

    set -lx FDX_PATTERN $pattern
    set -lx FDX_ARGS_FILE $args_file
    set -lx FDX_ROOT_DIR $root_dir
    set -l expect_keys enter,ctrl-p,ctrl-y
    set -l header 'Editor: Enter/print path | Ctrl+P: Paste path   | Ctrl+Y: Yank path
Ctrl+Space: Preview      | Tab: Select row      |
Ctrl+H: Hidden           | Ctrl+T: Type f/d/all | ←/→: Preview scroll'

    if test $floating_mode = true
        set expect_keys enter,ctrl-y
        set header 'Enter: Open editor       | Ctrl+Y: Yank path
Ctrl+Space: Preview      | Tab: Select row
Ctrl+H: Hidden           | Ctrl+T: Type f/d/all | ←/→: Preview scroll'

        if test $opencode_mode = true
            set expect_keys enter,ctrl-o,ctrl-y
            set header 'Enter: Open editor       | Ctrl+O: Send to OpenCode | Ctrl+Y: Yank path
Ctrl+Space: Preview      | Tab: Select row
Ctrl+H: Hidden           | Ctrl+T: Type f/d/all   | ←/→: Preview scroll'
        end
    end

    set -l fzf_args \
        --ansi \
        --delimiter "$tab" \
        --with-nth=1 \
        --nth=1 \
        --query "$pattern" \
        --expect="$expect_keys" \
        --header="$header" \
        --header-lines=1 \
        --preview '__fdx_preview {2}' \
        --preview-window='right:60%:wrap' \
        --bind 'right:preview-down,left:preview-up,ctrl-space:toggle-preview' \
        --bind "ctrl-h:reload(__fdx_toggle_hidden $state_file; __fdx_search $state_file)" \
        --bind "ctrl-t:reload(__fdx_cycle_type $state_file; __fdx_search $state_file)" \
        --multi

    if test $floating_mode = true
        set -a fzf_args --bind 'ctrl-p:ignore'
    end

    set -l selection (
        __fdx_search $state_file \
            | fzf $fzf_args
    )

    set -l key $selection[1]
    set -l rows $selection[2..]

    rm -f $state_file $args_file

    if test -z "$rows"
        return
    end

    set -l files
    for row in $rows
        set -l clean (string replace -ra '\e\[[0-9;]*[a-zA-Z]' '' -- $row)
        set -l parts (string split "$tab" -- $clean)

        if test (count $parts) -ge 2
            set -a files $parts[2]
        end
    end

    switch $key
        case ctrl-p
            set -l first true
            for file in (printf "%s\n" $files | sort -u)
                if test $first = false
                    printf "\n"
                end

                printf "%s" $file
                set first false
            end
        case ctrl-y
            string join \n (printf "%s\n" $files | sort -u) | wl-copy
            if test $floating_mode = true
                pypr hide fdx-floating >/dev/null 2>&1
            end
        case ctrl-o
            if test $opencode_mode = false
                return 1
            end

            set -l prompt_text " "(string join ' ' -- (string escape -n -- (printf "%s\n" $files | sort -u)))
            if "$HOME/.config/opencode/plugins/prompt-bridger-client" "$prompt_text"
                printf 'Appended %d path(s) to OpenCode prompt\n' (count $files)
            else
                printf 'Prompt bridge unavailable; selected path(s) were not appended\n' >&2
            end

            if test $floating_mode = true
                pypr hide fdx-floating >/dev/null 2>&1
            end
        case enter ''
            if status --is-command-substitution; and test $widget_mode = false
                set -l first true
                for file in (printf "%s\n" $files | sort -u)
                    if test $first = false
                        printf "\n"
                    end

                    printf "%s" $file
                    set first false
                end

                return
            end

            set -l editor nvim
            if set -q FDX_EDITOR
                set editor (string split ' ' -- $FDX_EDITOR)
            end

            command $editor $files
            if test $floating_mode = true
                pypr hide fdx-floating >/dev/null 2>&1
            end
    end
end
