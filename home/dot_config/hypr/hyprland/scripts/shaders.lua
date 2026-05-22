local state = require("hyprland.scripts.state")

local home = os.getenv("HOME") or ""
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")

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

local values = {}
for raw_line in read_file(state.existing_generated("shaders.conf")):gmatch("[^\r\n]+") do
    local line = strip_comment(raw_line)
    local key, value = line:match("^%$([%w_]+)%s*=%s*(.-)%s*$")
    if key and value then
        value = trim(value):gsub('^"', ""):gsub('"$', "")
        value = value:gsub("%$XDG_CONFIG_HOME", config_home)
        values[key] = value
    end
end

local shader = values.SCREEN_SHADER or "disable"
local compiled = values.SCREEN_SHADER_COMPILED or (config_home .. "/hypr/shaders/.compiled.cache.glsl")
local file = io.open(compiled, "r")
local compiled_exists = file ~= nil
if file then
    file:close()
end

return {
    shader = shader,
    compiled = compiled,
    enabled = shader ~= "disable" and compiled_exists,
}
