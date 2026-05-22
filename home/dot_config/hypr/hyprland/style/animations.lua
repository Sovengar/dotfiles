local animation_state = require("hyprland.scripts.animations")

if animation_state.enabled ~= nil then
    hl.config({ animations = { enabled = animation_state.enabled } })
end

for _, curve in ipairs(animation_state.curves or {}) do
    hl.curve(curve.name, {
        type = "bezier",
        points = curve.points,
    })
end

for _, animation in ipairs(animation_state.animations or {}) do
    hl.animation(animation)
end
