function osp
    set -l pm paru
    set -l pm_sudo sudo paru
    set -l official_mode 0
    set -l args

    # Scan for -o / --official anywhere in args (standalone or combined like -Ro)
    for arg in $argv
        switch $arg
            case -o --official
                set official_mode 1
            case '-*'
                set -l stripped (string replace -r -- '^-([^-]*?)o([^-]*)$' '-$1$2' $arg)
                if test "$stripped" != "$arg"
                    set official_mode 1
                    if test "$stripped" != '-'
                        set -a args $stripped
                    end
                else
                    set -a args $arg
                end
            case '*'
                set -a args $arg
        end
    end

    if test $official_mode -eq 1
        set pm pacman
        set pm_sudo sudo pacman
    end

    set argv $args

    switch "$argv[1]"
        case -R -Rn -Rs -Rns --remove -rn
            $pm_sudo -Rns --noconfirm $argv[2..-1]
        case -Ss -s --search
            $pm -Ss $argv[2..-1]
        case -Q -q --query
            $pm -Q $argv[2..-1]
        case -Syu -Su -Syuu --update
            $pm_sudo -Syu --noconfirm $argv[2..-1]
        case ''
            echo "Usage: osp [options] <package>"
            echo ""
            echo "  osp <package>      install via paru (default)"
            echo "  osp -o <package>   install via pacman (official only)"
            echo "  osp -Ro <package>  remove via pacman"
            echo "  osp -R <package>   remove"
            echo "  osp -Ss <term>     search"
            echo "  osp -Q <term>      query installed"
            echo "  osp -Syu           full system update"
        case '*'
            $pm_sudo -S --noconfirm $argv
    end
end
