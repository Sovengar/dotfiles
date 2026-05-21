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

local function portal_float(match)
    hl.window_rule({
        name = "hyde_portal_dialogs_float",
        match = match,
        float = true,
    })
end

local function portal_center(match)
    hl.window_rule({
        name = "hyde_portal_dialogs_center",
        match = match,
        center = true,
    })
end

-- Infrastructure rules migrated from hyde/windowrules.lua.
portal_float({ tag = "portal-dialogs" })
portal_center({ tag = "portal-dialogs" })

hl.window_rule({
    name = "hyde_floating_apps",
    tag = "+hyde_floating_apps",
    match = { class = "^(blueman-manager|pavucontrol-qt|com\\.gabm\\.satty|vlc|kvantummanager|qt[56]ct|nwg-(look|displays)|org\\.kde\\.ark|org\\.pulseaudio\\.pavucontrol|blueman-manager|nm-(applet|connection-editor)|hyprpolkitagent|console-dropdown)$" },
})

hl.window_rule({
    name = "hyde_dolphin_popups",
    tag = "+hyde_floating_apps",
    match = {
        class = "^(org\\.kde\\.dolphin)$",
        title = "^(Progress Dialog — Dolphin|Copying — Dolphin)$",
    },
})

hl.window_rule({
    name = "hyde_common_popups",
    tag = "+hyde_common_popups",
    match = { title = "^(Choose Files|Save As|Confirm to replace files|File Operation Progress|Open|Authentication Required|Add Folder to Workspace|File Upload.*|Choose wallpaper.*|Library.*|.*dialog.*)$" },
})

hl.window_rule({
    name = "hyde_common_popups_initial",
    tag = "+hyde_common_popups",
    match = { initial_title = "^(Open File|Volume Control|Save As.*)$" },
})

hl.window_rule({
    name = "hyde_common_popups_class",
    tag = "+hyde_common_popups",
    match = { class = "^(.*dialog.*|[Xx]dg-desktop-portal-gtk)$" },
})

hl.window_rule({
    name = "hyde_portal_dialogs",
    tag = "+hyde_portal_dialogs",
    match = { class = "^(org\\.freedesktop\\.impl\\.portal\\.desktop\\.(hyprland|gtk)|[Xx]dg-desktop-portal-gtk)$" },
})

hl.window_rule({
    name = "hyde_picture_in_picture_tag_pip",
    tag = "+picture-in-picture",
    match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float = true,
    keep_aspect_ratio = true,
    move = { "monitor_w * 0.73", "monitor_h * 0.72" },
    size = { "monitor_w * 0.25", "monitor_h * 0.25" },
    pin = true,
})

hl.window_rule({
    name = "hyde_picture_in_picture_tag_hyde",
    tag = "+hyde_picture_in_picture",
    match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float = true,
    keep_aspect_ratio = true,
    move = { "monitor_w * 0.73", "monitor_h * 0.72" },
    size = { "monitor_w * 0.25", "monitor_h * 0.25" },
    pin = true,
})

hl.window_rule({
    name = "hyde_floating_apps_apply",
    match = { tag = "hyde_floating_apps" },
    float = true,
})

hl.window_rule({
    name = "hyde_common_popups_apply",
    match = { tag = "hyde_common_popups" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "hyde_portal_dialogs_apply",
    match = { tag = "hyde_portal_dialogs" },
    float = true,
    center = true,
})

hl.layer_rule({
    name = "hyde_layer_blur",
    match = { namespace = "^(rofi|notifications|swaync-(notification-window|control-center)|waybar|logout_dialog)$" },
    blur = true,
})

hl.layer_rule({
    name = "hyde_layer_ignore_alpha",
    match = { namespace = "^(rofi|notifications|swaync-(notification-window|control-center)|logout_dialog|waybar|selection)$" },
    ignore_alpha = true,
})

hl.layer_rule({
    name = "hyde_selection_no_anim",
    match = { namespace = "selection" },
    no_anim = true,
})

-- Idle-inhibit rules
window_rule("idle-inhibit-media", { class = "^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$" }, { idle_inhibit = "fullscreen" })
window_rule("idle-inhibit-spotify", { class = "^(.*[Ss]potify.*)$" }, { idle_inhibit = "fullscreen" })
window_rule("idle-inhibit-browsers", { class = "^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$" }, { idle_inhibit = "fullscreen" })

opacity_rule("opacity-firefox", "^(firefox)$", 0.90, 0.85)
opacity_rule("opacity-zen", "^(zen)$", 0.90, 0.85)
opacity_rule("opacity-brave", "^(brave-browser)$", 0.97, 0.90)
opacity_rule("opacity-code-oss", "^(code-oss)$", 0.80, 0.80)
opacity_rule("opacity-code", "^([Cc]ode)$", 0.80, 0.80)
opacity_rule("opacity-code-url-handler", "^(code-url-handler)$", 0.80, 0.80)
opacity_rule("opacity-code-insiders-url-handler", "^(code-insiders-url-handler)$", 0.80, 0.80)
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
