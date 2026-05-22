#!/usr/bin/env zsh

# Kubernetes shortcuts. Fish equivalent: conf.d/60-kubernetes.fish.
alias k='kubectl'

export KUBECONFIG='.kube/prod-k8s-clcreative-kubeconfig.yaml;.kube/civo-k8s_test_1-kubeconfig;.kube/k8s_test_1.yml'

function kn {
  if [[ $1 == default || $1 == d ]]; then
    kubectl config set-context --current --namespace=default
  else
    kubectl config set-context --current --namespace="$1"
  fi
}
