function fdx_file_widget --description 'Open fdx and insert selected paths into the command line'
    set -l parsed (__fdx_parse_commandline)
    set -l dir $parsed[1]
    set -l query $parsed[2]
    set -l prefix $parsed[3]

    set -l result (fdx --widget --dir "$dir" --query "$query")

    if test -n "$result"
        commandline -rt -- (string join -- ' ' $prefix(string escape -n -- $result))' '
    end

    commandline -f repaint
end
