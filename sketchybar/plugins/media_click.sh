#!/usr/bin/env bash

# Media click plugin
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"

NOWPLAYING_CLI="${NOWPLAYING_CLI:-$(command -v nowplaying-cli 2>/dev/null)}"
if [ -z "$NOWPLAYING_CLI" ]; then
    for candidate in /opt/homebrew/bin/nowplaying-cli /usr/local/bin/nowplaying-cli; do
        if [ -x "$candidate" ]; then
            NOWPLAYING_CLI="$candidate"
            break
        fi
    done
fi

[ -x "$NOWPLAYING_CLI" ] || exit 0

# pause and find media
"$NOWPLAYING_CLI" togglePlayPause &

CURRENT_ICON=$(sketchybar --query media | python3 -c "import sys, json; print(json.loads(sys.stdin.read())['icon']['value'])")

if [ "$CURRENT_ICON" = "󰏤" ]; then
    sketchybar --animate sin "$VALUE_ANIMATION_FRAMES" --set media icon="󰎆" icon.background.color="$GREEN"
else
    sketchybar --animate sin "$VALUE_ANIMATION_FRAMES" --set media icon="󰏤" icon.background.color="$YELLOW"
fi
