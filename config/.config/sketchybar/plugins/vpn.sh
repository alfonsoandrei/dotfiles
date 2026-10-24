#!/bin/bash
# AWS VPN Client logs its tray state; show a foam shield-check when connected, a muted shield-off otherwise.

source "$CONFIG_DIR/colors.sh"

state=""
for log in $(/bin/ls -t "$HOME/.config/AWSVPNClient/logs"/aws_vpn_client_gui_*.log 2>/dev/null); do
  state=$(grep -o 'Tray state changed to [a-z]*' "$log" | tail -1 | awk '{print $NF}')
  [ -n "$state" ] && break
done

if [ "$state" = "connected" ]; then
  sketchybar --set "$NAME" icon=󰕥 icon.color="$FOAM"
else
  sketchybar --set "$NAME" icon=󰦝 icon.color="$MUTED"
fi
