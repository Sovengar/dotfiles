#!/usr/bin/env sh

LESSHISTFILE="${LESSHISTFILE:-/tmp/less-hist}"
PARALLEL_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/parallel"
SCREENRC="${XDG_CONFIG_HOME:-$HOME/.config}/screen/screenrc"

export LESSHISTFILE PARALLEL_HOME SCREENRC
