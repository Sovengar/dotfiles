local vars = require("hyprland.hyde.variables")

local function exec_once(command)
    hl.exec_cmd(command)
end

hl.on("hyprland.start", function()
    exec_once("dbus-update-activation-environment --systemd --all")
    exec_once("dbus-update-activation-environment --systemd " .. vars.envList)
    exec_once("systemctl --user import-environment " .. vars.envList)
    exec_once("hyde-shell resetxdgportal.sh")
    exec_once("hyde-shell app -t service -- polkitkdeauth.sh")

    exec_once("hyde-shell app -u " .. vars.unit .. "-bar.scope -t scope -- waybar.py --watch")
    exec_once("hyde-shell app -u " .. vars.unit .. "-notifications.service -t service -- dunst")
    exec_once("sh -c 'command -v swayosd-server >/dev/null 2>&1 && hyde-shell app -u " .. vars.unit .. "-swayosd.service -t service -- swayosd-server'")
    exec_once("hyde-shell app -u " .. vars.unit .. "-wallpaper.service -t service -- wallpaper.sh --start --global")

    exec_once("hyde-shell app -u " .. vars.unit .. "-text-clipboard.service -t service wl-paste --type text --watch cliphist store")
    exec_once("hyde-shell app -u " .. vars.unit .. "-image-clipboard.service -t service wl-paste --type image --watch cliphist store")

    exec_once("hyde-shell app -u " .. vars.unit .. "-network-manager-applet.service -t service -- nm-applet --indicator")
    exec_once("hyde-shell app -u " .. vars.unit .. "-removable-media-applet.service -t service -- udiskie --no-automount --smart-tray")
    exec_once("hyde-shell app -u " .. vars.unit .. "-bluetooth-applet.service -t service -- blueman-applet")
    exec_once("hyde-shell app -u " .. vars.unit .. "-battery-notify.service -t service -- batterynotify.sh")

    exec_once("hyde-shell app -u " .. vars.unit .. "-idle.service -t service -- hypridle")
    exec_once("hyde-shell app -u " .. vars.unit .. "-blue-light-filter.service -t service -- hyprsunset")

    exec_once("hyde-shell app -t service hyde-config --no-startup")
    exec_once("hyprctl setcursor " .. vars.CURSOR_THEME .. " " .. vars.CURSOR_SIZE)
end)
