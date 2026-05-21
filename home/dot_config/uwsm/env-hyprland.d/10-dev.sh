#!/usr/bin/env sh

EDITOR="${EDITOR:-code}"
VISUAL="${VISUAL:-$EDITOR}"
AURHELPER="${AURHELPER:-paru}"
aurhelper="${aurhelper:-$AURHELPER}"

export EDITOR VISUAL AURHELPER aurhelper
