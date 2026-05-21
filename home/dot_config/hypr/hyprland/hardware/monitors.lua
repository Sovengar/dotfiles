--[[
# █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█ █▀
# █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄ ▄█

# Set your monitor configuration here
# See https://wiki.hypr.land/Configuring/Monitors/
# For a sample file, please refer to https://github.com/prasanthrangan/hyprdots/blob/main/Configs/.config/hypr/monitors.t2
]]

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

hl.monitor({
    output = "DP-3",
    mode = "3440x1440@99.98",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-2",
    mode = "1920x1080@239.96",
    position = "760x-1080",
    scale = 1,
})
