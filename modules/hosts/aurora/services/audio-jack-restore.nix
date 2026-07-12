{ pkgs, ... }:

let
  restoreAudioJack = pkgs.writeShellScript "aurora-audio-jack-restore" ''
    set -u

    amixer="${pkgs.alsa-utils}/bin/amixer"
    pactl="${pkgs.pulseaudio}/bin/pactl"
    card="PCH"

    set_control() {
      control="$1"
      shift

      if "$amixer" -c "$card" sget "$control" >/dev/null 2>&1; then
        "$amixer" -c "$card" sset "$control" "$@" >/dev/null 2>&1 || true
      fi
    }

    active_port="$("$pactl" list sinks 2>/dev/null \
      | ${pkgs.gawk}/bin/awk '
          /^Sink #/ { in_default = 0 }
          /^[[:space:]]*Name: alsa_output\.pci-0000_00_1f\.3\.analog-stereo$/ { in_default = 1 }
          in_default && /^[[:space:]]*Active Port:/ { print $3; exit }
        ')"

    set_control "Master" 87% unmute
    set_control "PCM" 100%
    set_control "Auto-Mute Mode" Enabled

    case "$active_port" in
      analog-output-headphones)
        set_control "Headphone" 87% unmute
        set_control "Speaker" mute
        ;;
      *)
        set_control "Speaker" 87% unmute
        set_control "Headphone" mute
        ;;
    esac
  '';

  watchAudioJack = pkgs.writeShellScript "aurora-audio-jack-watch" ''
    set -u

    pending=""

    schedule_restore() {
      if [ -n "$pending" ] && kill -0 "$pending" 2>/dev/null; then
        return
      fi

      (
        sleep 0.5
        "${restoreAudioJack}"
      ) &
      pending="$!"
    }

    "${restoreAudioJack}"

    "${pkgs.pulseaudio}/bin/pactl" subscribe | while IFS= read -r line; do
      case "$line" in
        *" on card "#*|*" on sink "#*)
          schedule_restore
          ;;
      esac
    done
  '';
in
{
  systemd.user.services.audio-jack-restore = {
    description = "Restore Aurora ALSA speaker/headphone mixer after jack changes";
    after = [ "pipewire.service" "wireplumber.service" ];
    wants = [ "pipewire.service" "wireplumber.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${watchAudioJack}";
      Restart = "always";
      RestartSec = "2s";
    };
  };
}
