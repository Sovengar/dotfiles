# All key bindings consolidated.
# Vi key bindings — https://fishshell.com/docs/current/fish_vi_key_bindings.html

function accept_autosuggestion_or_complete
    if commandline --showing-suggestion
        commandline -f accept-autosuggestion
    else
        commandline -f complete
    end
end

function fish_user_key_bindings
    # jj → normal mode (faster than ESC, less conflict than jk)
    bind -M insert jj 'set fish_bind_mode default; commandline -f repaint'

    # History utils: ! and $ shortcuts
    bind -M insert ! get_previous_command
    bind -M insert '$' get_previous_argument

    # Fzf: *** → | fzf
    bind '*' fzf_expand_pipe_trigger
    bind -M insert '*' fzf_expand_pipe_trigger

    # Tab accepts autosuggestion; otherwise normal completion
    bind tab accept_autosuggestion_or_complete
    bind -M insert tab accept_autosuggestion_or_complete

    # Ctrl+↑/↓ → Inicio/fin de línea
    bind -M insert ctrl-up   beginning-of-line
    bind -M insert ctrl-down end-of-line

    # Fzf built-in key bindings
    if functions -q fzf_key_bindings
        fzf_key_bindings
        # Disable global Ctrl+T file picker: handled by Ctrl+F via fdx.
        bind --erase \ct 2>/dev/null
        bind --erase -M insert \ct 2>/dev/null
    end

    # fzf-git: Ctrl+G directly bound to each command
    if functions -q __fzf_git_sh
        bind -M default \cg\? '__fzf_git_list_bindings'
        bind -M insert  \cg\? '__fzf_git_list_bindings'
        set -l fzf_commands branches each_ref files hashes lreflogs remotes stashes tags worktrees
        for cmd in $fzf_commands
            set -l k (string sub --length=1 $cmd)
            bind -M default \cg$k   "__fzf_git_sh $cmd"
            bind -M insert  \cg$k   "__fzf_git_sh $cmd"
            eval "bind -M default \cg\c$k '__fzf_git_sh $cmd'"
            eval "bind -M insert  \cg\c$k '__fzf_git_sh $cmd'"
        end
    end

    # Ctrl+F → fdx file widget
    if functions -q fdx_file_widget
        bind \cf fdx_file_widget
        bind -M insert \cf fdx_file_widget
    end
end

# Enable vi mode (calls fish_user_key_bindings internally)
fish_vi_key_bindings

# Cursor shapes per mode
set -g fish_cursor_default block      blink
set -g fish_cursor_insert line        blink
set -g fish_cursor_replace_one       underline blink
set -g fish_cursor_visual            block

# No delay when leaving insert mode
set -g fish_escape_delay_ms 10
