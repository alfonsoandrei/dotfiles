#!/bin/bash
# Show the current AeroSpace binding mode: a quiet badge in main, love in any other mode.

source "$CONFIG_DIR/colors.sh"
export PATH="/opt/homebrew/bin:$PATH"

# Empty when SketchyBar starts before AeroSpace, which always starts in main.
mode=$(aerospace list-modes --current)
mode=${mode:-main}

if [ "$mode" = "main" ]; then
  sketchybar --set "$NAME" label="$mode" background.color="$SURFACE" label.color="$MUTED"
else
  sketchybar --set "$NAME" label="$mode" background.color="$LOVE" label.color="$BASE"
fi
