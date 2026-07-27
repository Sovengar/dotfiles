function connect
    switch $argv[1]
        case jon
            wezterm connect jon
        case '*'
            echo "Unknown target: $argv[1]"
    end
end
