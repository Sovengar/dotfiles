function __fdx_search --argument-names state_file --description "Run fd and format fdx rows"
    set -l hidden 0
    set -l type_filter f
    set -l root_dir .

    if set -q FDX_ROOT_DIR
        set root_dir $FDX_ROOT_DIR
    end

    while read -l line
        set -l parts (string split -m 1 = -- $line)

        switch $parts[1]
            case hidden
                set hidden $parts[2]
            case type
                set type_filter $parts[2]
        end
    end < $state_file

    set -l hidden_label OFF
    if test "$hidden" = 1
        set hidden_label ON
    end

    set -l type_label "Files only"
    switch $type_filter
        case d
            set type_label "Directories only"
        case all
            set type_label "Files and Directories"
    end

    printf "Status --> Show Hidden Files:%s | Type:%s\t\n" "$hidden_label" "$type_label"

    set -l fd_args --color=never

    if test "$hidden" = 1
        set -a fd_args --hidden
    end

    if test "$type_filter" != all
        set -a fd_args --type $type_filter
    end

    if test -n "$FDX_ARGS_FILE" -a -f "$FDX_ARGS_FILE"
        set -l skip_next_type_value false

        while read -l arg
            if test $skip_next_type_value = true
                set skip_next_type_value false
                continue
            end

            if test -n "$arg"
                if string match -q -- '--hidden' $arg; or string match -q -- '-H' $arg
                    continue
                end

                if string match -q -- '-t' $arg; or string match -q -- '--type' $arg
                    set skip_next_type_value true
                    continue
                end

                if string match -q -- '--type=*' $arg; or string match -qr -- '^-t.+' $arg
                    continue
                end

                set -a fd_args $arg
            end
        end < $FDX_ARGS_FILE
    end

    begin
        if test "$root_dir" = .
            fd $fd_args
        else
            fd $fd_args . "$root_dir"
        end
    end | while read -l file
        if test "$type_filter" = f; and not test -f "$file"
            continue
        end

        if test "$type_filter" = d; and not test -d "$file"
            continue
        end

        set -l name (path basename -- "$file")
        set -l dir (path dirname -- "$file")
        set -l display $file

        set -l git_root (command git -C "$dir" rev-parse --show-toplevel 2>/dev/null)
        if test -n "$git_root"
            set display (path basename -- "$git_root")"/"$name
        end

        if test (string length -- "$display") -gt 55
            set display (string sub -l 53 -- "$display")".."
        end

        printf "%s\t%s\n" "$display" "$file"
    end
end
