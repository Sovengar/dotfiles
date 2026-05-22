local home = os.getenv("HOME") or ""
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local state_home = os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")
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

local function selected_workflow_name()
    local state = read_file(hyde_state_dir .. "/staterc")
    local from_state = state:match("%f[%w_]HYPR_WORKFLOW%f[^%w_]%s*=%s*\"?([^\"\r\n]+)\"?")
    if from_state and from_state ~= "" then
        local name = trim(from_state):gsub('^"', ""):gsub('"$', "")
        if name:match("^[%w_.%-]+$") then
            return name
        end
    end

    return "default"
end

local function apply_workflow(name)
    if name:find("/", 1, true) or name:find("\\", 1, true) then
        return false
    end

    local module = "workflows." .. name
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

apply_workflow(selected_workflow_name())
