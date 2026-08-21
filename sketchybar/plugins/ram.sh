#!/usr/bin/env bash
# RAM plugin
FREE_PERCENT=$(memory_pressure | awk '/System-wide memory free percentage:/ {gsub("%", "", $5); print $5; exit}')

if ! [[ "$FREE_PERCENT" =~ ^[0-9]+$ ]]; then
    exit 0
fi

RAM_USAGE=$((100 - FREE_PERCENT))
USED_GB=$(echo "$RAM_USAGE 16" | awk '{printf "%.1f", $1 * $2 / 100}')

sketchybar --set "$NAME" icon="${USED_GB}/16 GB"
