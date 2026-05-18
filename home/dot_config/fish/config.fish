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

# OpenCode Go quota (opencode-quota plugin)
set -gx OPENCODE_GO_WORKSPACE_ID "wrk_01KPRTA44GVQD63142WX91W7XK"
set -gx OPENCODE_GO_AUTH_COOKIE "Fe26.2**cb217838513dcff0eb516adb87ed820592b7007c7151039737d6c7c0b3a65986*goVwAFpWRlvktcDgs8pjgQ*crWCeTmLGGQ-wPhn-Ec9KytrInlVR2yVssmg4pUArCLDuNEmZY7-gREcTGfOZP1R2_pE5a7ZuDR0x8vPcuToKR9fqS1I4_i3SQmcCvsTVC0KwvXEv2yYnwYO8hGTqPxATRNQ6Lf6G05H51Ju117JzzaFryNi1OiQAnfOo32SPY74shVzYHHZeE9LzEml0GQK6ux7EL_BDP8qDLxHoLMJpnVln5rW5hNnSHoKKRvCWGM2QPrKukNrhz4fVTrZcGUc8tc1f9DorefmCgof2k-eXJTlYmmnirnAuPVnaZiLYndIBdwkdiIOLu70zf9rGFAZlJn7A3P8bQjCvFkJVzP37w*1810670822349*186ebc43da50e689ad2b8c2c93440913ce7691d56024018a554e37373f365289*37IZkmAmnqtqjHnGZwCig9r-CURO2mahhpieWnkujMo"
