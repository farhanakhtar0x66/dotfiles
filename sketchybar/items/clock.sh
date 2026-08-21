#!/usr/bin/env bash
# Clock / calendar item
sketchybar --add item clock right \
           --subscribe clock mouse.entered mouse.exited \
           --set clock icon="󰃰" \
                 icon.color="$ICON_DARK_COLOR" \
                 icon.background.color="$MAUVE" \
                 label.color="$TEXT_COLOR" \
                 update_freq=10 \
                 mouse.entered_script="$HOVER_ENTER_SCRIPT" \
                 mouse.exited_script="$HOVER_EXIT_SCRIPT" \
                 script="$CONFIG_DIR/plugins/clock.sh"
