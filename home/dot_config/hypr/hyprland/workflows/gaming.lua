-- @workflow_icon 
-- @workflow_description Emphasis on performance and disabling compositors expensive features

return {
    icon = "",
    description = "Emphasis on performance and disabling compositors expensive features",

    apply = function()
        hl.config({
            decoration = {
                shadow = {
                    enabled = false,
                },
                blur = {
                    enabled = false,
                    xray = true,
                },
                rounding = 0,
                active_opacity = 1,
                inactive_opacity = 1,
                fullscreen_opacity = 1,
            },
            general = {
                gaps_in = 0,
                gaps_out = 0,
                border_size = 1,
            },
            animations = {
                enabled = false,
            },
        })

        hl.window_rule({
            name = "workflow_windowrule_1",
            opaque = true,
            match = {
                class = ".*",
            },
        })

        hl.layer_rule({
            name = "workflows_gaming",
            blur = false,
            no_anim = true,
            match = {
                namespace = "^(rofi|notifications|swaync-(notification-window|control-center)|logout_dialog|waybar|.*www-daemon)$",
            },
        })
    end,
}
