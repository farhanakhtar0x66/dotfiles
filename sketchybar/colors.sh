#!/usr/bin/env bash

# GitHub Dark Palette
export BAR_COLOR=0xff000000
export POPUP_BACKGROUND=0xff161b22
export BORDER_COLOR=0xff30363d
export TEXT_COLOR=0xffc9d1d9
export INACTIVE_COLOR=0xff8b949e
export SURFACE_COLOR=0xff21262d
export ICON_DARK_COLOR=0xff0d1117
export BAR_BORDER_COLOR=0x4030363d
export PILL_BORDER_COLOR=0x2630363d
export SAPPHIRE=0xff388bfd
export YELLOW=0xffe3b341

export PILL_INACTIVE=0x20ffffff
export PILL_ACTIVE=0xff30363d

# Animation durations are frame counts at 60 hz
export HOVER_ANIMATION_FRAMES=10
export WORKSPACE_ANIMATION_FRAMES=14
export VALUE_ANIMATION_FRAMES=12

# Reused by every item
export HOVER_ENTER_SCRIPT="sketchybar --animate sin $HOVER_ANIMATION_FRAMES --set \$NAME background.color=$PILL_ACTIVE"
export HOVER_EXIT_SCRIPT="sketchybar --animate sin $HOVER_ANIMATION_FRAMES --set \$NAME background.color=$SURFACE_COLOR"

export MAUVE=0xffd2a8ff
export BLUE=0xff58a6ff
export GREEN=0xff56d364
export PEACH=0xffffa657
export RED=0xffff7b72

# Typography Specifications
export FONT_FAMILY="JetBrainsMono Nerd Font"
export FONT_TEXT="JetBrainsMono Nerd Font:Bold:12.0"
export FONT_ICON="JetBrainsMono Nerd Font:Regular:14.0"
export FONT_DISPLAY="JetBrainsMono Nerd Font:ExtraBold:14.0"
