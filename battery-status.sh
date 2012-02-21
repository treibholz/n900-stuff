#!/bin/bash

# Battery

battery_present () {
    if grep -q 1 /sys/class/power_supply/bq27200-0/present; then
        return 0
    else
        return 1
    fi
}

battery_percent () {
    cat /sys/class/power_supply/bq27200-0/capacity
}

battery_temp () {
    cat /sys/class/power_supply/bq27200-0/temp
}


if battery_present ; then
    echo "Battery: $(battery_percent)%"
    echo "Temperature: $(battery_temp)°C"
fi


