#!/bin/zsh -f
# Clock plugin — "15 Nov 04:41 AM" (no weekday). strftime is a builtin: no `date` forks.
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"
handle_hover
zmodload zsh/datetime
strftime -s label '%d %b %I:%M %p'
sketchybar --set "$NAME" label="$label"
