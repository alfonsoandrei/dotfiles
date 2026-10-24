#!/bin/bash
# Show the focused AeroSpace workspace in iris and other non-empty ones in overlay; hide the rest.

source "$CONFIG_DIR/colors.sh"
export PATH="/opt/homebrew/bin:$PATH"

focused=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}
nonempty=$(aerospace list-workspaces --monitor all --empty no)

args=()
for sid in $(aerospace list-workspaces --all); do
  if [ "$sid" = "$focused" ]; then
    args+=(--set "space.$sid" drawing=on background.color="$IRIS" label.color="$BASE")
  elif grep -qx "$sid" <<<"$nonempty"; then
    args+=(--set "space.$sid" drawing=on background.color="$OVERLAY" label.color="$SUBTLE")
  else
    args+=(--set "space.$sid" drawing=off)
  fi
done

sketchybar "${args[@]}"
