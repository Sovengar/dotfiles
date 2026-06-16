--[[
## █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
## █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█

# see https://wiki.hypr.land/configuring/keywords/ for more
# example binds, see https://wiki.hypr.land/configuring/binds/ for more

#? ------- Grouping of binds for easier management ----------------
#  $d=[Group Name|Subgroup Name1|Subgroup Name2|...]
# '$d' is a variable that is used to group binds together (or use another variable)
# This is only for organization purposes and is not a defined hyprland variable
# What we did here is to modify the Description of the binds to include the group name
# The $d will be parsed as a separate key to be use for a GUI or something pretty
# [Main|Subgroup1|Subgroup2|...]
# Main - The main groupname
# Subgroup1.. - The subgroup names can be use to avoid repeating the same description
]]

local mainMod = "SUPER"

local function exec(keys, command, description, opts)
    opts = opts or {}
    opts.description = description
    hl.bind(keys, hl.dsp.exec_cmd(command), opts)
end

local function bind(keys, dispatcher, description, opts)
    opts = opts or {}
    opts.description = description
    hl.bind(keys, dispatcher, opts)
end

-- Window Management
bind(mainMod .. " + Backspace", hl.dsp.window.close(), "Close focused window")
exec(mainMod .. " + Delete", "hyde-shell logout", "Kill Hyprland session")
bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
exec(mainMod .. " + SHIFT + F", "hyde-shell window.pin", "Toggle pin on focused window")
exec("CONTROL + ALT + Delete", "hyde-shell logoutlaunch", "Logout menu")
exec(mainMod .. " + CONTROL + H", "hyprctl dispatch changegroupactive b", "Previous group")
exec(mainMod .. " + CONTROL + L", "hyprctl dispatch changegroupactive f", "Next group")

-- Window Management / Change focus
bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }), "Focus left")
bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }), "Focus right")
bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }), "Focus up")
bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }), "Focus down")

-- Window Management / Resize Active Window
bind(mainMod .. " + SHIFT + Right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), "Resize window right", { repeating = true })
bind(mainMod .. " + SHIFT + Left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), "Resize window left", { repeating = true })
bind(mainMod .. " + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), "Resize window up", { repeating = true })
bind(mainMod .. " + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), "Resize window down", { repeating = true })

-- Window Management / Move active window (swap in dwindle, move in floating)
local function move_window(dx, dy, dir)
    return function()
        local win = hl.get_active_window()
        if win and win.floating then
            hl.dispatch(hl.dsp.window.move({ x = dx, y = dy }))
        else
            hl.dispatch(hl.dsp.window.move({ direction = dir }))
        end
    end
end
bind(mainMod .. " + ALT + Left", move_window(-30, 0, "l"), "Move window left", { repeating = true })
bind(mainMod .. " + ALT + Right", move_window(30, 0, "r"), "Move window right", { repeating = true })
bind(mainMod .. " + ALT + Up", move_window(0, -30, "u"), "Move window up", { repeating = true })
bind(mainMod .. " + ALT + Down", move_window(0, 30, "d"), "Move window down", { repeating = true })

-- Window Management / Move and Resize with mouse
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), "Drag window", { mouse = true })
local function float_and_resize()
    local win = hl.get_active_window()
    if win and not win.floating then
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    end
    hl.dispatch(hl.dsp.window.resize())
end
bind(mainMod .. " + mouse:273", float_and_resize, "Float and resize window", { mouse = true })
bind(mainMod .. " + Z", hl.dsp.window.fullscreen(), "Toggle fullscreen")
bind(mainMod .. " + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }), "Universal cut")
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), "Toggle split")

-- Launcher / Apps
exec(mainMod .. " + Return", "sh -lc 'exec \"${TERMINAL:-wezterm}\"'", "Open terminal")
exec(mainMod .. " + ALT + Return", "hyde-shell pypr toggle console", "Open dropdown terminal")
exec(mainMod .. " + E", "sh -lc 'exec hyde-shell open --fall \"${EXPLORER:-dolphin}\" file-manager'", "Open file explorer")
exec(mainMod .. " + Y", "sh -lc 'exec \"${TERMINAL:-wezterm}\" -e yazi'", "Open yazi file manager")
exec(mainMod .. " + T", "sh -lc 'exec hyde-shell open --fall \"${EDITOR:-code-oss}\" text-editor'", "Open text editor")
exec(mainMod .. " + B", "sh -lc 'exec hyde-shell open --fall \"${BROWSER:-zen-browser}\" web-browser'", "Open browser")
exec("CONTROL + SHIFT + Escape", "hyde-shell system.monitor", "Open system monitor")

-- Launcher / Rofi menus
local rofiLaunch = "hyde-shell rofilaunch"
exec(mainMod .. " + A", "pkill -x rofi || " .. rofiLaunch .. " d", "Application finder")
exec(mainMod .. " + TAB", "pkill -x rofi || " .. rofiLaunch .. " w", "Window switcher")
exec(mainMod .. " + SHIFT + E", "pkill -x rofi || " .. rofiLaunch .. " f", "File finder")
exec(mainMod .. " + SHIFT + A", "pkill -x rofi || hyde-shell rofiselect", "Select rofi launcher")
exec(mainMod .. " + slash", "pkill -x rofi || hyde-shell keybinds_hint c", "Keybindings hint")
exec(mainMod .. " + comma", "pkill -x rofi || hyde-shell emoji-picker", "Emoji picker")
exec(mainMod .. " + period", "pkill -x rofi || hyde-shell glyph-picker", "Glyph picker")

-- Clipboard
bind(mainMod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }), "Universal copy")
bind(mainMod .. " + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }), "Universal paste")
bind(mainMod .. " + SHIFT + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }), "Universal cut")
bind(mainMod .. " + SHIFT + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "C" }), "Copy GUI apps")
bind(mainMod .. " + SHIFT + V", hl.dsp.send_shortcut({ mods = "CTRL", key = "V" }), "Paste GUI apps")
bind(mainMod .. " + SHIFT + Insert", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }), "Paste primary selection")
exec(mainMod .. " + CONTROL + V", "pkill -x rofi || hyde-shell cliphist -c", "Clipboard")
exec(mainMod .. " + SHIFT + V", "pkill -x rofi || hyde-shell cliphist", "Clipboard manager")

-- Hardware Controls / Audio and Media
exec("F10", "hyde-shell volumecontrol -o m", "Toggle mute output", { locked = true })
exec("XF86AudioMute", "hyde-shell volumecontrol -o m", "Toggle mute output", { locked = true })
exec("F11", "hyde-shell volumecontrol -o d", "Decrease volume", { locked = true, repeating = true })
exec("F12", "hyde-shell volumecontrol -o i", "Increase volume", { locked = true, repeating = true })
exec("XF86AudioMicMute", "hyde-shell volumecontrol -i m", "Toggle microphone mute", { locked = true })
exec("XF86AudioLowerVolume", "hyde-shell volumecontrol -o d", "Decrease volume", { locked = true, repeating = true })
exec("XF86AudioRaiseVolume", "hyde-shell volumecontrol -o i", "Increase volume", { locked = true, repeating = true })
exec("XF86AudioPlay", "playerctl play-pause", "Play media", { locked = true })
exec("XF86AudioPause", "playerctl play-pause", "Pause media", { locked = true })
exec("XF86AudioNext", "playerctl next", "Next media", { locked = true })
exec("XF86AudioPrev", "playerctl previous", "Previous media", { locked = true })
exec(mainMod .. " + CONTROL + M", "hyde-shell window.mute", "Toggle active window mute")
exec("XF86MonBrightnessUp", "hyde-shell brightnesscontrol i", "Increase brightness", { locked = true, repeating = true })
exec("XF86MonBrightnessDown", "hyde-shell brightnesscontrol d", "Decrease brightness", { locked = true, repeating = true })

-- Utilities
exec(mainMod .. " + K", "pkill -x rofi || hyde-shell keybinds_hint c", "Keybindings hint")
exec(mainMod .. " + ALT + G", "hyde-shell gamemode", "Game mode")
exec(mainMod .. " + SHIFT + G", "hyde-shell gamelauncher", "Open game launcher")
exec(mainMod .. " + SHIFT + P", "hyprpicker -an", "Color picker")
exec("Print", "grim -g \"$(slurp)\" - | swappy -f -", "Snip screen")
exec(mainMod .. " + CONTROL + P", "hyde-shell screenshot sf", "Freeze and snip screen")
exec(mainMod .. " + ALT + P", "hyde-shell screenshot m", "Print monitor", { locked = true })
exec(mainMod .. " + P", "hyde-shell screenshot p", "Print all monitors", { locked = true })

-- Theming and Wallpaper
exec(mainMod .. " + SHIFT + CONTROL + Right", "hyde-shell wallpaper -Gn", "Next global wallpaper")
exec(mainMod .. " + SHIFT + CONTROL + Left", "hyde-shell wallpaper -Gp", "Previous global wallpaper")
exec(mainMod .. " + SHIFT + W", "pkill -x rofi || hyde-shell wallpaper -SG", "Select global wallpaper")
exec(mainMod .. " + SHIFT + CONTROL + Up", "hyde-shell wbarconfgen n", "Next waybar layout")
exec(mainMod .. " + SHIFT + CONTROL + Down", "hyde-shell wbarconfgen p", "Previous waybar layout")
exec(mainMod .. " + SHIFT + R", "pkill -x rofi || hyde-shell wallbashtoggle -m", "Wallbash mode selector")
exec(mainMod .. " + SHIFT + T", "pkill -x rofi || hyde-shell themeselect", "Select theme")
exec(mainMod .. " + SHIFT + Y", "pkill -x rofi || hyde-shell animations --select", "Select animations")
exec(mainMod .. " + SHIFT + U", "pkill -x rofi || hyde-shell hyprlock --select", "Select hyprlock layout")

-- Workspaces / Navigation
for i = 1, 9 do
    bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }), "Go to workspace " .. i)
    bind(mainMod .. " + F" .. i, hl.dsp.window.move({ workspace = i }), "Move to workspace " .. i)
    exec(mainMod .. " + ALT + " .. i, "hyprctl dispatch movetoworkspacesilent " .. i, "Move to workspace " .. i .. " (silent)")
end

-- Workspace 10
bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }), "Go to workspace 10")
bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }), "Move to workspace 10")
exec(mainMod .. " + ALT + 0", "hyprctl dispatch movetoworkspacesilent 10", "Move to workspace 10 (silent)")

bind(mainMod .. " + CONTROL + Right", hl.dsp.focus({ workspace = "r+1" }), "Next relative workspace")
bind(mainMod .. " + CONTROL + Left", hl.dsp.focus({ workspace = "r-1" }), "Previous relative workspace")
bind(mainMod .. " + CONTROL + Down", hl.dsp.focus({ workspace = "empty" }), "Nearest empty workspace")
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")
bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), "Move to scratchpad")
bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"), "Toggle scratchpad")
bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic", silent = true }), "Move to scratchpad (silent)")
exec(mainMod .. " + CONTROL + ALT + Right", "hyprctl dispatch movetoworkspace r+1", "Move window to next workspace")
exec(mainMod .. " + CONTROL + ALT + Left", "hyprctl dispatch movetoworkspace r-1", "Move window to previous workspace")

exec(mainMod .. " + F10", "pkill -SIGUSR1 hyprexpose", "Workspace overview")
exec(mainMod .. " + XF86AudioMute", "pkill -SIGUSR1 hyprexpose", "Workspace overview")
exec(mainMod .. " + G", "pypr toggle lazygit", "LazyGit")
exec(mainMod .. " + D", "pypr toggle lazydocker", "LazyDocker")
exec(mainMod .. " + W", "pypr toggle ai-assistant", "AI assistant (ChatGPT + Gemini + Claude + Arena)")
