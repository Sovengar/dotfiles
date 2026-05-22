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
