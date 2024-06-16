#!/bin/bash

sh -c "swaylock -C /home/delta/.config/swaylock/config --indicator-x-position $(shuf -i 100-1750 -n 1) --indicator-y-position $(shuf -i 50-1000 -n 1)" & hyprctl switchxkblayout at-translated-set-2-keyboard 0

#X_POS=$(shuf -i 100-1750 -n 1)
#Y_POS=$(shuf -i 50-1000 -n 1)

#swaylock -C .config/swaylock/config2 --indicator-x-position $X_POS --indicator-y-position $Y_POS
