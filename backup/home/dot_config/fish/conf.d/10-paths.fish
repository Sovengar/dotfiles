#!/usr/bin/env fish

fish_add_path --global --move $HOME/.local/bin

if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv fish | source
end

fish_add_path $HOME/.local/share/mise/shims
fish_add_path $HOME/.local/share/mise/installs/python/3.12.13/bin
fish_add_path $HOME/go/bin
fish_add_path $HOME/.cargo/bin

if test -d $HOME/Applications/depot_tools
    fish_add_path --global --move $HOME/Applications/depot_tools
end
