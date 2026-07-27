function __fdx_cycle_type --argument-names state_file --description "Cycle fdx type state"
    set -l new_lines

    while read -l line
        if string match -q 'type=*' -- $line
            set -l value (string split -m 1 = -- $line)[2]
            set -l next_type

            switch $value
                case f
                    set next_type d
                case d
                    set next_type all
                case '*'
                    set next_type f
            end

            set -a new_lines "type=$next_type"
        else
            set -a new_lines $line
        end
    end < $state_file

    printf "%s\n" $new_lines > $state_file
end
