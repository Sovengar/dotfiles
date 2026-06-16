local state = require("hypr.scripts.generated_paths")

local home = os.getenv("HOME") or ""
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local state_home = os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")
local animation_file = state_home .. "/hypr/animation.conf"
local animations_dir = config_home .. "/hypr/hyprland/style/animations"

local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        return ""
    end

    local content = file:read("*a")
    file:close()
    return content
end

local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function strip_comment(line)
    return trim(line:gsub("%s+#.*$", ""))
end

local function split_csv(value)
    local parts = {}
    for part in value:gmatch("[^,]+") do
        table.insert(parts, trim(part))
    end
    return parts
end

local function bool(value)
    value = tostring(value):lower()
    return value == "1" or value == "yes" or value == "true" or value == "on"
end

local function state_value(key)
    for raw_line in read_file(animation_file):gmatch("[^\r\n]+") do
        local line = strip_comment(raw_line)
        local value = line:match("^" .. key .. "%s*=%s*(.-)%s*$")
        if value then
            return trim(value):gsub('^"', ""):gsub('"$', ""):gsub("^'", ""):gsub("'$", "")
        end
    end
end

local function selected_animation()
    local animation = state_value("HYPR_ANIMATION") or "theme"
    if not animation:match("^[%w_.%-]+$") then
        return "theme"
    end
    return animation
end

local function active_animation_path()
    local animation = selected_animation()
    if animation == "theme" then
        return state.existing_generated("animations.theme.conf")
    end
    return animations_dir .. "/" .. animation .. ".conf"
end

local parsed = {
    curves = {},
    animations = {},
}

for raw_line in read_file(active_animation_path()):gmatch("[^\r\n]+") do
    local line = strip_comment(raw_line)

    local enabled = line:match("^enabled%s*=%s*(.+)$") or line:match("^animations:enabled%s*=%s*(.+)$")
    if enabled then
        parsed.enabled = bool(enabled)
    end

    local bezier = line:match("^bezier%s*=%s*(.+)$")
    if bezier then
        local parts = split_csv(bezier)
        table.insert(parsed.curves, {
            name = parts[1],
            points = {
                { tonumber(parts[2]), tonumber(parts[3]) },
                { tonumber(parts[4]), tonumber(parts[5]) },
            },
        })
    end

    local animation = line:match("^animation%s*=%s*(.+)$")
    if animation then
        local parts = split_csv(animation)
        table.insert(parsed.animations, {
            leaf = parts[1],
            enabled = bool(parts[2]),
            speed = tonumber(parts[3]),
            bezier = parts[4],
            style = parts[5],
        })
    end
end

return parsed
