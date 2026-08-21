#!/usr/bin/env bash
# Volume item
sketchybar --add item volume right \
           --subscribe volume volume_change mouse.scrolled mouse.entered mouse.exited \
           --set volume icon="󰕾" \
                 icon.color="$ICON_DARK_COLOR" \
                 icon.background.color="$SAPPHIRE" \
                 label.color="$TEXT_COLOR" \
                 mouse.entered_script="$HOVER_ENTER_SCRIPT" \
                 mouse.exited_script="$HOVER_EXIT_SCRIPT" \
                 script="$CONFIG_DIR/plugins/volume.sh"
