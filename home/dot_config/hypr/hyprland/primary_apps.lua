-- Primary apps used by launch keybindings and HyDE metadata.

local apps = {
    terminal = "hyde-shell app -T",
    editor = "hyde-shell open --fall code-oss text-editor",
    explorer = "hyde-shell open --fall dolphin file-manager",
    browser = "hyde-shell open --fall run-browser web-browser",
}

apps.TERMINAL = apps.terminal
apps.EDITOR = apps.editor
apps.EXPLORER = apps.explorer
apps.BROWSER = apps.browser

return apps
