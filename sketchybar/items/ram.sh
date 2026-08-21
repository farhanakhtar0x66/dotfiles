#!/usr/bin/env bash
# RAM item
sketchybar --add item ram q \
           --subscribe ram mouse.entered mouse.exited \
           --set ram label= \
                     label.font="$FONT_DISPLAY" \
                     label.background.drawing=on \
                     label.background.color="$GREEN" \
                     label.background.height=26 \
                     label.background.corner_radius=8 \
                     label.color="$ICON_DARK_COLOR" \
                     icon="--" \
                     icon.font="$FONT_TEXT" \
                     icon.color="$TEXT_COLOR" \
                     update_freq=5 \
                     script="$CONFIG_DIR/plugins/ram.sh" \
                     mouse.entered_script="$HOVER_ENTER_SCRIPT" \
                     mouse.exited_script="$HOVER_EXIT_SCRIPT"
