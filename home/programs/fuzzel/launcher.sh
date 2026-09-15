#!/usr/bin/env sh

if pgrep -x fuzzel >/dev/null 2>&1; then
  pkill -x fuzzel >/dev/null 2>&1 || true
  exit 0
fi

exec fuzzel
