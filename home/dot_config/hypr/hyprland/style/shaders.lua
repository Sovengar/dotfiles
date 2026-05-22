local shader_state = require("hypr.scripts.shader_state_loader")

if shader_state.enabled then
    hl.config({
        decoration = {
            screen_shader = shader_state.compiled,
        },
    })
end
