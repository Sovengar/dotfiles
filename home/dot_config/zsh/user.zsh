# Custom startup/config has been split into conf.d/NN-*.zsh files.
# Keep this file for HyDE-specific toggles loaded during HyDE initialization.

#   Overrides 
# HYDE_ZSH_NO_PLUGINS=1 # Set to 1 to disable loading of oh-my-zsh plugins, useful if you want to use your zsh plugins system 
# unset HYDE_ZSH_PROMPT # Uncomment to unset/disable loading of prompts from HyDE and let you load your own prompts
# HYDE_ZSH_COMPINIT_CHECK=1 # Set 24 (hours) per compinit security check // lessens startup time
# HYDE_ZSH_OMZ_DEFER=1 # Set to 1 to defer loading of oh-my-zsh plugins ONLY if prompt is already loaded

# cdx - interactive directory navigator wrapper
function cdx {
    local result_file=/tmp/cdx-rs-result.txt
    rm -f "$result_file"
    cdx-rs "$@" >/dev/null 2>&1
    if [[ $? -eq 0 && -f "$result_file" ]]; then
        local target=$(<"$result_file")
        target=${target%$'\n'}
        target=${target#$'\n'}
        rm -f "$result_file"
        if [[ -n "$target" && -d "$target" ]]; then
            builtin cd "$target"
            command eza --icons --group-directories-first 2>/dev/null || ls --color=auto
        fi
    fi
}

if [[ ${HYDE_ZSH_NO_PLUGINS} != "1" ]]; then
    #  OMZ Plugins 
    # manually add your oh-my-zsh plugins here
    plugins=(
        "sudo"
    )
fi
