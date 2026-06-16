hl.config({
    decoration = {
        dim_special = 0.3,
        active_opacity = 0.96,
        inactive_opacity = 0.96,
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



-- FILE MANAGERS
opacity_rule("opacity-dolphin", "^(org.kde.dolphin)$", 0.90, 0.90)
opacity_rule("opacity-nautilus", "^(org.gnome.Nautilus|nautilus)$", 0.90, 0.90)

-- TERMINALS
-- Keep compositor opacity near-solid; terminals manages background transparency itself.
opacity_rule("opacity-kitty", "^(kitty)$", 0.99, 0.99, { opaque = false })
opacity_rule("opacity-wezterm", "^(org.wezfurlong.wezterm|wezterm)$", 0.99, 0.99, { opaque = false })

-- WEB BROWSERS
opacity_rule("opacity-firefox", "^(firefox)$", 0.90, 0.85)
opacity_rule("opacity-zen", "^(zen)$", 0.95, 0.95)
opacity_rule("opacity-brave", "^(brave-browser)$", 0.97, 0.90)

-- IDEs / CODE EDITORS
opacity_rule("opacity-code-oss", "^(code-oss)$", 0.80, 0.80)
opacity_rule("opacity-code", "^([Cc]ode)$", 0.80, 0.80)
opacity_rule("opacity-code-url-handler", "^(code-url-handler)$", 0.80, 0.80)
opacity_rule("opacity-code-insiders-url-handler", "^(code-insiders-url-handler)$", 0.80, 0.80)

-- KDE/QT TOOLS
opacity_rule("opacity-ark", "^(org.kde.ark)$", 0.97, 0.80)
opacity_rule("opacity-nwg-look", "^(nwg-look)$", 0.97, 0.80)
opacity_rule("opacity-qt5ct", "^(qt5ct)$", 0.97, 0.80)
opacity_rule("opacity-qt6ct", "^(qt6ct)$", 0.97, 0.80)
opacity_rule("opacity-kvantummanager", "^(kvantummanager)$", 0.97, 0.80)

-- SYSTEM UTILITIES
opacity_rule("opacity-pavucontrol", "^(org.pulseaudio.pavucontrol)$", 0.97, 0.70)
opacity_rule("opacity-blueman-manager", "^(blueman-manager)$", 0.97, 0.70)
opacity_rule("opacity-nm-applet", "^(nm-applet)$", 0.97, 0.70)
opacity_rule("opacity-nm-connection-editor", "^(nm-connection-editor)$", 0.97, 0.70)
opacity_rule("opacity-hyprpolkitagent", "^(hyprpolkitagent)$", 0.97, 0.70)
opacity_rule("opacity-portal-gtk", "^(org.freedesktop.impl.portal.desktop.gtk)$", 0.97, 0.70)
opacity_rule("opacity-portal-hyprland", "^(org.freedesktop.impl.portal.desktop.hyprland)$", 0.97, 0.70)

-- COMMUNICATION
opacity_rule("opacity-vesktop", "^(vesktop)$", 0.97, 0.80)
opacity_rule("opacity-discord", "^(discord)$", 0.97, 0.80)
opacity_rule("opacity-webcord", "^(WebCord)$", 0.97, 0.80)
opacity_rule("opacity-armcord", "^(ArmCord)$", 0.97, 0.80)
opacity_rule("opacity-signal", "^(Signal)$", 0.97, 0.80)
opacity_rule("opacity-warp", "^(app.drey.Warp)$", 0.97, 0.80)

-- MEDIA
opacity_rule("opacity-spotify", "^([Ss]potify)$", 0.97, 0.70)
opacity_rule("opacity-blender", "^(blender)$", 1.00, 1.00)
opacity_rule("opacity-clapper", "^(com.github.rafostar.Clapper)$", 0.97, 0.80)
opacity_rule("opacity-obs", "^(com.obsproject.Studio)$", 0.97, 0.80)
opacity_rule("opacity-upscaler", "^(io.gitlab.theevilskeleton.Upscaler)$", 0.97, 0.80)
opacity_rule("opacity-video-downloader", "^(com.github.unrud.VideoDownloader)$", 0.97, 0.80)

-- GAMING
opacity_rule("opacity-steam", "^([Ss]team)$", 0.97, 0.70)
opacity_rule("opacity-steamwebhelper", "^(steamwebhelper)$", 0.97, 0.70)
opacity_rule("opacity-protonup", "^(net.davidotek.pupgui2)$", 0.97, 0.80)
opacity_rule("opacity-protontricks", "^(yad)$", 0.97, 0.80)

-- UTILITIES / FLATPAK
opacity_rule("opacity-flatseal", "^(com.github.tchx84.Flatseal)$", 0.97, 0.80)
opacity_rule("opacity-cartridges", "^(hu.kramo.Cartridges)$", 0.97, 0.80)
opacity_rule("opacity-boxes", "^(gnome-boxes)$", 0.97, 0.80)
opacity_rule("opacity-planify", "^(io.github.alainm23.planify)$", 0.97, 0.80)
opacity_rule("opacity-impression", "^(io.gitlab.adhami3310.Impression)$", 0.97, 0.80)
opacity_rule("opacity-mission-center", "^(io.missioncenter.MissionCenter)$", 0.97, 0.80)
opacity_rule("opacity-warehouse", "^(io.github.flattool.Warehouse)$", 0.97, 0.80)
