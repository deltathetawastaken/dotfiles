#!/usr/bin/env bash

iDIR="$HOME/Documents/dotfiles/pkgs/scripts/icons"

# Get Volume
get_volume() {
	volume=$(pamixer --get-volume)
	echo "$volume"
}

# Get icons
get_icon() {
	current=$(get_volume)
	if [[ "$current" -eq "0" ]]; then
		echo "$iDIR/volume-mute.png"
	elif [[ ("$current" -ge "0") && ("$current" -le "30") ]]; then
		echo "$iDIR/volume-low.png"
	elif [[ ("$current" -ge "30") && ("$current" -le "60") ]]; then
		echo "$iDIR/volume-mid.png"
	elif [[ ("$current" -ge "60") && ("$current" -le "100") ]]; then
		echo "$iDIR/volume-high.png"
	fi
}

draw_progressbar() {
  # Get the percentage as the first argument
  local percentage=$1
  # Calculate the number of filled and empty bars based on the percentage
  local filled=$((percentage / 4))
  local empty=$((25 - filled))
  # Create a string of filled bars
  local fill=$(printf "%${filled}s")
  # Create a string of empty bars
  local empt=$(printf "%${empty}s")
  # Replace the spaces with the bar symbols
  fill=${fill// /█}
  empt=${empt// /░}
  # Print the progressbar with the percentage
  printf "%s%s" "$fill" "$empt"
}

# Notify
notify_user() {
	  local volume=$(get_volume)
	  # Call the draw_progressbar function with the volume as the argument
	  local progressbar=$(draw_progressbar "$volume")
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "$(get_icon)" "$volume %" "$progressbar"
}

# Increase Volume
inc_volume() {
	pamixer -i 5 && notify_user
}

# Decrease Volume
dec_volume() {
	pamixer -d 5 && notify_user
}

# Toggle Mute
toggle_mute() {
	if [ "$(pamixer --get-mute)" == "false" ]; then
		pamixer -m && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "$iDIR/volume-mute.png" "Volume Switched OFF" "$(draw_progressbar "0")"
	elif [ "$(pamixer --get-mute)" == "true" ]; then
		pamixer -u && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "$(get_icon)" "Volume Switched ON" "$(draw_progressbar "$(get_volume)")"
	fi
}

# Toggle Mic
toggle_mic() {
	if [ "$(pamixer --default-source --get-mute)" == "false" ]; then
		pamixer --default-source -m && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "$iDIR/microphone-mute.png" "Microphone Switched OFF"
	elif [ "$(pamixer --default-source --get-mute)" == "true" ]; then
		pamixer -u --default-source u && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "$iDIR/microphone.png" "Microphone Switched ON"
	fi
}
# Get icons
get_mic_icon() {
	current=$(pamixer --default-source --get-volume)
	if [[ "$current" -eq "0" ]]; then
		echo "$iDIR/microphone.png"
	elif [[ ("$current" -ge "0") && ("$current" -le "30") ]]; then
		echo "$iDIR/microphone.png"
	elif [[ ("$current" -ge "30") && ("$current" -le "60") ]]; then
		echo "$iDIR/microphone.png"
	elif [[ ("$current" -ge "60") && ("$current" -le "100") ]]; then
		echo "$iDIR/microphone.png"
	fi
}
# Notify
notify_mic_user() {
	local volume=$(pamixer --default-source --get-volume)
	# Call the draw_progressbar function with the volume as the argument
	local progressbar=$(draw_progressbar "$volume")
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "$(get_mic_icon)" "Mic-Level : $volume %" "$progressbar"
}

# Increase MIC Volume
inc_mic_volume() {
	pamixer --default-source -i 5 && notify_mic_user
}

# Decrease MIC Volume
dec_mic_volume() {
	pamixer --default-source -d 5 && notify_mic_user
}

# Execute accordingly
if [[ "$1" == "--get" ]]; then
	get_volume
elif [[ "$1" == "--inc" ]]; then
	inc_volume
elif [[ "$1" == "--dec" ]]; then
	dec_volume
elif [[ "$1" == "--toggle" ]]; then
	toggle_mute
elif [[ "$1" == "--toggle-mic" ]]; then
	toggle_mic
elif [[ "$1" == "--get-icon" ]]; then
	get_icon
elif [[ "$1" == "--get-mic-icon" ]]; then
	get_mic_icon
elif [[ "$1" == "--mic-inc" ]]; then
	inc_mic_volume
elif [[ "$1" == "--mic-dec" ]]; then
	dec_mic_volume
else
	get_volume
fi
