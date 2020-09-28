#!/bin/bash
#
# Loads / unloads pulseaudio loopback module in order to eg. be redirect
#  mic input to headphones.
#
# Usage: mic-loopback [on|off]
#

on="pactl load-module module-loopback latency_msec=1"
off="pactl unload-module module-loopback"
status="pacmd list-sink-inputs | awk '{print $1;}'"

if [ $# -ne 1 ]; then
	echo "Usage: $0 [on|off]"
	exit 1
fi

if [[ $1 == "on"  ]]; then
    $on
    echo "pulseaudio loopback module loaded"
elif [[ $1 == "off" ]]; then
    $off
    echo "pulseaudio loopback module unloaded"
elif [[ $1 == "status" ]]; then
    echo "pulseaudio loopback module status: " && $status
else
    echo "Usage: $0 [on|off]"
fi