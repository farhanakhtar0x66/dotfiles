#!/usr/bin/env bash
# Media item
sketchybar --add item media e \
           --subscribe media media_change mouse.entered mouse.exited \
           --set media \
                 icon="󰎆" \
                 icon.color="$ICON_DARK_COLOR" \
                 icon.background.color="$GREEN" \
                 label.color="$TEXT_COLOR" \
                 scroll_texts=on \
                 label.max_chars=15 \
                 update_freq=2 \
                 mouse.entered_script="$HOVER_ENTER_SCRIPT" \
                 mouse.exited_script="$HOVER_EXIT_SCRIPT" \
                 script="$CONFIG_DIR/plugins/media.sh" \
                 click_script="$CONFIG_DIR/plugins/media_click.sh"
