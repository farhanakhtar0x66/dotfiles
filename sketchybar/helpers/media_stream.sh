#!/usr/bin/env bash
# Long-running listener: `media-control stream` pushes now-playing changes, so the bar
# never polls (a poll costs ~0.6s of CPU each time). Started from sketchybarrc.
export PATH="/opt/homebrew/bin:$PATH"
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"

media-control stream --no-diff --no-artwork 2>/dev/null \
  | jq --unbuffered -r --arg us $'\x1f' \
      '(.payload // {}) | [(.title // ""), ((.playing // false) | tostring)] | join($us)' 2>/dev/null \
  | while IFS=$'\x1f' read -r title playing; do
      # Exit with sketchybar so we never leak a listener after the bar quits.
      sketchybar --query bar >/dev/null 2>&1 || exit 0
      MEDIA_TITLE="$title" MEDIA_PLAYING="$playing" NAME=media SENDER=media_stream \
        "$CONFIG_DIR/plugins/media.sh"
    done
