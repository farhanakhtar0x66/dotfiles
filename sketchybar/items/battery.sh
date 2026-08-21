#!/usr/bin/env bash
# Battery item
sketchybar --add item battery right \
           --subscribe battery power_source_change system_woke mouse.entered mouse.exited \
           --set battery icon=󰁹 \
                         icon.font="$FONT_ICON" \
                         icon.background.drawing=on \
                         icon.background.color="$YELLOW" \
                         icon.color="$ICON_DARK_COLOR" \
                         label="100%" \
                         label.color="$TEXT_COLOR" \
                         update_freq=120 \
                         script="$CONFIG_DIR/plugins/battery.sh" \
                         mouse.entered_script="$HOVER_ENTER_SCRIPT" \
                         mouse.exited_script="$HOVER_EXIT_SCRIPT"
