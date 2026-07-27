function __rgx_toggle_hidden --argument-names state_file --description "Toggle rgx hidden state"
    set -l new_lines

    while read -l line
        if string match -q 'hidden=*' -- $line
            set -l value (string split -m 1 = -- $line)[2]
            set -a new_lines "hidden="(math "1 - $value")
        else
            set -a new_lines $line
        end
    end < $state_file

    printf "%s\n" $new_lines > $state_file
end
