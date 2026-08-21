#!/usr/bin/env bash
# Front application plugin
if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" icon="$INFO"
fi
