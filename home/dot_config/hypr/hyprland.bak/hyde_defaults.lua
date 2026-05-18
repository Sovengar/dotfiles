hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

hl.config({
    decoration = {
        dim_special = 0.3,
        active_opacity = 0.97,
        inactive_opacity = 0.82,
        fullscreen_opacity = 1,
        blur = {
            special = true,
        },
    },

    input = {
        accel_profile = "flat",
        numlock_by_default = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        vrr = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        anr_missed_pings = 5,
        allow_session_lock_restore = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        snap = {
            enabled = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
