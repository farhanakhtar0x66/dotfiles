#!/bin/zsh -f
# Workspace pills. Two paths, so a workspace switch never waits on a window query:
#   aerospace_workspace_change → repaint from cached icons (no aerospace call before painting)
#   anything else (windows opened/closed/moved, app switched, startup) → debounced icon refresh
CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/helpers/app_icon.sh"
zmodload zsh/zselect

COUNT=9
PERMANENT=5                     # 1-5 always shown; 6-9 only while focused or holding windows
STATE=${TMPDIR:-/tmp}/sketchybar-ws
[[ -d $STATE ]] || mkdir -p $STATE
FOCUS=$STATE/focus ICONS=$STATE/icons LOCK=$STATE/lock DIRTY=$STATE/dirty

# Paint all pills from the focus + icon caches. $1=1 → animate.
paint() {
  local focused sid label vis l
  local -A icons
  local -a a
  read -r focused < $FOCUS 2>/dev/null
  if [[ -r $ICONS ]]; then
    while IFS= read -r l; do icons[${l%%$'\t'*}]=${l#*$'\t'}; done < $ICONS
  fi
  (( $1 )) && a=(--animate $WORKSPACE_CURVE $WORKSPACE_ANIMATION_FRAMES)
  for sid in {1..$COUNT}; do
    label=${icons[$sid]}
    if [[ $sid == $focused ]]; then
      a+=(--set space.$sid drawing=on icon=$sid icon.color=$ICON_DARK_COLOR
          icon.background.color=$PEACH background.color=$SURFACE_COLOR
          label="${label:-—}" label.color=$TEXT_COLOR label.width=dynamic)
    else
      if (( sid <= PERMANENT )) || [[ -n $label ]]; then vis=on; else vis=off; fi
      a+=(--set space.$sid drawing=$vis icon=$sid icon.color=$TEXT_COLOR
          icon.background.color=$SURFACE_COLOR background.color=0x00000000 label.width=0)
    fi
  done
  sketchybar $a
  REPLY=$focused
}

# Re-read which apps live on which workspace (one aerospace call), then repaint.
refresh_icons() {
  local -a rows
  local -A acc
  local r ws app out prev
  typeset -g changed
  rows=(${(ou)${(f)"$(aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null)"}})
  for r in $rows; do
    ws=${r%%|*} app=${r#*|}
    [[ $ws == [1-9] && -n $app ]] || continue
    app_icon $app
    acc[$ws]+="${acc[$ws]:+ }$REPLY"
  done
  for ws in ${(ko)acc}; do out+="$ws"$'\t'"${acc[$ws]}"$'\n'; done
  # Report whether anything changed: repainting unchanged pills without animation would
  # snap them to their end state and cancel a workspace transition that is mid-flight.
  changed=0
  [[ -r $ICONS ]] && prev=$(<$ICONS)
  [[ ${out%$'\n'} != "$prev" ]] && changed=1
  (( changed )) && print -rn -- "$out" >| $ICONS
}

case $SENDER in
  aerospace_workspace_change)
    print -r -- "${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}" >| $FOCUS
    paint 1
    # Overlapping events can finish out of order: confirm against the truth once, off the hot path.
    real=$(aerospace list-workspaces --focused 2>/dev/null)
    if [[ -n $real && $real != $REPLY ]]; then print -r -- $real >| $FOCUS; paint 1; fi
    ;;
  *)
    # Only one refresher at a time; events arriving meanwhile just ask for one more pass.
    stale=($LOCK(N/mm+1)); (( $#stale )) && rmdir $LOCK 2>/dev/null
    if ! mkdir $LOCK 2>/dev/null; then : >| $DIRTY; exit 0; fi
    [[ -s $FOCUS ]] || print -r -- "$(aerospace list-workspaces --focused 2>/dev/null)" >| $FOCUS
    while :; do
      rm -f $DIRTY
      [[ $SENDER == space_windows_change ]] && zselect -t 8      # let aerospace settle (80ms)
      refresh_icons
      # Startup/forced always paints; otherwise only when the icons really changed.
      if (( changed )) || [[ $SENDER == forced || -z $SENDER ]]; then paint 0; fi
      [[ -e $DIRTY ]] || break
    done
    rmdir $LOCK 2>/dev/null
    ;;
esac
