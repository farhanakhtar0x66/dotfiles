#!/bin/zsh -f
# Items with no data of their own (RAM is refreshed by cpu.sh) still get the hover glow.
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"
handle_hover
