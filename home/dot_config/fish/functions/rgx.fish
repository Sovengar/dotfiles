function rgx --description "rg + fzf + bat preview + nvim/path output"
    for arg in $argv
        switch $arg
            case --help -h
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
        end
    end

    set -l pattern
    set -l initial_hidden 0

    for arg in $argv
        switch $arg
            case --help -h
                # handled above, skip
                continue
            case --hidden -H
                set initial_hidden 1
                continue
        end

        if not string match -q -- '-*' $arg
            set pattern $arg
            break
        end
    end

    set -lx RGX_PATTERN $pattern
    set -l state_file (mktemp -t rgx-state.XXXXXX)
    set -l args_file (mktemp -t rgx-args.XXXXXX)
    printf "hidden=%s\n" $initial_hidden > $state_file
    printf "%s\n" $argv > $args_file

    set -lx RGX_ARGS_FILE $args_file
    set -l tab (printf '\t')
    set -l header 'Enter: nvim/print path | Ctrl+P: Paste path | Ctrl+Y: Yank path  |
Ctrl+Space: Preview    | Tab: Select row   | Alt+H: Hidden      | ←/→: Preview scroll'

    set -l selection (
        __rgx_search $state_file \
            | fzf \
                --delimiter "$tab" \
                --with-nth=1 \
                --nth=1 \
                --expect=enter,ctrl-p,ctrl-y \
                --header="$header" \
                --header-lines=1 \
                --preview '__rgx_preview "$RGX_PATTERN" {2} {3}' \
                --preview-window='up:60%:wrap:+{4}-/2' \
                --bind 'right:preview-down,left:preview-up,ctrl-d:preview-page-down,ctrl-u:preview-page-up,ctrl-space:toggle-preview' \
                --bind "alt-h:reload(__rgx_toggle_hidden $state_file; __rgx_search $state_file)" \
                --multi
    )

    set -l key $selection[1]
    set -l rows $selection[2..]

    rm -f $state_file $args_file

    if test -z "$rows"
        return
    end

    set -l files
    set -l nvim_args

    for row in $rows
        set -l clean (string replace -ra '\e\[[0-9;]*[a-zA-Z]' '' -- $row)
        set -l parts (string split "$tab" -- $clean)

        if test (count $parts) -ge 3
            set -a files $parts[2]
            set -a nvim_args "+$parts[3]" $parts[2]
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
        case enter ''
            if status --is-command-substitution
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

            nvim $nvim_args
    end
end
