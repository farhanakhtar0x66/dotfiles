#!/usr/bin/env bash
# RAM item
sketchybar --add item ram q \
           --subscribe ram mouse.entered mouse.exited \
           --set ram label= \
                     label.font="$FONT_DISPLAY" \
                     label.background.drawing=on \
                     label.background.color="$GREEN" \
                     label.background.height=30 \
                     label.background.corner_radius=10 \
                     label.color="$ICON_DARK_COLOR" \
                     icon="--" \
                     icon.font="$FONT_TEXT" \
                     icon.color="$TEXT_COLOR" \
                     script="$CONFIG_DIR/plugins/hover.sh"
