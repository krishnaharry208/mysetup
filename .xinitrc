#!/bin/sh
pulseaudio --start &
exec dbus-launch --sh-syntax --exit-with-session bspwm
