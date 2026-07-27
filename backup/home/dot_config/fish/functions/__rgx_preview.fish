function __rgx_preview --argument-names pattern file line --description "Preview rgx matches with plain text and highlighted match"
    if not test -f "$file"
        return
    end

    if not string match -qr '^[0-9]+$' -- $line
        set line 1
    end

    set -l start (math "max(1, $line - 200)")
    set -l end (math "$line + 200")
    set -l header_color (set_color cyan)
    set -l line_color (set_color brblack)
    set -l exact_match_color (set_color --bold --background=yellow black)
    set -l folded_match_color (set_color --bold --background=brcyan black)
    set -l reset_color (set_color normal)
    printf "%s%s:%s%s\n\n" "$header_color" "$file" "$line" "$reset_color"

    if type -q bat
        bat --color=always --style=numbers --paging=never --line-range "$start:$end" --highlight-line "$line" --theme='RGX Muted' "$file" \
            | while read -l content
                if test -n "$pattern"
                    set -l escaped_highlight (string escape --style=regex -- "$pattern")
                    set -l matches (string match -a -r -i -- "$escaped_highlight" "$content")

                    for match in (printf "%s\n" $matches | sort -u)
                        set -l match_color $folded_match_color

                        if test "$match" = "$pattern"
                            set match_color $exact_match_color
                        end

                        set content (string replace -a -- "$match" "$match_color$match$reset_color" -- "$content")
                    end
                end

                printf "%s\n" "$content"
            end

        return
    end

    set -l current_file_line 0
    while read -l content
        set current_file_line (math "$current_file_line + 1")

        if test $current_file_line -lt $start
            continue
        end

        if test $current_file_line -gt $end
            break
        end

        if test -n "$pattern"
            set -l escaped_highlight (string escape --style=regex -- "$pattern")
            set -l matches (string match -a -r -i -- "$escaped_highlight" "$content")

            for match in (printf "%s\n" $matches | sort -u)
                set -l match_color $folded_match_color

                if test "$match" = "$pattern"
                    set match_color $exact_match_color
                end

                set content (string replace -a -- "$match" "$match_color$match$reset_color" -- "$content")
            end
        end

        printf "%s%6d%s  %s\n" "$line_color" "$current_file_line" "$reset_color" "$content"
    end < "$file"
end
