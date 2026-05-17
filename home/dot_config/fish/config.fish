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
    set result_file /tmp/cdx-rs-result.txt
    rm -f $result_file
    cdx-rs $argv 2>/dev/null
    and test -f $result_file
    and set target (string trim (cat $result_file))
    and rm -f $result_file
    and test -n "$target"
    and test -d "$target"
    and cd "$target"
end
