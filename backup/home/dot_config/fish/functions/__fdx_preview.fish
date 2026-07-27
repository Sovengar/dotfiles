function __fdx_preview --argument-names file --description "Preview fdx paths with bat and optional match highlighting"
    if not test -f "$file"
        if test -d "$file"
            command eza --icons --group-directories-first "$file" 2>/dev/null; or ls --color=auto "$file"
        end

        return
    end

    set -l pattern $FDX_PATTERN
    set -l header_color (set_color cyan)
    set -l match_color (set_color --bold --background=yellow black)
    set -l reset_color (set_color normal)

    printf "%s%s%s\n\n" "$header_color" "$file" "$reset_color"

    if not type -q bat
        while read -l content
            printf "%s\n" "$content"
        end < "$file"

        return
    end

    if test -z "$pattern"
        bat --color=always --style=numbers --paging=never "$file"
        return
    end

    set -l escaped_pattern (string escape --style=regex -- "$pattern")
    bat --color=always --style=numbers --paging=never "$file" \
        | while read -l content
            if string match -qri -- "$escaped_pattern" "$content"
                set content (string replace -ari -- "$escaped_pattern" "$match_color\$0$reset_color" -- "$content")
            end

            printf "%s\n" "$content"
        end
end
