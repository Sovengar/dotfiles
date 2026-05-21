local home = os.getenv("HOME") or ""
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local state_home = os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")
local base_dir = config_home .. "/hypr/hyprland"
local hyde_state_dir = state_home .. "/hyde"

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

local function scalar(value)
    value = trim(value)
    local lowered = value:lower()
    if lowered == "yes" or lowered == "true" or lowered == "on" or lowered == "1" then
        return true
    end
    if lowered == "no" or lowered == "false" or lowered == "off" or lowered == "0" then
        return false
    end
    return tonumber(value) or value
end

local function set_path(root, path, value)
    local current = root
    local segments = {}

    for segment in path:gsub(":", "."):gmatch("[^%.]+") do
        table.insert(segments, segment)
    end

    for index, segment in ipairs(segments) do
        if index == #segments then
            current[segment] = value
        else
            current[segment] = current[segment] or {}
            current = current[segment]
        end
    end
end

local function split_csv(value)
    local parts = {}
    for part in value:gmatch("[^,]+") do
        table.insert(parts, trim(part))
    end
    return parts
end

local function selected_workflow_name()
    local state = read_file(hyde_state_dir .. "/staterc")
    local from_state = state:match("[%f[%w_]HYPR_WORKFLOW%s*=%s*\"?([^\"\r\n]+)\"?")
    if from_state and from_state ~= "" then
        return trim(from_state)
    end

    local conf = read_file(base_dir .. "/workflows.conf")
    local from_conf = conf:match("$WORKFLOW%s*=%s*([^\r\n]+)")
    if from_conf and from_conf ~= "" then
        return trim(from_conf):gsub('^"', ""):gsub('"$', "")
    end

    return "default"
end

local function apply_lua_workflow(name)
    if name:find("/", 1, true) or name:find("\\", 1, true) then
        return false
    end

    local module = "hyprland.workflows." .. name
    package.loaded[module] = nil

    local ok, workflow = pcall(require, module)
    if not ok then
        return false
    end

    if type(workflow) == "function" then
        workflow()
        return true
    end

    if type(workflow) == "table" and type(workflow.apply) == "function" then
        workflow.apply()
        return true
    end

    return true
end

local function parse_window_rule(value, index)
    local rule = { name = "workflow_windowrule_" .. index }
    local match = {}

    for _, part in ipairs(split_csv(value)) do
        local match_key, match_value = part:match("^match:([%w_]+)%s+(.+)$")
        if match_key then
            match[match_key] = match_value
        else
            local key, raw_value = part:match("^([%w_]+)%s+(.+)$")
            if key then
                rule[key] = scalar(raw_value)
            end
        end
    end

    rule.match = match
    hl.window_rule(rule)
end

local function apply_layer_rule(rule)
    if rule.name and rule.match and rule.match.namespace then
        hl.layer_rule(rule)
    end
end

local function active_workflow_path()
    local conf = read_file(base_dir .. "/workflows.conf")
    local path = conf:match("$WORKFLOWS_PATH%s*=%s*([^\r\n]+)") or "./workflows/default.conf"
    path = trim(path):gsub('^"', ""):gsub('"$', "")
    return path:gsub("^%./", base_dir .. "/")
end

if apply_lua_workflow(selected_workflow_name()) then
    return
end

local config = {}
local stack = {}
local layer_rule = nil
local window_rule_count = 0

for raw_line in read_file(active_workflow_path()):gmatch("[^\r\n]+") do
    local line = strip_comment(raw_line)

    if line ~= "" and not line:match("^%$") then
        local block = line:match("^([%w_:%.]+)%s*{%s*$")
        if block then
            if block == "layerrule" then
                layer_rule = { match = {} }
            else
                local normalized = block:gsub(":", ".")
                table.insert(stack, normalized)
            end
        elseif line == "}" then
            if layer_rule then
                apply_layer_rule(layer_rule)
                layer_rule = nil
            else
                table.remove(stack)
            end
        else
            local window_rule = line:match("^windowrule%s*=%s*(.+)$")
            if window_rule then
                window_rule_count = window_rule_count + 1
                parse_window_rule(window_rule, window_rule_count)
            else
                local key, value = line:match("^([%w_:%.]+)%s*=%s*(.-)%s*$")
                if key and value then
                    if layer_rule then
                        local normalized = key:gsub(":", ".")
                        key = normalized
                        if key == "match.namespace" then
                            layer_rule.match.namespace = value
                        else
                            layer_rule[key] = scalar(value)
                        end
                    else
                        local prefix = table.concat(stack, ".")
                        local full_key = prefix ~= "" and (prefix .. "." .. key) or key
                        set_path(config, full_key, scalar(value))
                    end
                end
            end
        end
    end
end

if next(config) then
    hl.config(config)
end
