local state = require("hyprland.scripts.state")

local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        return ""
    end

    local content = file:read("*a")
    file:close()
    return content
end

local function strip_comment(line)
    return (line:gsub("%s+#.*$", "")):gsub("^%s+", ""):gsub("%s+$", "")
end

local function parse_colors(path)
    local colors = {}

    for raw_line in read_file(path):gmatch("[^\r\n]+") do
        local line = strip_comment(raw_line)
        local key, value = line:match("^%$([%w_]+)%s*=%s*([%x]+)%s*$")
        if key and value then
            colors[key] = value
        end
    end

    return colors
end

local function load_theme(path)
    local ok, theme = pcall(dofile, path)
    if ok and type(theme) == "table" then
        return theme
    end

    return {}
end

return {
    theme = load_theme(state.existing_generated("hyprland.theme.lua")),
    colors = parse_colors(state.existing_generated("colors.conf")),
}
