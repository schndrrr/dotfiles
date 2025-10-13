#!/usr/bin/env bash

# Update workspace visibility for numbered workspaces only
for sid in 1 2 3 4 5 6 7 8 9; do
    if [ -n "$(aerospace list-windows --workspace $sid)" ] || [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
        # Show workspace if it has windows or is focused
        sketchybar --set space.$sid drawing=on
        if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
            sketchybar --set space.$sid background.drawing=on
        else
            sketchybar --set space.$sid background.drawing=off
        fi
    else
        # Hide empty workspace
        sketchybar --set space.$sid drawing=off
    fi
done