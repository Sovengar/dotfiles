--[[
# █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
# ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█

# See https://wiki.hypr.land/Configuring/Window-Rules/
]]

local function window_rule(name, match, rule)
    rule.name = name
    rule.match = match
    hl.window_rule(rule)
end

local function opacity_rule(name, class, active, inactive, extra, fullscreen)
    local rule = {
        opacity = string.format("%.2f override %.2f override %.2f override", active, inactive, fullscreen or 1),
        opaque = false,
    }

    if extra then
        for key, value in pairs(extra) do
            rule[key] = value
        end
    end

    window_rule(name, { class = class }, rule)
end

local function float_rule(name, match)
    window_rule(name, match, { float = true })
end

-- Idle-inhibit rules
window_rule("idle-inhibit-media", { class = "^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$" }, { idle_inhibit = "fullscreen" })
window_rule("idle-inhibit-spotify", { class = "^(.*[Ss]potify.*)$" }, { idle_inhibit = "fullscreen" })
window_rule("idle-inhibit-browsers", { class = "^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$" }, { idle_inhibit = "fullscreen" })

-- Picture-in-Picture
local pictureInPictureMatch = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }
window_rule("hyde_picture_in_picture", pictureInPictureMatch, {
    float = true,
    keep_aspect_ratio = true,
    move = { "monitor_w * 0.73", "monitor_h * 0.72" },
    size = { "monitor_w * 0.25", "monitor_h * 0.25" },
    pin = true,
})
window_rule("hyde_picture_in_picture_tag_pip", pictureInPictureMatch, { tag = "+picture-in-picture" })
window_rule("hyde_picture_in_picture_tag_hyde", pictureInPictureMatch, { tag = "+hyde_picture_in_picture" })

opacity_rule("opacity-firefox", "^(firefox)$", 0.97, 0.90)
opacity_rule("opacity-zen", "^(zen)$", 0.80, 0.80, nil, 0.80)
opacity_rule("opacity-brave", "^(brave-browser)$", 0.97, 0.90)
opacity_rule("opacity-code-oss", "^(code-oss)$", 0.90, 0.85)
opacity_rule("opacity-code", "^([Cc]ode)$", 0.90, 0.85)
opacity_rule("opacity-code-url-handler", "^(code-url-handler)$", 0.90, 0.85)
opacity_rule("opacity-code-insiders-url-handler", "^(code-insiders-url-handler)$", 0.90, 0.85)
-- Keep compositor opacity near-solid; Kitty manages background transparency itself.
opacity_rule("opacity-kitty", "^(kitty)$", 0.99, 0.99, { opaque = false })
opacity_rule("opacity-dolphin", "^(org.kde.dolphin)$", 0.97, 0.80)
opacity_rule("opacity-ark", "^(org.kde.ark)$", 0.97, 0.80)
opacity_rule("opacity-nwg-look", "^(nwg-look)$", 0.97, 0.80)
opacity_rule("opacity-qt5ct", "^(qt5ct)$", 0.97, 0.80)
opacity_rule("opacity-qt6ct", "^(qt6ct)$", 0.97, 0.80)
opacity_rule("opacity-kvantummanager", "^(kvantummanager)$", 0.97, 0.80)
opacity_rule("opacity-pavucontrol", "^(org.pulseaudio.pavucontrol)$", 0.97, 0.70)
opacity_rule("opacity-blueman-manager", "^(blueman-manager)$", 0.97, 0.70)
opacity_rule("opacity-nm-applet", "^(nm-applet)$", 0.97, 0.70)
opacity_rule("opacity-nm-connection-editor", "^(nm-connection-editor)$", 0.97, 0.70)
opacity_rule("opacity-hyprpolkitagent", "^(hyprpolkitagent)$", 0.97, 0.70)
opacity_rule("opacity-portal-gtk", "^(org.freedesktop.impl.portal.desktop.gtk)$", 0.97, 0.70)
opacity_rule("opacity-portal-hyprland", "^(org.freedesktop.impl.portal.desktop.hyprland)$", 0.97, 0.70)
opacity_rule("opacity-steam", "^([Ss]team)$", 0.97, 0.70)
opacity_rule("opacity-steamwebhelper", "^(steamwebhelper)$", 0.97, 0.70)
opacity_rule("opacity-spotify", "^([Ss]potify)$", 0.97, 0.70)
opacity_rule("opacity-blender", "^(blender)$", 1.00, 1.00)

for _, spec in ipairs({
    { "clapper", "^(com.github.rafostar.Clapper)$" },
    { "flatseal", "^(com.github.tchx84.Flatseal)$" },
    { "cartridges", "^(hu.kramo.Cartridges)$" },
    { "obs", "^(com.obsproject.Studio)$" },
    { "boxes", "^(gnome-boxes)$" },
    { "vesktop", "^(vesktop)$" },
    { "discord", "^(discord)$" },
    { "webcord", "^(WebCord)$" },
    { "armcord", "^(ArmCord)$" },
    { "warp", "^(app.drey.Warp)$" },
    { "protonup", "^(net.davidotek.pupgui2)$" },
    { "protontricks", "^(yad)$" },
    { "signal", "^(Signal)$" },
    { "planify", "^(io.github.alainm23.planify)$" },
    { "upscaler", "^(io.gitlab.theevilskeleton.Upscaler)$" },
    { "video-downloader", "^(com.github.unrud.VideoDownloader)$" },
    { "impression", "^(io.gitlab.adhami3310.Impression)$" },
    { "mission-center", "^(io.missioncenter.MissionCenter)$" },
    { "warehouse", "^(io.github.flattool.Warehouse)$" },
}) do
    opacity_rule("opacity-" .. spec[1], spec[2], 0.97, 0.80)
end

for _, spec in ipairs({
    { "signal", { class = "^(Signal)$" } },
    { "clapper", { class = "^(com.github.rafostar.Clapper)$" } },
    { "warp", { class = "^(app.drey.Warp)$" } },
    { "protonup", { class = "^(net.davidotek.pupgui2)$" } },
    { "protontricks", { class = "^(yad)$" } },
    { "eog", { class = "^(eog)$" } },
    { "planify", { class = "^(io.github.alainm23.planify)$" } },
    { "upscaler", { class = "^(io.gitlab.theevilskeleton.Upscaler)$" } },
    { "video-downloader", { class = "^(com.github.unrud.VideoDownloader)$" } },
    { "impression", { class = "^(io.gitlab.adhami3310.Impression)$" } },
    { "mission-center", { class = "^(io.missioncenter.MissionCenter)$" } },
    { "steam-friends", { title = "^(Friends List)$" } },
    { "steam-settings", { title = "^(Steam Settings)$" } },
}) do
    float_rule("float-" .. spec[1], spec[2])
end

window_rule("blender-image-editor-float", { initial_title = "^(Image Editor)$", class = "^(blender)$" }, { float = true })
window_rule("blender-image-editor-size", { initial_title = "^(Image Editor)$", class = "^(blender)$" }, { size = { "monitor_w * 0.5", "monitor_h * 0.5" } })
-- Workaround for JetBrains IDE dropdowns/popups causing flickering.
window_rule("jetbrains-no-initial-focus", { class = "^(.*jetbrains.*)$", title = "^(win[0-9]+)$" }, { no_initial_focus = true })

--[[
# █░░ ▄▀█ █▄█ █▀▀ █▀█   █▀█ █░█ █░░ █▀▀ █▀
# █▄▄ █▀█ ░█░ ██▄ █▀▄   █▀▄ █▄█ █▄▄ ██▄ ▄█
]]
hl.layer_rule({ name = "rofi-blur", match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ name = "rofi-ignore-alpha", match = { namespace = "rofi" }, ignore_alpha = 0 })
hl.layer_rule({ name = "notifications-blur", match = { namespace = "notifications" }, blur = true })
hl.layer_rule({ name = "notifications-ignore-alpha", match = { namespace = "notifications" }, ignore_alpha = 0 })
hl.layer_rule({ name = "swaync-notification-blur", match = { namespace = "swaync-notification-window" }, blur = true })
hl.layer_rule({ name = "swaync-notification-ignore-alpha", match = { namespace = "swaync-notification-window" }, ignore_alpha = 0 })
hl.layer_rule({ name = "swaync-control-center-blur", match = { namespace = "swaync-control-center" }, blur = true })
hl.layer_rule({ name = "swaync-control-center-ignore-alpha", match = { namespace = "swaync-control-center" }, ignore_alpha = 0 })
hl.layer_rule({ name = "logout-dialog-blur", match = { namespace = "logout_dialog" }, blur = true })
