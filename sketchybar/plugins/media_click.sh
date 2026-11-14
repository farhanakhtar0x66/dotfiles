#!/usr/bin/env bash
# Media click: play/pause, then redraw from the real player state.
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
export PATH="/opt/homebrew/bin:$PATH"
media-control toggle-play-pause
sleep 0.2
NAME=media SENDER=forced "$CONFIG_DIR/plugins/media.sh"
