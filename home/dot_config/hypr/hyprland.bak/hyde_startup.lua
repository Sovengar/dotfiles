local function exec_once(command)
    hl.exec_cmd(command)
end

local session = os.getenv("XDG_SESSION_DESKTOP") or "Hyprland"
local unit = "hyde-" .. session
local env_list = "WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CONFIG_HOME QT_QPA_PLATFORMTHEME"

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})

hl.on("hyprland.start", function()
    exec_once("dbus-update-activation-environment --systemd --all")
    exec_once("dbus-update-activation-environment --systemd " .. env_list)
    exec_once("systemctl --user import-environment " .. env_list)
    exec_once("hyde-shell resetxdgportal.sh")
    exec_once("hyde-shell app -t service -- polkitkdeauth.sh")

    exec_once("hyde-shell app -u " .. unit .. "-bar.scope -t scope -- waybar.py --watch")
    exec_once("hyde-shell app -u " .. unit .. "-notifications.service -t service -- dunst")
    exec_once("hyde-shell app -u " .. unit .. "-wallpaper.service -t service -- wallpaper.sh --start --global")

    exec_once("hyde-shell app -u " .. unit .. "-text-clipboard.service -t service wl-paste --type text --watch cliphist store")
    exec_once("hyde-shell app -u " .. unit .. "-image-clipboard.service -t service wl-paste --type image --watch cliphist store")

    exec_once("hyde-shell app -u " .. unit .. "-network-manager-applet.service -t service -- nm-applet --indicator")
    exec_once("hyde-shell app -u " .. unit .. "-removable-media-applet.service -t service -- udiskie --no-automount --smart-tray")
    exec_once("hyde-shell app -u " .. unit .. "-bluetooth-applet.service -t service -- blueman-applet")
    exec_once("hyde-shell app -u " .. unit .. "-battery-notify.service -t service -- batterynotify.sh")

    exec_once("hyde-shell app -u " .. unit .. "-idle.service -t service -- hypridle")
    exec_once("hyde-shell app -u " .. unit .. "-blue-light-filter.service -t service -- hyprsunset")
    exec_once("hyde-shell app -t service hyde-config --no-startup")
    exec_once("hyprctl setcursor Bibata-Modern-Ice 24")
end)
