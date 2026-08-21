#!/usr/bin/env bash
# CPU plugin
CORE_COUNT=$(sysctl -n hw.logicalcpu)
CPU_INFO=$(ps -Ao %cpu= | awk '{s+=$1} END {print s}')
CPU_USAGE=$(echo "$CPU_INFO $CORE_COUNT" | awk '{printf "%02.0f\n", $1/$2}')

sketchybar --set "$NAME" icon="${CPU_USAGE}%"
