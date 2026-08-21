#!/usr/bin/env bash
# Volume plugin
if [ "$SENDER" = "volume_change" ]; then
    sketchybar --set "$NAME" label="$INFO%"
elif [ "$SENDER" = "mouse.scrolled" ]; then
    # Adjust output volume in 5% increments and keep it within macOS limits.
    CURRENT=$(osascript -e 'output volume of (get volume settings)')
    if [ "${SCROLL_DELTA:-0}" -gt 0 ]; then
        NEW=$((CURRENT + 5))
    else
        NEW=$((CURRENT - 5))
    fi

    [ "$NEW" -gt 100 ] && NEW=100
    [ "$NEW" -lt 0 ] && NEW=0
    osascript -e "set volume output volume $NEW"
fi
