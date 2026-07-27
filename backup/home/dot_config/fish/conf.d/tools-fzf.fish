#!/usr/bin/env fish

set -l fzf_functions_dir $HOME/.config/fish/functions/fzf
if test -d $fzf_functions_dir; and not contains -- $fzf_functions_dir $fish_function_path
    set -g fish_function_path $fzf_functions_dir $fish_function_path
end

if test -f "$HOME/.config/fzf/fzf-config.fish"
    source "$HOME/.config/fzf/fzf-config.fish"
end
