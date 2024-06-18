#!/usr/bin/env bash

# Define the options
options=(
    "off"
    "blue-light-filter"
    "extradark"
    "noblue-light"
    "noblue-smart"
    "noblue"
)

# Prompt user to select an option using dmenu
selected_option=$(printf "%s\n" "${options[@]}" | fzfmenuft)

# Check if selected option is empty (user canceled)
if [[ -z "$selected_option" ]]; then
    exit 1
fi

# Construct the hyprshade command based on selected option
if [[ "$selected_option" == "off" ]]; then
    command="hyprshade off"
else
    command="hyprshade on $selected_option"
fi

# Execute the constructed command
eval $command
