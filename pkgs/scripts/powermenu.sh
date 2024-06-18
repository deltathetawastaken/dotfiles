#!/usr/bin/env bash

# Define the options
options="Hibernate\nShutdown\nReboot\nSuspend\nLogout\nLock"

# Use dmenu to get the user's choice
choice=$(echo -e "$options" | fzfmenuft)

# Execute the corresponding command based on the user's choice
case "$choice" in
    Hibernate)
        systemctl hibernate
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    Reboot)
        systemctl reboot
        ;;
    Suspend)
        systemctl suspend
        ;;
    Logout)
        # Assuming you're using a desktop environment that supports 'logout'
        # Adjust the command according to your DE/WM
        pkill -KILL -u $USER
        ;;
    Lock)
        hyprlock
        ;;
    *)
        echo "Invalid option" && exit 1
        ;;
esac
