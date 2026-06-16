function osp {
    local cmd=(sudo paru)
    local pm="paru"
    local official_mode=0
    local args=()

    for arg in "$@"; do
        case "$arg" in
            -o|--official)
                official_mode=1
                ;;
            -*)
                local stripped="${arg/o/}"
                if [[ "$stripped" != "$arg" ]]; then
                    official_mode=1
                    [[ "$stripped" != "-" ]] && args+=("$stripped")
                else
                    args+=("$arg")
                fi
                ;;
            *)
                args+=("$arg")
                ;;
        esac
    done

    if [[ $official_mode -eq 1 ]]; then
        cmd=(sudo pacman)
        pm="pacman"
    fi

    set -- "${args[@]}"

    case "${1:-}" in
        -R|-Rn|-Rs|-Rns|--remove|-rn)
            $cmd -Rns --noconfirm "${@:2}"
            ;;
        -Ss|-s|--search)
            $pm -Ss "${@:2}"
            ;;
        -Q|-q|--query)
            $pm -Q "${@:2}"
            ;;
        -Syu|-Su|-Syuu|--update)
            $cmd -Syu --noconfirm "${@:2}"
            ;;
        '')
            echo "Usage: osp [options] <package>"
            echo ""
            echo "  osp <package>      install via paru (default)"
            echo "  osp -o <package>   install via pacman (official only)"
            echo "  osp -Ro <package>  remove via pacman"
            echo "  osp -R <package>   remove"
            echo "  osp -Ss <term>     search"
            echo "  osp -Q <term>      query installed"
            echo "  osp -Syu           full system update"
            ;;
        *)
            $cmd -S --noconfirm "$@"
            ;;
    esac
}
