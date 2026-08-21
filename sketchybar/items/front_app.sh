#!/usr/bin/env bash
# Front application item
sketchybar --add item front_app q \
           --subscribe front_app front_app_switched mouse.entered mouse.exited \
           --set front_app \
                 label="󰣆" \
                 label.color="$ICON_DARK_COLOR" \
                 label.background.color="$BLUE" \
                 label.background.height=26 \
                 label.background.corner_radius=8 \
                 label.background.drawing=on \
                 icon="" \
                 icon.color="$TEXT_COLOR" \
                 mouse.entered_script="$HOVER_ENTER_SCRIPT" \
                 mouse.exited_script="$HOVER_EXIT_SCRIPT" \
                 script="$CONFIG_DIR/plugins/front_app.sh"
