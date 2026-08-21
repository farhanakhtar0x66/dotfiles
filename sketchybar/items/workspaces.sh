#!/usr/bin/env bash
# AeroSpace workspaces
for sid in {1..9}; do
    sketchybar --add item space.$sid left

    if [ "$sid" -eq 1 ]; then
        sketchybar --add event aerospace_workspace_change
        sketchybar --add event space_windows_change
        sketchybar --subscribe space.$sid aerospace_workspace_change space_windows_change
    fi

    sketchybar --set space.$sid \
            icon="$sid" \
            icon.font="$FONT_TEXT" \
            icon.width=22 \
            icon.align=center \
            icon.padding_left=8 \
            icon.padding_right=8 \
            label.font="$FONT_ICON" \
            label.padding_left=8 \
            label.padding_right=8 \
            background.color=0x00000000 \
            click_script="aerospace workspace $sid"
done

sketchybar --set space.1 script="/bin/bash $CONFIG_DIR/plugins/aerospace_ws.sh"
