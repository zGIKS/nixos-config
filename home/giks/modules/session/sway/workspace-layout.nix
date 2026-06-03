{ lib, pkgs, roles, ... }:

let
  swayWorkspaceLayout = pkgs.writeShellApplication {
    name = "sway-workspace-layout";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      jq
      sway
      util-linux
    ];
    text = ''
      set -euo pipefail

      main_workspace_count=9
      external_workspace_base=10

      log() {
        printf 'sway-workspace-layout: %s\n' "$*" >&2
      }

      connected_internal_outputs() {
        local connector_path connector status_path status

        for connector_path in /sys/class/drm/card*-*; do
          status_path="$connector_path/status"
          [ -r "$status_path" ] || continue

          connector="''${connector_path##*/}"
          connector="''${connector#card*-}"
          status="$(<"$status_path")"

          case "$connector" in
            eDP-*|LVDS-*|DSI-*)
              [ "$status" = "connected" ] && printf '%s\n' "$connector"
              ;;
          esac
        done
      }

      active_outputs_json() {
        swaymsg -t get_outputs --raw
      }

      focused_workspace() {
        swaymsg -t get_workspaces --raw \
          | jq -r '.[] | select(.focused) | .name' \
          | head -n 1
      }

      choose_primary_output() {
        local outputs_json="$1"
        local output

        while IFS= read -r output; do
          [ -n "$output" ] || continue

          if jq -e --arg output "$output" \
            '.[] | select(.active and .name == $output)' \
            <<< "$outputs_json" >/dev/null; then
            printf '%s\n' "$output"
            return 0
          fi
        done < <(connected_internal_outputs)

        output="$(jq -r \
          '.[] | select(.active and (.name | test("^(eDP|LVDS|DSI)-"))) | .name' \
          <<< "$outputs_json" \
          | head -n 1)"
        if [ -n "$output" ]; then
          printf '%s\n' "$output"
          return 0
        fi

        jq -r '.[] | select(.active) | .name' <<< "$outputs_json" | head -n 1
      }

      apply_layout() {
        local outputs_json primary_output current_workspace
        local workspace output external_workspace max_external_workspace restore_workspace
        local -a active_outputs external_outputs

        outputs_json="$(active_outputs_json)"
        primary_output="$(choose_primary_output "$outputs_json")"

        if [ -z "$primary_output" ]; then
          log "no active outputs found"
          return 0
        fi

        mapfile -t active_outputs < <(
          jq -r '.[] | select(.active) | .name' <<< "$outputs_json" | sort
        )
        mapfile -t external_outputs < <(
          printf '%s\n' "''${active_outputs[@]}" | awk -v primary="$primary_output" '$0 != primary'
        )

        current_workspace="$(focused_workspace || true)"

        for workspace in $(seq 1 "$main_workspace_count"); do
          swaymsg --quiet -- "workspace $workspace output $primary_output"
        done

        external_workspace="$external_workspace_base"
        for output in "''${external_outputs[@]}"; do
          swaymsg --quiet -- "workspace $external_workspace output $output"
          swaymsg --quiet -- "workspace number $external_workspace"
          swaymsg --quiet -- "move workspace to output $output"
          external_workspace=$((external_workspace + 1))
        done

        max_external_workspace=$((external_workspace - 1))
        restore_workspace="$current_workspace"
        if [[ "$current_workspace" =~ ^[0-9]+$ ]] \
          && [ "$current_workspace" -gt "$max_external_workspace" ]; then
          restore_workspace="1"
        fi

        if [ -n "$restore_workspace" ]; then
          swaymsg --quiet -- "workspace $restore_workspace"
        else
          swaymsg --quiet -- "workspace number 1"
        fi
      }

      watch_layout() {
        local lock_file="''${XDG_RUNTIME_DIR:-/tmp}/sway-workspace-layout.lock"

        exec 9>"$lock_file"
        flock -n 9 || exit 0

        apply_layout

        swaymsg -t subscribe -m '["output"]' \
          | while IFS= read -r _event; do
              sleep 0.5
              apply_layout
            done
      }

      case "''${1:-apply}" in
        --watch)
          watch_layout
          ;;
        apply)
          apply_layout
          ;;
        *)
          printf 'usage: %s [apply|--watch]\n' "$0" >&2
          exit 2
          ;;
      esac
    '';
  };

  swayWorkspaceCycle = pkgs.writeShellApplication {
    name = "sway-workspace-cycle";
    runtimeInputs = with pkgs; [ jq sway ];
    text = ''
      set -euo pipefail

      direction="''${1:-}"
      if [[ "$direction" != "next" && "$direction" != "prev" ]]; then
        printf 'usage: %s {next|prev}\n' "$(basename "$0")" >&2
        exit 2
      fi

      current=$(swaymsg -t get_workspaces --raw | jq '.[] | select(.focused) | .num // empty')
      if [[ -z "$current" ]]; then
        current=1
      fi

      if [[ "$direction" == "next" ]]; then
        target=$(( current >= 9 ? 1 : current + 1 ))
      else
        target=$(( current <= 1 ? 9 : current - 1 ))
      fi

      swaymsg --quiet "workspace number $target"
    '';
  };
in
{
  config.home.packages =
    lib.optionals (lib.elem "desktop" roles) [
      swayWorkspaceLayout
      swayWorkspaceCycle
    ];
}
