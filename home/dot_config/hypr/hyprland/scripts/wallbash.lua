local state = require("hyprland.scripts.state")
local vars = require("hyprland.variables")

local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function strip_comment(line)
    return trim(line:gsub("%s+#.*$", ""))
end

local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        return ""
    end

    local content = file:read("*a")
    file:close()
    return content
end

local function literal(value, fallback)
    value = trim(value):gsub('^"', ""):gsub('"$', "")
    if value == "" or value:match("^%$") then
        return fallback
    end
    return value
end

local function apply_var(key, value)
    local normalized = key:gsub("_", "-"):lower()
    if normalized == "hyde-theme" then vars.HYDE_THEME = literal(value, vars.HYDE_THEME) end
    if normalized == "gtk-theme" then vars.GTK_THEME = literal(value, vars.GTK_THEME) end
    if normalized == "icon-theme" then vars.ICON_THEME = literal(value, vars.ICON_THEME) end
    if normalized == "color-scheme" then vars.COLOR_SCHEME = literal(value, vars.COLOR_SCHEME) end
    if normalized == "cursor-theme" then vars.CURSOR_THEME = literal(value, vars.CURSOR_THEME) end
    if normalized == "cursor-size" then vars.CURSOR_SIZE = tonumber(literal(value, tostring(vars.CURSOR_SIZE))) or vars.CURSOR_SIZE end
    if normalized == "font" then vars.FONT = literal(value, vars.FONT) end
    if normalized == "font-size" then vars.FONT_SIZE = tonumber(literal(value, tostring(vars.FONT_SIZE))) or vars.FONT_SIZE end
    if normalized == "document-font" then vars.DOCUMENT_FONT = literal(value, vars.DOCUMENT_FONT) end
    if normalized == "document-font-size" then vars.DOCUMENT_FONT_SIZE = tonumber(literal(value, tostring(vars.DOCUMENT_FONT_SIZE))) or vars.DOCUMENT_FONT_SIZE end
    if normalized == "monospace-font" then vars.MONOSPACE_FONT = literal(value, vars.MONOSPACE_FONT) end
    if normalized == "monospace-font-size" then vars.MONOSPACE_FONT_SIZE = tonumber(literal(value, tostring(vars.MONOSPACE_FONT_SIZE))) or vars.MONOSPACE_FONT_SIZE end
    if normalized == "code-theme" then vars.CODE_THEME = literal(value, vars.CODE_THEME) end
    if normalized == "sddm-theme" then vars.SDDM_THEME = literal(value, vars.SDDM_THEME) end
end

for raw_line in read_file(state.existing_generated("wallbash.conf")):gmatch("[^\r\n]+") do
    local line = strip_comment(raw_line)
    local key, value = line:match("^%$([%w_%-]+)%s*=%s*(.-)%s*$")
    if key and value then
        apply_var(key, value)
    end
end

return vars
