#!/usr/bin/env bash
# Clock plugin
TIME=$(date '+%I:%M %p')
DATE=$(date '+%a %d %b ')
sketchybar --set "$NAME" label="$DATE$TIME"
