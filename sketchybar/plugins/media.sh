#!/usr/bin/env bash
# Media plugin — state is pushed by helpers/media_stream.sh (MEDIA_TITLE / MEDIA_PLAYING).
# Without pushed state (startup, wake) it asks media-control once.
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"
handle_hover
export PATH="/opt/homebrew/bin:$PATH"

if [ -n "${MEDIA_TITLE+x}" ]; then
    TITLE="$MEDIA_TITLE"; PLAYING="$MEDIA_PLAYING"
else
    IFS=$'\x1f' read -r TITLE PLAYING <<< "$(media-control get --no-artwork 2>/dev/null \
        | jq -r '[(.title // ""), ((.playing // false) | tostring)] | join("\u001f")' 2>/dev/null)"
fi

if [ -n "$TITLE" ] && [ "$PLAYING" = "true" ]; then
    sketchybar --animate sin "$VALUE_ANIMATION_FRAMES" --set "$NAME" drawing=on icon="󰎆" label="$TITLE" icon.background.color="$GREEN"
elif [ -n "$TITLE" ]; then
    sketchybar --animate sin "$VALUE_ANIMATION_FRAMES" --set "$NAME" drawing=on icon="󰏤" label="$TITLE" icon.background.color="$YELLOW"
else
    sketchybar --animate sin "$VALUE_ANIMATION_FRAMES" --set "$NAME" drawing=on icon="󰎆" label="Offline" icon.background.color="$INACTIVE_COLOR"
fi
