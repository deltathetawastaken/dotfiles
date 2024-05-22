#!/usr/bin/env bash

old_brightness_file="/tmp/old_brightness"

lower_brightness() {
  brightnessctl get > "$old_brightness_file"
  brightnessctl set 10%  # Adjust percentage as desired
}

restore_brightness() {
  echo "Restoring brightness..."
  if [[ -f "$old_brightness_file" ]]; then
    old_brightness=$(cat "$old_brightness_file")
    brightnessctl set "$old_brightness"
  else
    echo "No old brightness level found."
  fi
}

case "$1" in
  "on-timeout")
    lower_brightness
    ;;
  "on-resume")
    restore_brightness
    ;;
  *)
    echo "Usage: $0 {on-timeout|on-resume}"
    exit 1
    ;;
esac
