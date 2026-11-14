#!/usr/bin/env bash
# CPU item
sketchybar --add item cpu q \
           --subscribe cpu mouse.entered mouse.exited \
           --set cpu label= \
                     label.font="$FONT_DISPLAY" \
                     label.background.drawing=on \
                     label.background.color="$MAUVE" \
                     label.background.height=30 \
                     label.background.corner_radius=10 \
                     label.color="$ICON_DARK_COLOR" \
                     icon="--" \
                     icon.font="$FONT_TEXT" \
                     icon.color="$TEXT_COLOR" \
                     update_freq=2 \
                     script="$CONFIG_DIR/plugins/cpu.sh"
