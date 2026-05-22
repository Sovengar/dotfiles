hl.config({
    decoration = {
        dim_special = 0.3,
        active_opacity = 0.90,
        inactive_opacity = 0.75,
        fullscreen_opacity = 1,
    },
})

local function opacity_rule(name, class, active, inactive, extra, fullscreen)
    local rule = {
        name = name,
        match = { class = class },
        opacity = string.format("%.2f override %.2f override %.2f override", active, inactive, fullscreen or 1),
        opaque = false,
    }

    if extra then
        for key, value in pairs(extra) do
            rule[key] = value
        end
    end

    hl.window_rule(rule)
end

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
