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

local function bool(value)
    value = trim(tostring(value)):lower()
    return value == "1" or value == "yes" or value == "true" or value == "on"
end

local cursor = {}

for raw_line in read_file(config_home .. "/hypr/nvidia.conf"):gmatch("[^\r\n]+") do
    local line = strip_comment(raw_line)

    local key, value = line:match("^env%s*=%s*([%w_]+)%s*,%s*(.-)%s*$")
    if key and value and value ~= "" then
        hl.env(key, value)
    end

    local cursor_key, cursor_value = line:match("^cursor:([%w_]+)%s*=%s*(.-)%s*$")
    if cursor_key == "no_hardware_cursors" or cursor_key == "use_cpu_buffer" then
        cursor[cursor_key] = bool(cursor_value)
    end
end

if next(cursor) then
    hl.config({ cursor = cursor })
end
