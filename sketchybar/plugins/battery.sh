#!/usr/bin/env bash
# Battery plugin
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"

BATT_INFO=$(pmset -g batt)
PERCENTAGE=$(echo "$BATT_INFO" | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(echo "$BATT_INFO" | grep -i "AC Power")

if [ -z "$PERCENTAGE" ]; then
    exit 0
fi

ICON_COLOR="$GREEN"

if [ -n "$CHARGING" ]; then
    ICON="󰂄"
    ICON_COLOR="$GREEN"
else
    case "$PERCENTAGE" in
        9[0-9]|100)
            ICON="󰁹"
            ICON_COLOR="$GREEN"
            ;;
        7[0-9]|8[0-9])
            ICON="󰂀"
            ICON_COLOR="$GREEN"
            ;;
        4[0-9]|5[0-9]|6[0-9])
            ICON="󰁾"
            ICON_COLOR="$BLUE"
            ;;
        2[0-9]|3[0-9])
            ICON="󰁼"
            ICON_COLOR="$PEACH"
            ;;
        *)
            ICON="󰂃"
            ICON_COLOR="$RED"
            ;;
    esac
fi

sketchybar --animate tanh "$VALUE_ANIMATION_FRAMES" --set "$NAME" icon="$ICON" icon.background.color=$ICON_COLOR label="${PERCENTAGE}%"
