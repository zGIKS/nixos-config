#!/usr/bin/env bash

set -euo pipefail

source "${HOME}/.config/eww/components/shared/osd-utils.sh"

action="${1:-show}"
hide_pid_file="/tmp/eww-brightness-osd-hide.pid"

case "$action" in
  up)
    brightnessctl set 5%+ >/dev/null
    ;;
  down)
    brightnessctl set 5%- >/dev/null
    ;;
  show)
    ;;
  *)
    exit 1
    ;;
esac

ensure_eww_daemon

current="$(brightnessctl get)"
maximum="$(brightnessctl max)"

if [ "$maximum" -eq 0 ]; then
  brightness_percent=0
else
  brightness_percent="$(awk -v c="$current" -v m="$maximum" 'BEGIN { printf("%d", ((c / m) * 100) + 0.5) }')"
fi

if [ "$brightness_percent" -lt 0 ]; then
  brightness_percent=0
fi

if [ "$brightness_percent" -gt 100 ]; then
  brightness_percent=100
fi

run_eww update brightness="$brightness_percent" brightness_text="${brightness_percent}%" brightness_icon="󰃠" || true
run_eww open brightness-osd || true
debounced_close "brightness-osd" "$hide_pid_file" 1.1
