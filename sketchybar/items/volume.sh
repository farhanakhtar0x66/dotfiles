#!/usr/bin/env bash
# Volume item
sketchybar --add item volume right \
           --subscribe volume volume_change mouse.scrolled mouse.entered mouse.exited \
           --set volume icon="󰕾" \
                 icon.color="$ICON_DARK_COLOR" \
                 icon.background.color="$SAPPHIRE" \
                 label.color="$TEXT_COLOR" \
                 script="$CONFIG_DIR/plugins/volume.sh"
