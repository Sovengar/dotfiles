#!/bin/bash

# Invoked by wallbash when wallpaper changes (via kitty.dcol).
# Wallbash extracts colors from the new wallpaper and writes theme.conf.
# This script reloads kitty so it picks up the new colors without restarting.

killall -SIGUSR1 kitty
