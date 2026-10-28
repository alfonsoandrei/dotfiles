#!/bin/bash
# Show the focused AeroSpace workspace in iris and other non-empty ones in overlay; hide the rest.
# Items are created here, not in sketchybarrc, so workspaces AeroSpace creates on the fly (like 10)
# show up too, and a bar that started before AeroSpace fills in on the first event.

source "$CONFIG_DIR/colors.sh"
export PATH="/opt/homebrew/bin:$PATH"

focused=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}
nonempty=$(aerospace list-workspaces --monitor all --empty no)
all=$(aerospace list-workspaces --all)
existing=$(sketchybar --query bar | grep -o '"space\.[^"]*"' | tr -d '"')

args=()
# Hide items for workspaces AeroSpace has since dropped.
for item in $existing; do
  grep -qx "${item#space.}" <<<"$all" || args+=(--set "$item" drawing=off)
done

for sid in $all; do
  if ! grep -qx "space.$sid" <<<"$existing"; then
    args+=(--add item "space.$sid" left
      --set "space.$sid" label="$sid" icon.drawing=off
        label.padding_left=10 label.padding_right=10
        background.corner_radius=7 background.height=22 background.drawing=on
        click_script="aerospace workspace $sid"
      --move "space.$sid" before aerospace)
  fi
  if [ "$sid" = "$focused" ]; then
    args+=(--set "space.$sid" drawing=on background.color="$IRIS" label.color="$BASE")
  elif grep -qx "$sid" <<<"$nonempty"; then
    args+=(--set "space.$sid" drawing=on background.color="$OVERLAY" label.color="$SUBTLE")
  else
    args+=(--set "space.$sid" drawing=off)
  fi
done

sketchybar "${args[@]}"
