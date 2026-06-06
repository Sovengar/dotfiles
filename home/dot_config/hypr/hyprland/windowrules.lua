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

-- Idle-inhibit rules
window_rule("idle-inhibit-media", { class = "^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$" }, { idle_inhibit = "fullscreen" })
window_rule("idle-inhibit-spotify", { class = "^(.*[Ss]potify.*)$" }, { idle_inhibit = "fullscreen" })
window_rule("idle-inhibit-browsers", { class = "^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$" }, { idle_inhibit = "fullscreen" })


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
