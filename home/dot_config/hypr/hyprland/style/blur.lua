-- By default HyDE themes own decoration.blur.
local blur = {
    override_theme = true, -- Set override_theme = true to ignore the theme blur block and use this table instead.
    enabled = true,
    size = 25,
    passes = 4,
    contrast = 2,
    noise = 0.08,
    new_optimizations = true,
    ignore_opacity = true,
    xray = true,
}

--acrylic = { size = 0, passes = 4 }
--glass = { size = 3, passes = 4 }
--blurred = { size = 6, passes = 4 }
--Default = { size = 7, passes = 3 }
--Chromed = { size = 25, passes = 4 }

hl.layer_rule({
    name = "hyde_layer_blur",
    match = { namespace = "^(rofi|notifications|swaync-(notification-window|control-center)|waybar|logout_dialog)$" },
    blur = true,
})

return blur
