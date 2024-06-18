#!/usr/bin/env bash

output=$(bluetoothctl info 2>&1)

if [[ $output == *"Missing device address argument"* ]] || [[ $output == *"DeviceSet (null) not available"* ]]; then
    exit 0
fi

charge=$(bluetoothctl info | awk -F ':' '/Battery Percentage: [0-9A-F]+/ {gsub(/.*\(|\).*/, "", $2); print $2}')
tooltip=$(bluetoothctl info | awk -F': ' '/Name/ {print $2}')

    #if [[ "$CHARGE" = "0" ]]
    #then
    #    echo ""
    #else

        #echo "{\"text\":\""$CHARGE"\", \"tooltip\":\""$tooltip"\"}"
    #fi
    #echo '{"number": "2", "tooltip": "text-text-text"}'
    echo -e $charge'%\n'$tooltip
    exit 0




