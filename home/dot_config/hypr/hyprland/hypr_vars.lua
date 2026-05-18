-- Default apps and modifiers shared by Hyprland modules.
-- mainMod is the Super/Meta/Windows key.

local vars = {
    mainMod = "SUPER",
    MOD = "SUPER",
    terminal = "hyde-shell app -T",
    editor = "hyde-shell open --fall code-oss text-editor",
    explorer = "hyde-shell open --fall dolphin file-manager",
    browser = "hyde-shell open --fall run-browser web-browser",
    lockscreen = "hyprlock",
    killactive = "hyprctl dispatch killactive \"\"",
}

return vars
