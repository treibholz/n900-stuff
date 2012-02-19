#!/bin/bash

# primitive script to load the battery of a Nokia N900 without the proprietary
# daemon


battery_present () { # {{{
    if grep -q 1 /sys/class/power_supply/bq27200-0/present; then
        return 0
    else
        return 1
    fi
} # }}}

charger_present () { # {{{
    if grep -q 1 /sys/bus/platform/devices/twl4030_usb/vbus; then
        return 0
    else
        return 1
    fi
} # }}}

battery_percent () { # {{{
    cat /sys/class/power_supply/bq27200-0/capacity
} # }}}

battery_temp () { # {{{
    cat /sys/class/power_supply/bq27200-0/temp
} # }}}

function battery_load () { # {{{
    i2cset -y -m 0x77 2 0x6b 0x04 0xc9;
    status=$(i2cget -y 2 0x6b 0x00)

    # next register 0x03 is device ID, always 4b and r/o; so we skip to 0x04
    i2cset -y -m 0xff 2 0x6b 0x02 0x8c;
    # 0x8c = 3v5 + .640 + .040 + .020 = 4V200, BE CAREFUL and DON'T CHANGE
    # unless you know what you're doing. 4V2 is ABS MAX!
    i2cset -y -m 0xff 2 0x6b 0x01 0xc8;
    i2cset -y -m 0xc0 2 0x6b 0x00 0x00;

    # tickle watchdog, while status indicates 'charging from wallcharger'
    #while [ $(i2cget -y 2 0x6b 0x00) = 0x90 ] ; do
    while [ $(i2cget -y 2 0x6b 0x00) = 0x10 ] ; do
            echo charging...
            sleep 28;
            # reset watchdog timer:
            i2cset -y -m 0x80 2 0x6b 0x00 0x80
    done
} # }}}

while true; do

    if battery_present && charger_present; then
        echo "Start charging..."
        battery_load
        echo "Stop charging..."
    else
        sleep 10

    fi

done

# vim:fdm=marker:ts=4:sw=4:sts=4:ai:sta:et
