#!/bin/bash
# Granola starts a "Granola Helper (Audio)" process while it records.

source "$CONFIG_DIR/colors.sh"

if pgrep -f 'Granola Helper \(Audio\)' >/dev/null; then
  sketchybar --set "$NAME" icon=󰍬 icon.color="$LOVE"
else
  sketchybar --set "$NAME" icon=󰍭 icon.color="$MUTED"
fi
