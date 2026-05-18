--[[
# █░█ █▀ █▀▀ █▀█   █▀█ █▀█ █▀▀ █▀▀ █▀
# █▄█ ▄█ ██▄ █▀▄   █▀▀ █▀▄ ██▄ █▀░ ▄█

# Set your personal hyprland configuration here
# See https://wiki.hypr.land/Configuring for more information

# // █ █▄░█ █▀█ █░█ ▀█▀
# // █ █░▀█ █▀▀ █▄█ ░█░
]]

local vars = require("hyprland.hypr_vars")

-- Uncomment to enable // change to a preferred value
hl.config({
    -- Input variables: https://wiki.hypr.land/Configuring/Variables/#input
    input = {
        --follow_mouse = 1
        --sensitivity = 0
        --force_no_accel = 0
        --accel_profile = flat
        --numlock_by_default = true
        kb_layout = "es",
        -- ms to wait before a held key starts repeating.
        repeat_delay = 250,
        -- Repetitions per second while a key is held.
        repeat_rate = 40,
        -- Touchpad variables: https://wiki.hypr.land/Configuring/Variables/#touchpad
        touchpad = {
            natural_scroll = false,
        },
    },
    -- Do not show Hyprland update news on first launch.
    ecosystem = {
        -- no_update_news = true,
    },
    -- for window shallow similar to devour
    misc = {
        -- Ultrawide: single window at 1:1 ratio (width:height = 1:1)
        --single_window_aspect_ratio = "1 1",
        --single_window_aspect_ratio_tolerance = 0.1,

        -- for window shallow similar to devour
        -- enable_swallow = true
        -- swallow_regex = (foot|kitty|allacritty|Alacritty|ghostty|Ghostty|org.wezfurlong.wezterm)
    },

    --# 🔗 See https://wiki .hyprland.org/Configuring/Variables/#gestures
    --gestures {
    --    #     workspace_swipe = true
    --    #     workspace_swipe_fingers = 3
    --}
})

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("keepassxc --minimized")
end)

return vars
