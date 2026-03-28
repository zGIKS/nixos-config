#!/usr/bin/env sh

if ! pgrep -x eww >/dev/null 2>&1; then
  eww daemon >/dev/null 2>&1 &
  sleep 0.2
fi

if eww active-windows 2>/dev/null | grep -Eq '^(settings|settings_backdrop):'; then
  sh ~/.config/eww/components/settings/close.sh
else
  eww open-many settings_backdrop settings >/dev/null 2>&1 || {
    eww open settings_backdrop >/dev/null 2>&1
    eww open settings >/dev/null 2>&1
  }
  swaymsg mode settings >/dev/null 2>&1 || true
fi
