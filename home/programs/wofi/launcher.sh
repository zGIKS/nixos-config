#!/usr/bin/env sh

LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/wofi-launcher.lock"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

if pgrep -x wofi >/dev/null 2>&1 || pgrep -x rofi >/dev/null 2>&1; then
  pkill -x wofi >/dev/null 2>&1 || true
  pkill -x rofi >/dev/null 2>&1 || true
  exit 0
fi

wofi --show drun