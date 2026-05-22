local blur_override = require("hyprland.style.blur")
local fonts = require("hyprland.style.fonts")
local theme_state = require("hypr.scripts.generated_theme_loader")

local function copy_table(values)
    local copy = {}
    for key, value in pairs(values) do
        if key ~= "override_theme" then
            copy[key] = value
        end
    end
    return copy
end

local function selected_blur(theme_blur)
    if blur_override.override_theme then
        return copy_table(blur_override)
    end

    return theme_blur or copy_table(blur_override)
end

local theme = theme_state.theme or {}
local colors = theme_state.colors or {}
local general = theme.general or {}
local group = theme.group or {}
local decoration = theme.decoration or {}
local group_col = group.col or {}
local blur = selected_blur(decoration.blur)

hl.config({
    general = {
        gaps_in = general.gaps_in or 3,
        gaps_out = general.gaps_out or 8,
        border_size = general.border_size or 2,
        col = {
            active_border = general.active_border or { colors = { "rgba(eb6f92ff)", "rgba(c4a7e7ff)" }, angle = 45 },
            inactive_border = general.inactive_border or { colors = { "rgba(31748fcc)", "rgba(9ccfd8cc)" }, angle = 45 },
        },
        layout = general.layout or "dwindle",
        resize_on_border = general.resize_on_border,
    },

    group = {
        col = {
            border_active = group_col.border_active,
            border_inactive = group_col.border_inactive,
            border_locked_active = group_col.border_locked_active,
            border_locked_inactive = group_col.border_locked_inactive,
        },
        groupbar = {
            enabled = true,
            gradients = 1,
            render_titles = 1,
            col = {
                active = colors.wallbash_pry3 and ("rgba(" .. colors.wallbash_pry3 .. "ee)") or nil,
                inactive = colors.wallbash_pry1 and ("rgba(" .. colors.wallbash_pry1 .. "ee)") or nil,
                locked_active = colors.wallbash_pry2 and ("rgba(" .. colors.wallbash_pry2 .. "ee)") or nil,
                locked_inactive = colors.wallbash_pry4 and ("rgba(" .. colors.wallbash_pry4 .. "ee)") or nil,
            },
            text_color = colors.wallbash_txt3 and ("rgba(" .. colors.wallbash_txt3 .. "ee)") or nil,
            text_color_inactive = colors.wallbash_txt1 and ("rgba(" .. colors.wallbash_txt1 .. "ee)") or nil,
            blur = true,
        },
    },

    decoration = {
        rounding = decoration.rounding or 10,
        shadow = decoration.shadow,
        blur = blur,
    },
})
