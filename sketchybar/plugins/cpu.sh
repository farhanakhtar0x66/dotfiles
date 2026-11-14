#!/bin/zsh -f
# CPU + RAM plugin — one ~4ms `sysstat` call updates both pills.
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"
handle_hover

if [[ -x $HOME/.local/bin/sysstat ]]; then
  read -r cpu ram <<< "$($HOME/.local/bin/sysstat)"
else   # fallback if the helper isn't built yet (slower)
  cpu=$(ps -A -o %cpu= | awk -v n=$(sysctl -n hw.logicalcpu) '{s+=$1} END {printf "%d", s/n}')
  ram=$(vm_stat | awk '/page size of/{p=$8} /Pages active/{a=$3} /Pages wired down/{w=$4} /occupied by compressor/{c=$5} END{printf "%.1f", (a+w+c)*p/1073741824}')
fi
[[ -n $cpu ]] || exit 0
printf -v cpu '%02d' $cpu
sketchybar --set cpu icon="${cpu}%" --set ram icon="${ram} GB"
