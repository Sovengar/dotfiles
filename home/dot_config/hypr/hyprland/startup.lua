local vars = require("hyprland.variables")
local home = os.getenv("HOME") or ""

local xdg_runtime = os.getenv("XDG_RUNTIME_DIR") or ("/run/user/" .. (os.getenv("UID") or "1000"))
local xdg_cache = os.getenv("XDG_CACHE_HOME") or (home .. "/.cache")
local xdg_config = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local xdg_data = os.getenv("XDG_DATA_HOME") or (home .. "/.local/share")
local xdg_state = os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")

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
    -- exec_once("hyde-shell app -u " .. vars.unit .. "-notifications.service -t service -- dunst")
    exec_once("hyde-shell app -u " .. vars.unit .. "-notifications.service -t service -- swaync")
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

    exec_once("hyprctl setcursor " .. vars.CURSOR_THEME .. " " .. vars.CURSOR_SIZE)
    exec_once("hyde-shell app -u " .. vars.unit .. "-hyprexpose.service -t service -- hyprexpose")

    -- Personal autostart.
    exec_once("keepassxc --minimized")

    -- Directory setup and keybinds hint (from dynamic.lua)
    exec_once("mkdir -p " .. xdg_runtime .. "/hyde " .. xdg_cache .. "/hyde/wallbash " .. xdg_config .. "/hyde " .. xdg_data .. "/hyde " .. xdg_state .. "/hyde")
    exec_once("bash -c 'eval \"$(hyde-shell init)\" && " .. vars.scrPath .. "/hyde/keybinds/hint-hyprland.py --format rofi > " .. xdg_runtime .. "/hyde/keybinds_hint.rofi'")
end)
