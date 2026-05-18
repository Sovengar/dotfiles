local home = os.getenv("HOME") or ""
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")

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

local function parse_theme(path)
    local sections = {}
    local stack = {}

    for raw_line in read_file(path):gmatch("[^\r\n]+") do
        local line = strip_comment(raw_line)
        if line ~= "" then
            local section = line:match("^([%w_:%.]+)%s*{%s*$")
            if section then
                local normalized = section:gsub(":", ".")
                table.insert(stack, normalized)
            elseif line == "}" then
                table.remove(stack)
            else
                local key, value = line:match("^([%w_:%.]+)%s*=%s*(.-)%s*$")
                if key and value then
                    local prefix = table.concat(stack, ".")
                    local normalized = key:gsub(":", ".")
                    local full_key = prefix ~= "" and (prefix .. "." .. normalized) or normalized
                    sections[full_key] = value
                end
            end
        end
    end

    return sections
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

local function bool(value)
    if value == nil then
        return nil
    end

    value = tostring(value):lower()
    return value == "yes" or value == "true" or value == "on" or value == "1"
end

local function num(value)
    return value and tonumber(value) or nil
end

local function gradient(value)
    if not value then
        return nil
    end

    local colors = {}
    for color in value:gmatch("rgba%([^%)]+%)") do
        table.insert(colors, color)
    end

    local angle = tonumber(value:match("(%-?%d+)deg"))
    if #colors > 0 then
        return { colors = colors, angle = angle }
    end

    return value
end

local theme = parse_theme(config_home .. "/hypr/themes/theme.conf")
local colors = parse_colors(config_home .. "/hypr/themes/colors.conf")

hl.config({
    general = {
        gaps_in = num(theme["general.gaps_in"]) or 3,
        gaps_out = num(theme["general.gaps_out"]) or 8,
        border_size = num(theme["general.border_size"]) or 2,
        col = {
            active_border = gradient(theme["general.col.active_border"]) or { colors = { "rgba(eb6f92ff)", "rgba(c4a7e7ff)" }, angle = 45 },
            inactive_border = gradient(theme["general.col.inactive_border"]) or { colors = { "rgba(31748fcc)", "rgba(9ccfd8cc)" }, angle = 45 },
        },
        layout = theme["general.layout"] or "dwindle",
        resize_on_border = bool(theme["general.resize_on_border"]),
    },

    group = {
        col = {
            border_active = gradient(theme["group.col.border_active"]),
            border_inactive = gradient(theme["group.col.border_inactive"]),
            border_locked_active = gradient(theme["group.col.border_locked_active"]),
            border_locked_inactive = gradient(theme["group.col.border_locked_inactive"]),
        },
        groupbar = {
            enabled = true,
            gradients = 1,
            render_titles = 1,
            font_weight_inactive = "normal",
            font_weight_active = "semibold",
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
        rounding = num(theme["decoration.rounding"]) or 10,
        shadow = {
            enabled = bool(theme["decoration.shadow.enabled"]),
        },
        blur = {
            enabled = bool(theme["decoration.blur.enabled"]),
            size = num(theme["decoration.blur.size"]) or 6,
            passes = num(theme["decoration.blur.passes"]) or 3,
            new_optimizations = bool(theme["decoration.blur.new_optimizations"]),
            ignore_opacity = bool(theme["decoration.blur.ignore_opacity"]),
            xray = bool(theme["decoration.blur.xray"]),
        },
    },

    misc = {
        font_family = "Cantarell",
    },
})
