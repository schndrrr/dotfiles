#!/bin/bash

# Add the aerospace workspace change event
sketchybar --add event aerospace_workspace_change

# Create initial workspace items (will be updated dynamically)
for sid in 1 2 3 4 5 6 7 8 9; do
    sketchybar --add item space.$sid left \
        --subscribe space.$sid aerospace_workspace_change \
        --set space.$sid \
        background.color=0x44ffffff \
        background.corner_radius=5 \
        background.height=20 \
        background.drawing=off \
        label="$sid" \
        label.color=0xffffffff \
        label.font="Hack Nerd Font:Bold:14.0" \
        label.padding_left=8 \
        label.padding_right=8 \
        padding_left=2 \
        padding_right=2 \
        click_script="aerospace workspace $sid" \
        script="$PLUGIN_DIR/aerospace.sh"
done