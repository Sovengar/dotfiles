function __fdx_parse_commandline --description 'Parse the current command line token for fdx widget'
    set -l fzf_query ''
    set -l prefix ''
    set -l dir '.'

    set -l match_regex '(?<fzf_query>[\s\S]*?(?=\n?$)$)'
    set -l prefix_regex '^-[^\s=]+=|^-(?!-)\S'

    string match -qv -- '* -- *' (string sub -l (commandline -Cp) -- (commandline -p))
    and set match_regex "(?<prefix>$prefix_regex)?$match_regex"

    if string match -qr -- '^\d\d+|^[4-9]' $version
        string match -q -r -- $match_regex (commandline --current-token --tokens-expanded | string collect -N)
    else
        string match -q -r -- $match_regex (commandline --current-token --tokenize | string collect -N)
        eval set -- fzf_query (string escape -n -- $fzf_query | string replace -r -a '^\\(?=~)|\\(?=\$\w)' '')
    end

    if test -n "$fzf_query"
        if string match -qr -- '^\d\d+|^4|^3\.[5-9]' $version
            set fzf_query (path normalize -- $fzf_query)
            set dir $fzf_query
            while not path is -d $dir
                set dir (path dirname $dir)
            end
        else
            string match -q -r -- '(?<fzf_query>^[\s\S]*?(?=\n?$)$)' \
                (string replace -r -a -- '(?<=/)/|(?<!^)/+(?!\n)$' '' $fzf_query | string collect -N)
            set dir $fzf_query
            while not test -d "$dir"
                set dir (dirname -z -- "$dir" | string split0)
            end
        end

        if not string match -q -- '.' $dir; or string match -qr -- '^\.(/|$)' $fzf_query
            if string match -qr -- '^\d\d+|^[4-9]' $version
                string match -q -r -- '^'(string escape --style=regex -- $dir)'/?(?<fzf_query>[\s\S]*)' $fzf_query
            else
                string match -q -r -- '^/?(?<fzf_query>[\s\S]*?(?=\n?$)$)' \
                    (string replace -- "$dir" '' $fzf_query | string collect -N)
            end
        end
    end

    string escape -n -- "$dir" "$fzf_query" "$prefix"
end
