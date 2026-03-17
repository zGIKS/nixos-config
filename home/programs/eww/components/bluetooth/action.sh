#!/usr/bin/env bash

set -euo pipefail

source "${HOME}/.config/eww/components/shared/osd-utils.sh"

action="${1:-toggle-panel}"
mac="${2:-}"

toggle_power() {
  if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    bluetoothctl power off >/dev/null
  else
    bluetoothctl power on >/dev/null
  fi
}

scan_devices() {
  bluetoothctl power on >/dev/null 2>&1 || true
  bluetoothctl scan on >/dev/null 2>&1 || true
  sleep 8
  bluetoothctl scan off >/dev/null 2>&1 || true
}

toggle_connection() {
  local info

  if [ -z "$mac" ]; then
    exit 1
  fi

  bluetoothctl power on >/dev/null 2>&1 || true
  info="$(bluetoothctl info "$mac" 2>/dev/null || true)"

  if grep -q "Connected: yes" <<< "$info"; then
    bluetoothctl disconnect "$mac" >/dev/null
    return 0
  fi

  if ! grep -q "Paired: yes" <<< "$info"; then
    bluetoothctl pair "$mac" >/dev/null 2>&1 || true
  fi

  bluetoothctl trust "$mac" >/dev/null 2>&1 || true
  bluetoothctl connect "$mac" >/dev/null
}

case "$action" in
  open)
    ensure_eww_daemon
    run_eww open bluetooth-panel || true
    ;;
  close)
    ensure_eww_daemon
    run_eww close bluetooth-panel || true
    ;;
  toggle-panel)
    ensure_eww_daemon
    if eww active-windows 2>/dev/null | grep -q 'bluetooth-panel'; then
      run_eww close bluetooth-panel || true
    else
      run_eww open bluetooth-panel || true
    fi
    ;;
  toggle-power)
    toggle_power
    ;;
  scan)
    scan_devices
    ;;
  connect)
    toggle_connection
    ;;
  *)
    exit 1
    ;;
esac
