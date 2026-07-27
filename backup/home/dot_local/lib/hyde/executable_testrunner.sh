#!/usr/bin/env bash
scrDir=$(dirname "$(realpath "$0")")
source $scrDir/globalcontrol.sh
rofDir="$confDir/rofi"
if [ "$1" == "--verbose" ] || [ "$1" == "-v" ]; then
    case ${PALETTE_SOURCE:-theme} in
        theme) wallbashStatus="disabled (static theme)" ;;
        wallbash_auto) wallbashStatus="enabled // auto change based on wallpaper brightness" ;;
        wallbash_dark) wallbashStatus="enabled // dark mode --forced" ;;
        wallbash_light) wallbashStatus="enabled // light mode --forced" ;;
    esac
    echo -e "\n\ncurrent theme :: \"$HYDE_THEME\" :: \"$(readlink "$HYDE_THEME_WALL")\""
    echo -e "PALETTE_SOURCE :: ${PALETTE_SOURCE:-theme} :: $wallbashStatus\n"
    get_themes
    for x in "${!thmList[@]}"; do
        echo -e "\nTheme $((x + 1)) :: \${thmList[$x]}=\"${thmList[x]}\" :: \${thmWall[$x]}=\"${thmWall[x]}\"\n"
        get_hashmap "$(dirname "$HYDE_THEME_DIR")/${thmList[x]}" --verbose
        echo -e "\n"
    done
    exit 0
fi
