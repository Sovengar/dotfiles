source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# User custom config (HyDE)
test -f $HOME/.config/fish/user.fish && source $HOME/.config/fish/user.fish

# Linuxbrew environment
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv fish | source
end

# mise (runtime version manager)
fish_add_path $HOME/.local/share/mise/shims
fish_add_path $HOME/go/bin

# cdx — interactive directory navigator wrapper
function cdx --wraps cdx-rs
    set -l result_file /tmp/cdx-rs-result.txt
    rm -f $result_file
    cdx-rs $argv >/dev/null 2>&1
    if test $status -eq 0 -a -f "$result_file"
        set -l target (string trim (cat $result_file))
        rm -f $result_file
        if test -n "$target" -a -d "$target"
            cd "$target"
            command eza --icons --group-directories-first 2>/dev/null; or ls --color=auto
        end
    end
end
