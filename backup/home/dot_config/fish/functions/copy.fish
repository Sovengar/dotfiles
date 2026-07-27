function copy --description 'Copy files, recursively for directory sources'
    set -l count (count $argv)
    if test "$count" = 2; and test -d "$argv[1]"
        set -l from (string trim -r -c / -- $argv[1])
        set -l to $argv[2]
        command cp -r $from $to
    else
        command cp $argv
    end
end
