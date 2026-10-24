#!/bin/bash

batt=$(pmset -g batt)
percent=$(grep -Eo '[0-9]+%' <<<"$batt" | head -1 | tr -d '%')
[ -z "$percent" ] && exit 0

if grep -q 'AC Power' <<<"$batt"; then
  icon=󰂄
elif [ "$percent" -ge 80 ]; then
  icon=󰁹
elif [ "$percent" -ge 50 ]; then
  icon=󰁾
elif [ "$percent" -ge 20 ]; then
  icon=󰁻
else
  icon=󰂃
fi

sketchybar --set "$NAME" icon="$icon" label="$percent%"
