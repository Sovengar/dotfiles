-- @workflow_icon 
-- @workflow_description Best for writing and editing // Disables xray and blur that might affect color picking/contrast

return {
    icon = "",
    description = "Best for writing and editing // Disables xray and blur that might affect color picking/contrast",

    apply = function()
        hl.config({
            decoration = {
                blur = {
                    enabled = true,
                },
                active_opacity = 1,
                inactive_opacity = 1,
                fullscreen_opacity = 1,
            },
        })

        hl.layer_rule({
            name = "workflows_editing",
            blur = true,
            match = {
                namespace = "^(rofi|notifications|swaync-(notification-window|control-center)|logout_dialog|waybar)$",
            },
        })
    end,
}
