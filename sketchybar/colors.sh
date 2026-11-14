#!/usr/bin/env bash

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# Zacess High Contrast Dark palette (variable names kept from the original layout)
export BAR_COLOR=0xa6000000   # 65% black, blurred → translucent
export POPUP_BACKGROUND=0xff0b0b0b
export BORDER_COLOR=0xff000000
export TEXT_COLOR=0xffffffff
export INACTIVE_COLOR=0xff8a8a8a
export SURFACE_COLOR=0xe61a1a1a
export ICON_DARK_COLOR=0xff000000
export BAR_BORDER_COLOR=0x33ffffff
export SAPPHIRE=0xff00f4e0
export YELLOW=0xfff5c400

export PILL_INACTIVE=0x441a1a1a
export PILL_ACTIVE=0xf0333333

# Animation durations are frame counts at 60 hz
export HOVER_ANIMATION_FRAMES=10
export WORKSPACE_CURVE=sin
export WORKSPACE_ANIMATION_FRAMES=14
export VALUE_ANIMATION_FRAMES=12

export MAUVE=0xfff2a6ff
export BLUE=0xff8fd0ff
export GREEN=0xff26f444
export PEACH=0xfff5c400
export RED=0xffff9e94

# Typography Specifications
export FONT_FAMILY="JetBrainsMono Nerd Font"
export FONT_TEXT="JetBrainsMono Nerd Font:Bold:14.0"
export FONT_ICON="JetBrainsMono Nerd Font:Regular:16.0"
export FONT_DISPLAY="JetBrainsMono Nerd Font:ExtraBold:16.0"
export FONT_APP="sketchybar-app-font:Regular:16.0"

# Hover: sketchybar sends mouse.entered/exited to the item's own script, so every
# plugin calls this first. (The old mouse.entered_script property doesn't exist.)
handle_hover() {
  case "$SENDER" in
    mouse.entered) sketchybar --animate sin "$HOVER_ANIMATION_FRAMES" --set "$NAME" background.color="$PILL_ACTIVE"; exit 0 ;;
    mouse.exited)  sketchybar --animate sin "$HOVER_ANIMATION_FRAMES" --set "$NAME" background.color="$SURFACE_COLOR"; exit 0 ;;
  esac
}
