#!/usr/bin/env fish

function kn
    if test "$argv[1]" = "default" -o "$argv[1]" = "d"
        kubectl config set-context --current --namespace=default
    else
        kubectl config set-context --current --namespace=$argv[1]
    end
end
