#!/usr/bin/env bash

# Catppuccin Mocha Color Palette can be changed acc to needs use a neovim/vscode extension for colors
export BAR_COLOR=0xff1e1e2e
export POPUP_BACKGROUND=0xff181825
export BORDER_COLOR=0xff11111b
export TEXT_COLOR=0xffcdd6f4
export INACTIVE_COLOR=0xff6c7086
export SURFACE_COLOR=0xff313244
export ICON_DARK_COLOR=0xff11111b
export BAR_BORDER_COLOR=0x33cdd6f4
export SAPPHIRE=0xff74c7ec
export YELLOW=0xfff9e2af

export PILL_INACTIVE=0x44313244
export PILL_ACTIVE=0xff45475a

# Animation durations are frame counts at 60 hz
export HOVER_ANIMATION_FRAMES=10
export WORKSPACE_ANIMATION_FRAMES=14
export VALUE_ANIMATION_FRAMES=12

# Reused by every item
export HOVER_ENTER_SCRIPT="sketchybar --animate sin $HOVER_ANIMATION_FRAMES --set \$NAME background.color=$PILL_ACTIVE"
export HOVER_EXIT_SCRIPT="sketchybar --animate sin $HOVER_ANIMATION_FRAMES --set \$NAME background.color=$SURFACE_COLOR"

export MAUVE=0xffcba6f7
export BLUE=0xff89b4fap
export GREEN=0xffa6e3a1
export PEACH=0xfffab387
export RED=0xfff38ba8

# Typography Specifications
export FONT_FAMILY="JetBrainsMono Nerd Font"
export FONT_TEXT="JetBrainsMono Nerd Font:Bold:12.0"
export FONT_ICON="JetBrainsMono Nerd Font:Regular:14.0"
export FONT_DISPLAY="JetBrainsMono Nerd Font:ExtraBold:14.0"
