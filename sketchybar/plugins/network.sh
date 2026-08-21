#!/usr/bin/env bash
# Network plugin
CACHE_FILE="/tmp/network_bytes"
# en0
BYTES=$(netstat -ibn | awk '/en0/ && /Link/ {print $7; exit}')

if ! [[ "$BYTES" =~ ^[0-9]+$ ]]; then
    sketchybar --set "$NAME" label="0 B/s"
    exit 0
fi

if [ -f "$CACHE_FILE" ]; then
    OLD_BYTES=$(<"$CACHE_FILE")

    if [[ "$OLD_BYTES" =~ ^[0-9]+$ ]] && [ "$BYTES" -ge "$OLD_BYTES" ]; then
        # This script runs every two seconds (see the item definition).
        SPEED=$(((BYTES - OLD_BYTES) / 2))
    else
        SPEED=0
    fi
    
    if [ "$SPEED" -gt 1048576 ]; then
        FORMATTED=$(awk -v speed="$SPEED" 'BEGIN {printf "%.1f MB/s", speed / 1048576}')
    elif [ "$SPEED" -gt 1024 ]; then
        FORMATTED=$(awk -v speed="$SPEED" 'BEGIN {printf "%.0f KB/s", speed / 1024}')
    else
        FORMATTED="${SPEED} B/s"
    fi

    sketchybar --set "$NAME" label="$FORMATTED"
fi

echo "$BYTES" > "$CACHE_FILE"
