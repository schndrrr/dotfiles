#!/bin/bash

clock=(
  icon=
  icon.font="Hack Nerd Font:Bold:16.0"
  label.font="Hack Nerd Font:Bold:14.0"
  label.padding_right=10
  update_freq=10
  script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right      \
           --set clock "${clock[@]}"   \
           --subscribe clock system_woke