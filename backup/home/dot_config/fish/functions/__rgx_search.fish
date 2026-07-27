function __rgx_search --argument-names state_file --description "Run rg and format rgx rows"
    set -l hidden 0

    while read -l line
        set -l parts (string split -m 1 = -- $line)

        switch $parts[1]
            case hidden
                set hidden $parts[2]
        end
    end < $state_file

    set -l hidden_label OFF
    if test "$hidden" = 1
        set hidden_label ON
    end

    printf "Status --> Show Hidden Files:%s\t\t\n" "$hidden_label"

    set -l rg_args --line-number --no-heading --color=never -i

    if test "$hidden" = 1
        set -a rg_args --hidden
    end

    if test -n "$RGX_ARGS_FILE" -a -f "$RGX_ARGS_FILE"
        while read -l arg
            if test -n "$arg"
                if string match -q -- '--hidden' $arg; or string match -q -- '-H' $arg
                    continue
                end

                set -a rg_args $arg
            end
        end < $RGX_ARGS_FILE
    end

    set -l cached_dirs
    set -l cached_root_names

    rg $rg_args | while read -l row
        set -l parts (string split -m 2 ':' -- $row)

        if test (count $parts) -ge 3
            set -l file $parts[1]
            set -l line $parts[2]
            set -l preview_start (math "max(1, $line - 200)")
            set -l preview_scroll (math "$line - $preview_start + 3")
            set -l match (string trim -- $parts[3])
            set match (string replace -a (printf '\t') ' ' -- "$match")
            set -l name (path basename -- "$file")
            set -l dir (path dirname -- "$file")
            set -l git_root_name
            set -l cache_index (contains -i -- "$dir" $cached_dirs)

            if test -n "$cache_index"
                set git_root_name $cached_root_names[$cache_index]
            else
                set -l git_root (command git -C "$dir" rev-parse --show-toplevel 2>/dev/null)

                if test -n "$git_root"
                    set git_root_name (path basename -- "$git_root")
                end

                set -a cached_dirs "$dir"
                set -a cached_root_names "$git_root_name"
            end

            if test (string length -- "$name") -gt 35
                set name (string sub -l 33 -- "$name")".."
            end

            if test (string length -- "$match") -gt 70
                set match (string sub -l 70 -- "$match")
            end

            if test -n "$git_root_name"
                printf "%s || %s:%s --> %s\t%s\t%s\t%s\n" "$git_root_name" "$name" "$line" "$match" "$file" "$line" "$preview_scroll"
            else
                printf "%s:%s --> %s\t%s\t%s\t%s\n" "$name" "$line" "$match" "$file" "$line" "$preview_scroll"
            end
        end
    end
end
