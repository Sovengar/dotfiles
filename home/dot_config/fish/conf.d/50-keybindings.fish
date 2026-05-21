function fish_user_key_bindings
    # History utils: ! and $ shortcuts
    if test "$fish_key_bindings" = fish_vi_key_bindings
        bind -M insert ! get_previous_command
        bind -M insert '$' get_previous_argument
    else
        bind ! get_previous_command
        bind '$' get_previous_argument
    end

    # Alt+number history
    bind_M_n_history

    # Fzf: *** → | fzf
    bind '*' fzf_expand_pipe_trigger
    bind -M insert '*' fzf_expand_pipe_trigger

    # Fzf: ** widget (alt-º)
    bind alt-º fzf_star_star_widget
    bind -M insert alt-º fzf_star_star_widget
end
