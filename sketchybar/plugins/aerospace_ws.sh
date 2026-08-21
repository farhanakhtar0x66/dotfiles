#!/usr/bin/env bash

# Update all workspace badges from one AeroSpace query.
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"

WORKSPACE_COUNT=9
ICON_GAP="  "
STATE_DIR="${SKETCHYBAR_STATE_DIR:-/tmp}"
FOCUS_CACHE_FILE="$STATE_DIR/sketchybar-focused-workspace"
WINDOW_CACHE_FILE="$STATE_DIR/sketchybar-workspace-window-list"
WINDOW_LOCK_DIR="$STATE_DIR/sketchybar-workspace-refresh.lock"
FOCUSED_WORKSPACE="${FOCUSED_WORKSPACE:-${AEROSPACE_WORKSPACE:-}}"

if [ -z "$FOCUSED_WORKSPACE" ]; then
    if [ -f "$FOCUS_CACHE_FILE" ]; then
        FOCUSED_WORKSPACE=$(<"$FOCUS_CACHE_FILE")
    else
        FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
    fi
fi

if [ -n "$FOCUSED_WORKSPACE" ]; then
    printf '%s\n' "$FOCUSED_WORKSPACE" > "$FOCUS_CACHE_FILE"
fi

if [ "$SENDER" = "space_windows_change" ]; then
    if ! mkdir "$WINDOW_LOCK_DIR" 2>/dev/null; then
        exit 0
    fi
    trap 'rmdir "$WINDOW_LOCK_DIR" 2>/dev/null' EXIT
    sleep 0.08
fi

get_window_list() {
    aerospace list-windows --all --format '%{workspace}%{tab}%{app-name}' 2>/dev/null | sort -u
}

WINDOW_LIST=$(get_window_list)
if [ "$SENDER" = "space_windows_change" ]; then
    sleep 0.06
    UPDATED_WINDOW_LIST=$(get_window_list)

    if [ "$UPDATED_WINDOW_LIST" != "$WINDOW_LIST" ]; then
        sleep 0.06
        UPDATED_WINDOW_LIST=$(get_window_list)
    fi

    WINDOW_LIST="$UPDATED_WINDOW_LIST"
fi

if [ "$SENDER" = "space_windows_change" ] && [ -f "$WINDOW_CACHE_FILE" ]; then
    PREVIOUS_WINDOW_LIST=$(<"$WINDOW_CACHE_FILE")
    if [ "$WINDOW_LIST" = "$PREVIOUS_WINDOW_LIST" ]; then
        exit 0
    fi
fi

printf '%s\n' "$WINDOW_LIST" > "$WINDOW_CACHE_FILE"

# Icon strings for applications
ICON_STR=("" "" "" "" "" "" "" "" "" "")

while IFS=$'\t' read -r workspace app_name; do
    if [ -z "$workspace" ] || [ -z "$app_name" ]; then
        continue
    fi

    case "$workspace" in
        1|2|3|4|5|6|7|8|9) ;;
        *) continue ;;
    esac

    icon=""
    case "$app_name" in
        # Browsers
        "Helium"|"Google Chrome"|"Chrome"|"Brave Browser"|"Arc"|"Edge"|"Zen Browser") icon="" ;;
        # Coding
        "VSCodium"|"Code"|"Visual Studio Code"|"VSCode"|"Cursor"|"Neovim"|"nvim"|"Xcode"|"WebStorm"|"IntelliJ IDEA") icon="󰨞" ;;
        # Terminals
        "Ghostty"|"Terminal"|"Alacritty"|"iTerm2"|"iTerm"|"Warp"|"kitty") icon="" ;;
        # Social
        "Slack"|"Telegram"|"Messages"|"Messenger") icon="󰍡" ;;
        # Media
        "Music"|"Apple Music"|"YouTube Music") icon="" ;;
        "IINA"|"VLC") icon="󰕼" ;;
        # System and office
        "Finder") icon="󰀶" ;;
        "Clock") icon="󰃰" ;;
        "Mail"|"Microsoft Outlook") icon="󰇮" ;;
        "Calendar") icon="󰸗" ;;
        "System Settings"|"System Preferences") icon="󰒓" ;;
        "Notes"|"Notion"|"TextEdit"|"Pages"|"Word") icon="󱞁" ;;
        # Other applications
        "Chess") icon="" ;;
        "Discord") icon="" ;;
        "Hayase") icon="" ;;
        "Safari") icon="" ;;
        "Firefox"|"Firefox Developer Edition") icon="󰈹" ;;
        "WhatsApp") icon="" ;;
        "Spotify") icon="" ;;
        *) icon="󰀻" ;;
    esac

    if [ -z "${ICON_STR[$workspace]}" ]; then
        ICON_STR[$workspace]="$icon"
    else
        ICON_STR[$workspace]="${ICON_STR[$workspace]}${ICON_GAP}${icon}"
    fi
done <<< "$WINDOW_LIST"

# Sketchybar badge animation
if [ "$SENDER" = "space_windows_change" ]; then
    SKETCHYBAR_ARGS=()
else
    SKETCHYBAR_ARGS=(--animate sin "$WORKSPACE_ANIMATION_FRAMES")
fi
for sid in $(seq 1 "$WORKSPACE_COUNT"); do
    if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
        SKETCHYBAR_ARGS+=(
            --set "space.$sid"
            drawing=on
            icon="$sid"
            icon.color="$ICON_DARK_COLOR"
            icon.background.color="$PEACH"
            background.color="$SURFACE_COLOR"
            label="${ICON_STR[$sid]:-—}"
            label.color="$TEXT_COLOR"
            label.width=dynamic
        )
    else
        SKETCHYBAR_ARGS+=(
            --set "space.$sid"
            drawing=on
            icon="$sid"
            icon.color="$TEXT_COLOR"
            icon.background.color="$SURFACE_COLOR"
            background.color=0x00000000
            label.width=0
        )
    fi
done

sketchybar "${SKETCHYBAR_ARGS[@]}"
