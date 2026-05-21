#!/usr/bin/env fish

alias k='kubectl'

set -gx KUBECONFIG ".kube/prod-k8s-clcreative-kubeconfig.yaml;.kube/civo-k8s_test_1-kubeconfig;.kube/k8s_test_1.yml"

function kn
    if test "$argv[1]" = "default" -o "$argv[1]" = "d"
        kubectl config set-context --current --namespace=default
    else
        kubectl config set-context --current --namespace=$argv[1]
    end
end
