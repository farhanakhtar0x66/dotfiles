#!/usr/bin/env bash
# Front application item
sketchybar --add item front_app q \
           --subscribe front_app front_app_switched mouse.entered mouse.exited \
           --set front_app \
                 label=":default:" \
                 label.font="$FONT_APP" \
                 label.color="$ICON_DARK_COLOR" \
                 label.background.color="$BLUE" \
                 label.background.height=30 \
                 label.background.corner_radius=10 \
                 label.background.drawing=on \
                 icon="" \
                 icon.color="$TEXT_COLOR" \
                 script="$CONFIG_DIR/plugins/front_app.sh"
