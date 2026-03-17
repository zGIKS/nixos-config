#!/usr/bin/env bash

set -euo pipefail

ensure_eww_daemon() {
  if ! pgrep -x eww >/dev/null 2>&1; then
    eww daemon >/dev/null 2>&1 &
    sleep 0.08
  fi
}

run_eww() {
  local attempts=3
  local delay=0.05
  local i

  for ((i = 1; i <= attempts; i++)); do
    if eww "$@" >/dev/null 2>&1; then
      return 0
    fi
    sleep "$delay"
  done

  return 1
}

debounced_close() {
  local window_name="$1"
  local pid_file="$2"
  local delay="$3"
  local lock_file="${pid_file}.lock"
  local fd

  exec {fd}> "$lock_file"
  flock -x "$fd"

  if [ -f "$pid_file" ]; then
    local previous_pid
    previous_pid="$(cat "$pid_file" 2>/dev/null || true)"
    if [ -n "$previous_pid" ] && kill -0 "$previous_pid" >/dev/null 2>&1; then
      kill "$previous_pid" >/dev/null 2>&1 || true
    fi
  fi

  (
    sleep "$delay"
    run_eww close "$window_name" || true
  ) &

  echo $! > "$pid_file"
  flock -u "$fd"
}
