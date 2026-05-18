local function portal_float(match, extra)
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
