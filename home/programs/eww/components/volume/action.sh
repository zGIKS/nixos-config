#!/usr/bin/env bash

set -euo pipefail

source "${HOME}/.config/eww/components/shared/osd-utils.sh"

action="${1:-show}"
sink="@DEFAULT_AUDIO_SINK@"
hide_pid_file="/tmp/eww-volume-osd-hide.pid"

case "$action" in
  up)
    wpctl set-volume -l 1.0 "$sink" 5%+
    ;;
  down)
    wpctl set-volume -l 1.0 "$sink" 5%-
    ;;
  mute)
    wpctl set-mute "$sink" toggle
    ;;
  show)
    ;;
  *)
    exit 1
    ;;
esac

ensure_eww_daemon

volume_line="$(wpctl get-volume "$sink")"
volume_value="$(awk '{print $2}' <<< "$volume_line")"
is_muted=0

if grep -q "MUTED" <<< "$volume_line"; then
  is_muted=1
fi

volume_percent="$(awk -v v="$volume_value" 'BEGIN { printf("%d", (v * 100) + 0.5) }')"

if [ "$volume_percent" -lt 0 ]; then
  volume_percent=0
fi

if [ "$volume_percent" -gt 100 ]; then
  volume_percent=100
fi

if [ "$is_muted" -eq 1 ] || [ "$volume_percent" -eq 0 ]; then
  volume_icon="󰖁"
elif [ "$volume_percent" -lt 34 ]; then
  volume_icon="󰕿"
elif [ "$volume_percent" -lt 67 ]; then
  volume_icon="󰖀"
else
  volume_icon="󰕾"
fi

run_eww update volume="$volume_percent" volume_text="${volume_percent}%" volume_icon="$volume_icon" || true
run_eww open volume-osd || true
debounced_close "volume-osd" "$hide_pid_file" 1.1
