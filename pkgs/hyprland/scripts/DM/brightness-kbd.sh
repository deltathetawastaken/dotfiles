#!/usr/bin/env bash

old_brightness_file="/tmp/old_kbd_brightness"

lower_brightness() {
  brightnessctl -d platform::kbd_backlight get > "$old_brightness_file"
  brightnessctl -d platform::kbd_backlight set 0  # Set keyboard backlight to minimum
}

restore_brightness() {
  echo "Restoring keyboard backlight brightness..."
  if [[ -f "$old_brightness_file" ]]; then
    old_brightness=$(cat "$old_brightness_file")
    brightnessctl -d platform::kbd_backlight set "$old_brightness"
  else
    echo "No old keyboard backlight brightness level found."
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
