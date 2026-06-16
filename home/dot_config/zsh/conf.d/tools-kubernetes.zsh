#!/usr/bin/env zsh

function kn {
  if [[ $1 == default || $1 == d ]]; then
    kubectl config set-context --current --namespace=default
  else
    kubectl config set-context --current --namespace="$1"
  fi
}
