# NOTE: zoxide provides `z` and `zi` for navigation — don't alias those.
if type -q zoxide
    zoxide init fish | source
end
