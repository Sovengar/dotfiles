local shader_state = require("hyprland.scripts.shaders")

if shader_state.enabled then
    hl.config({
        decoration = {
            screen_shader = shader_state.compiled,
        },
    })
end
