#!/usr/bin/env bash
# RAM plugin
FREE_PERCENT=$(memory_pressure | awk '/System-wide memory free percentage:/ {gsub("%", "", $5); print $5; exit}')

if ! [[ "$FREE_PERCENT" =~ ^[0-9]+$ ]]; then
    exit 0
fi

RAM_USAGE=$((100 - FREE_PERCENT))
sketchybar --set "$NAME" icon="${RAM_USAGE}%"
