#!/usr/bin/env sh
HYPRGAPSMODE=$(hyprctl getoption general:gaps_in | awk 'NR==2{print$2}')

# Check if the environment variable exists and has a value
if [ "$HYPRGAPSMODE" != "0" ]; then
    hyprctl --batch "\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;"
else
    hyprctl --batch "\
        keyword general:gaps_in 10;\
        keyword general:gaps_out 3;"
fi

exit

