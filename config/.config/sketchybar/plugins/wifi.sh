#!/bin/bash
# Pine Wi-Fi icon while the Wi-Fi interface has an IPv4 address, love Wi-Fi-off otherwise.

source "$CONFIG_DIR/colors.sh"

device=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/ { getline; print $2 }')

if [ -n "$device" ] && ipconfig getifaddr "$device" >/dev/null 2>&1; then
  sketchybar --set "$NAME" icon=󰖩 icon.color="$PINE"
else
  sketchybar --set "$NAME" icon=󰖪 icon.color="$LOVE"
fi
