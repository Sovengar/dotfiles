-- @workflow_icon 󰓅
-- @workflow_description Snappy desktop

return {
    icon = "󰓅",
    description = "Snappy desktop",

    apply = function()
        hl.config({
            decoration = {
                rounding = 0,
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
    end,
}
