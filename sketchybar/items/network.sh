#!/usr/bin/env bash
# Network item
sketchybar --add item network e \
           --subscribe network mouse.entered mouse.exited \
           --set network icon=󰤨 \
                         icon.font="$FONT_DISPLAY" \
                         icon.background.drawing=on \
                         icon.background.color="$SAPPHIRE" \
                         icon.color="$ICON_DARK_COLOR" \
                         label="--" \
                         label.color="$TEXT_COLOR" \
                         update_freq=2 \
                         script="$CONFIG_DIR/plugins/network.sh" \
                         mouse.entered_script="$HOVER_ENTER_SCRIPT" \
                         mouse.exited_script="$HOVER_EXIT_SCRIPT"
