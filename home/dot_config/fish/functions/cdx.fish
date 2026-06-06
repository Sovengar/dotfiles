function cdx --wraps cdx-rs --description 'Interactive directory navigator wrapper'
    set -l result_file /tmp/cdx-rs-result.txt
    rm -f $result_file
    cdx-rs $argv >/dev/null 2>&1
    if test $status -eq 0 -a -f "$result_file"
        set -l target (string trim (cat $result_file))
        rm -f $result_file
        if test -n "$target" -a -d "$target"
            builtin cd "$target"
            command eza --icons --group-directories-first 2>/dev/null; or ls --color=auto
        end
    end
end
