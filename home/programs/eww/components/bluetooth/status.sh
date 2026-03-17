#!/usr/bin/env bash

set -euo pipefail

mode="${1:-panel}"

escape_yuck() {
  local value="${1:-}"
  value="${value//$'\\'/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/ }"
  value="${value//$'\t'/ }"
  printf '%s' "$value"
}

controller_show() {
  bluetoothctl show 2>/dev/null || true
}

device_info() {
  local mac="$1"
  bluetoothctl info "$mac" 2>/dev/null || true
}

field_value() {
  local field="$1"
  awk -F': ' -v key="$field" '$1 == key { print $2; exit }'
}

is_powered() {
  controller_show | grep -q "Powered: yes"
}

is_discovering() {
  controller_show | grep -q "Discovering: yes"
}

connected_count() {
  local count=0
  local line mac info

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    mac="${line#Device }"
    mac="${mac%% *}"
    info="$(device_info "$mac")"
    if grep -q "Connected: yes" <<< "$info"; then
      count=$((count + 1))
    fi
  done < <(bluetoothctl devices 2>/dev/null || true)

  printf '%s' "$count"
}

panel_markup() {
  local show_info powered discovering controller alias address title subtitle icon
  local power_label power_icon power_class scan_label device_lines
  local line mac name info device_alias connected paired trusted type_icon status_label meta_label action_label action_class escaped_name escaped_meta escaped_status escaped_mac

  show_info="$(controller_show)"
  powered="false"
  discovering="false"
  icon="󰂲"
  title="Bluetooth apagado"
  subtitle="Actívalo para buscar dispositivos"

  if is_powered; then
    powered="true"
    icon=""
    title="Bluetooth activo"
    subtitle="Listo para conectar dispositivos"
  fi

  if is_discovering; then
    discovering="true"
    subtitle="Buscando dispositivos cercanos"
  fi

  alias="$(field_value Alias <<< "$show_info")"
  address="$(sed -n 's/^Controller \([^ ]*\).*/\1/p' <<< "$show_info" | head -n 1)"

  if [ -n "$alias" ] && [ -n "$address" ]; then
    subtitle="$alias • $address"
  elif [ -n "$alias" ]; then
    subtitle="$alias"
  elif [ -n "$address" ]; then
    subtitle="$address"
  fi

  if [ "$discovering" = "true" ] && [ -n "$subtitle" ]; then
    subtitle="Buscando... • $subtitle"
  fi

  if [ "$discovering" = "true" ]; then
    icon="󰂯"
  elif [ "$(connected_count)" -gt 0 ]; then
    icon="󰂱"
  elif [ "$powered" = "false" ]; then
    icon="󰂲"
  fi

  if [ "$powered" = "true" ]; then
    power_label="Apagar"
    power_icon="󰂯"
    power_class="bt-button bt-button-primary"
  else
    power_label="Encender"
    power_icon="󰂯"
    power_class="bt-button"
  fi

  if [ "$discovering" = "true" ]; then
    scan_label="Buscando..."
  else
    scan_label="Buscar"
  fi

  printf '(box :class "bt-panel" :orientation "v" :spacing 0\n'
  printf '  (box :class "bt-header" :orientation "h" :space-evenly false :spacing 12\n'
  printf '    (label :class "bt-header-icon" :text "%s")\n' "$(escape_yuck "$icon")"
  printf '    (box :orientation "v" :hexpand true :space-evenly false\n'
  printf '      (label :class "bt-title" :xalign 0 :text "%s")\n' "$(escape_yuck "$title")"
  printf '      (label :class "bt-subtitle" :xalign 0 :wrap true :text "%s"))\n' "$(escape_yuck "$subtitle")"
  printf '    (button :class "bt-close" :onclick "bash ~/.config/eww/components/bluetooth/action.sh close"\n'
  printf '      (label :text "󰅖")))\n'

  printf '  (box :class "bt-toolbar" :orientation "h" :space-evenly false :spacing 8\n'
  printf '    (button :class "%s" :onclick "bash ~/.config/eww/components/bluetooth/action.sh toggle-power"\n' "$power_class"
  printf '      (label :text "%s %s"))\n' "$(escape_yuck "$power_icon")" "$(escape_yuck "$power_label")"
  printf '    (button :class "bt-button" :onclick "bash ~/.config/eww/components/bluetooth/action.sh scan"\n'
  printf '      (label :text "󰑐 %s")))\n' "$(escape_yuck "$scan_label")"

  printf '  (box :class "bt-device-list" :orientation "v" :space-evenly false :spacing 8\n'

  mapfile -t device_lines < <(bluetoothctl devices 2>/dev/null || true)

  if [ "${#device_lines[@]}" -eq 0 ]; then
    printf '    (label :class "bt-device-empty" :xalign 0 :text "No hay dispositivos guardados todavía. Usa Buscar para detectar algunos."))\n'
    printf ')' 
    return 0
  fi

  for line in "${device_lines[@]}"; do
    [ -n "$line" ] || continue
    mac="${line#Device }"
    mac="${mac%% *}"
    name="${line#Device $mac }"
    info="$(device_info "$mac")"

    device_alias="$(field_value Alias <<< "$info")"
    if [ -z "$device_alias" ]; then
      device_alias="$name"
    fi
    if [ -z "$device_alias" ]; then
      device_alias="$mac"
    fi

    connected="no"
    paired="no"
    trusted="no"

    if grep -q "Connected: yes" <<< "$info"; then
      connected="yes"
    fi
    if grep -q "Paired: yes" <<< "$info"; then
      paired="yes"
    fi
    if grep -q "Trusted: yes" <<< "$info"; then
      trusted="yes"
    fi

    case "$(field_value Icon <<< "$info")" in
      phone)
        type_icon="󰏲"
        ;;
      audio-headset)
        type_icon="󰋋"
        ;;
      audio-card)
        type_icon="󰓃"
        ;;
      input-keyboard)
        type_icon="󰌓"
        ;;
      input-mouse)
        type_icon="󰍽"
        ;;
      input-gaming)
        type_icon="󰊴"
        ;;
      video-display)
        type_icon="󰍹"
        ;;
      camera-video)
        type_icon="󰄀"
        ;;
      *)
        type_icon=""
        ;;
    esac

    status_label="Disponible"
    if [ "$connected" = "yes" ]; then
      status_label="Conectado"
    elif [ "$paired" = "yes" ]; then
      status_label="Emparejado"
    fi

    meta_label="$mac"
    if [ "$trusted" = "yes" ]; then
      meta_label="$meta_label • confiable"
    fi

    if [ "$connected" = "yes" ]; then
      action_label="Desconectar"
      action_class="bt-device-action bt-device-action-disconnect"
    else
      action_label="Conectar"
      action_class="bt-device-action bt-device-action-connect"
    fi

    escaped_name="$(escape_yuck "$device_alias")"
    escaped_meta="$(escape_yuck "$meta_label")"
    escaped_status="$(escape_yuck "$status_label")"
    escaped_mac="$(escape_yuck "$mac")"

    printf '    (box :class "bt-device" :orientation "h" :space-evenly false :spacing 10\n'
    printf '      (label :class "bt-device-icon" :text "%s")\n' "$(escape_yuck "$type_icon")"
    printf '      (box :orientation "v" :hexpand true :space-evenly false\n'
    printf '        (label :class "bt-device-name" :xalign 0 :text "%s")\n' "$escaped_name"
    printf '        (label :class "bt-device-meta" :xalign 0 :text "%s")\n' "$escaped_meta"
    printf '        (label :class "bt-device-status" :xalign 0 :text "%s"))\n' "$escaped_status"
    printf '      (button :class "%s" :valign "center" :onclick "bash ~/.config/eww/components/bluetooth/action.sh connect %s"\n' "$action_class" "$escaped_mac"
    printf '        (label :text "%s")))\n' "$(escape_yuck "$action_label")"
  done

  printf '  )'
  printf ')'
}

case "$mode" in
  panel)
    panel_markup
    ;;
  *)
    exit 1
    ;;
esac
