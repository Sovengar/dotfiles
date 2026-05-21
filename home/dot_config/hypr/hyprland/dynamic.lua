local home = os.getenv("HOME") or ""
local vars = require("hyprland.variables")

local xdg_config = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local xdg_cache = os.getenv("XDG_CACHE_HOME") or (home .. "/.cache")
local xdg_data = os.getenv("XDG_DATA_HOME") or (home .. "/.local/share")
local xdg_runtime = os.getenv("XDG_RUNTIME_DIR") or ("/run/user/" .. (os.getenv("UID") or "1000"))
local xdg_state = os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")

hl.config({
    misc = {
        font_family = vars.FONT,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("mkdir -p " .. xdg_runtime .. "/hyde " .. xdg_cache .. "/hyde/wallbash " .. xdg_config .. "/hyde " .. xdg_data .. "/hyde " .. xdg_state .. "/hyde")
    hl.exec_cmd("bash -c 'eval \"$(hyde-shell init)\" && " .. vars.scrPath .. "/hyde/keybinds/hint-hyprland.py --format rofi > " .. xdg_runtime .. "/hyde/keybinds_hint.rofi'")
end)
