#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/memory_pressure" <<'MOCK'
#!/bin/sh
echo 'System-wide memory free percentage: 50%'
MOCK
cat > "$tmp/sketchybar" <<'MOCK'
#!/bin/sh
printf '%s\n' "$*" > "$OUTPUT"
MOCK
chmod +x "$tmp/memory_pressure" "$tmp/sketchybar"
PATH="$tmp:$PATH" OUTPUT="$tmp/out" NAME=ram bash "$repo/sketchybar/plugins/ram.sh"
grep -q 'icon=50%' "$tmp/out" || { echo 'RAM widget should display measured percentage without assuming capacity' >&2; exit 1; }
echo 'RAM widget displays measured utilization'
