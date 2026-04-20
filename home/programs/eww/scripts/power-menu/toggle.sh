#!/usr/bin/env sh

if ! pgrep -x eww >/dev/null 2>&1; then
  eww daemon >/dev/null 2>&1 &
  sleep 0.2
fi

if eww active-windows 2>/dev/null | grep -Eq '^power_menu:'; then
  sh ~/.config/eww/scripts/power-menu/close.sh
else
  eww open power_menu >/dev/null 2>&1
fi
