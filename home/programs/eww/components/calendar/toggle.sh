#!/usr/bin/env sh

if ! pgrep -x eww >/dev/null 2>&1; then
  eww daemon >/dev/null 2>&1 &
  sleep 0.2
fi

if eww active-windows 2>/dev/null | grep -Eq '^calendar:'; then
  sh ~/.config/eww/components/calendar/close.sh
else
  eww open calendar >/dev/null 2>&1
fi
