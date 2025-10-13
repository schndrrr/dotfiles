#!/bin/bash

update() {
  # Check if Spotify is running
  if ! pgrep -x "Spotify" > /dev/null; then
    sketchybar --set spotify drawing=off
    return
  fi

  # Get Spotify state
  STATE=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)
  
  if [ "$STATE" = "playing" ]; then
    TRACK=$(osascript -e 'tell application "Spotify" to get name of current track' 2>/dev/null)
    ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track' 2>/dev/null)
    
    if [ ! -z "$TRACK" ] && [ ! -z "$ARTIST" ]; then
      # Truncate long names
      if [ ${#TRACK} -gt 25 ]; then
        TRACK="${TRACK:0:22}..."
      fi
      if [ ${#ARTIST} -gt 25 ]; then
        ARTIST="${ARTIST:0:22}..."
      fi
      
      LABEL="$TRACK - $ARTIST"
      sketchybar --set spotify drawing=on \
                          label="$LABEL" \
                          icon=􀊄
    else
      sketchybar --set spotify drawing=on \
                          label="Playing" \
                          icon=􀊄
    fi
  elif [ "$STATE" = "paused" ]; then
    TRACK=$(osascript -e 'tell application "Spotify" to get name of current track' 2>/dev/null)
    ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track' 2>/dev/null)
    
    if [ ! -z "$TRACK" ] && [ ! -z "$ARTIST" ]; then
      # Truncate long names
      if [ ${#TRACK} -gt 25 ]; then
        TRACK="${TRACK:0:22}..."
      fi
      if [ ${#ARTIST} -gt 25 ]; then
        ARTIST="${ARTIST:0:22}..."
      fi
      
      LABEL="$TRACK - $ARTIST"
      sketchybar --set spotify drawing=on \
                          label="$LABEL" \
                          icon=􀊆
    else
      sketchybar --set spotify drawing=on \
                          label="Paused" \
                          icon=􀊆
    fi
  else
    sketchybar --set spotify drawing=off
  fi
}

case "$SENDER" in
  "routine"|"forced"|"spotify_change") update
  ;;
  "mouse.clicked") 
    osascript -e 'tell application "Spotify" to playpause' 2>/dev/null
    sleep 0.1
    update
  ;;
  *) update
  ;;
esac