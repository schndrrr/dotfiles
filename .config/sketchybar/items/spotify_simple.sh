#!/bin/bash

source "$HOME/.config/sketchybar/icons.sh"
PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

spotify=(
  icon=􁁒
  icon.font="Hack Nerd Font:Bold:16.0"
  icon.color=0xff1db954
  label.font="Hack Nerd Font:Regular:14.0"
  label="Not Playing"
  label.max_chars=50
  script="$PLUGIN_DIR/spotify_simple.sh"
  click_script="osascript -e 'tell application \"Spotify\" to playpause'"
  update_freq=2
  padding_left=10
  padding_right=15
)

sketchybar --add event spotify_change $SPOTIFY_EVENT \
           --add item spotify left                 \
           --set spotify "${spotify[@]}"            \
           --subscribe spotify spotify_change mouse.clicked
