#!/bin/zsh -f
# Front application plugin: app name + its sketchybar-app-font icon
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"
handle_hover

if [[ $SENDER == front_app_switched ]]; then
  source "$CONFIG_DIR/helpers/app_icon.sh"
  app_icon "$INFO"
  sketchybar --set "$NAME" icon="$INFO" label="$REPLY"
fi
