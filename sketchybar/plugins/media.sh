#!/usr/bin/env bash
# Media plugin
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"

# nowplaying-cli
NOWPLAYING_CLI="${NOWPLAYING_CLI:-$(command -v nowplaying-cli 2>/dev/null)}"
if [ -z "$NOWPLAYING_CLI" ]; then
    for candidate in /opt/homebrew/bin/nowplaying-cli /usr/local/bin/nowplaying-cli; do
        if [ -x "$candidate" ]; then
            NOWPLAYING_CLI="$candidate"
            break
        fi
    done
fi

if [ -x "$NOWPLAYING_CLI" ]; then
    STATE=$("$NOWPLAYING_CLI" get playbackRate 2>/dev/null)
    TITLE=$("$NOWPLAYING_CLI" get title 2>/dev/null)

    if [ "$STATE" = "1" ] || [ "$STATE" = "1.0" ] || [ "$STATE" = "playing" ]; then
        sketchybar --animate sin "$VALUE_ANIMATION_FRAMES" --set "$NAME" drawing=on icon="󰎆" label="$TITLE" icon.background.color="$GREEN"
    elif [ -n "$TITLE" ] && [ "$TITLE" != "null" ]; then
        sketchybar --animate sin "$VALUE_ANIMATION_FRAMES" --set "$NAME" drawing=on icon="󰏤" label="$TITLE" icon.background.color="$YELLOW"
    else
        sketchybar --animate sin "$VALUE_ANIMATION_FRAMES" --set "$NAME" drawing=on icon="󰎆" label="Offline" icon.background.color="$INACTIVE_COLOR"
    fi
else
    # Fallback but may not needed coz the script will install everything 
    sketchybar --animate sin "$VALUE_ANIMATION_FRAMES" --set "$NAME" drawing=on label="Offline" icon.background.color="$INACTIVE_COLOR"
fi
