{ pkgs, ... }:

let
  audioMixerFix = pkgs.writeShellScript "audio-mixer-fix" ''
    ${pkgs.alsa-utils}/bin/amixer -c 1 sset 'Auto-Mute Mode' Enabled >/dev/null
    ${pkgs.alsa-utils}/bin/amixer -c 1 sset Master 87% unmute >/dev/null
    ${pkgs.alsa-utils}/bin/amixer -c 1 sset Headphone 87% unmute >/dev/null
    ${pkgs.alsa-utils}/bin/amixer -c 1 sset Speaker 87% unmute >/dev/null
    ${pkgs.alsa-utils}/bin/amixer -c 1 sset PCM 100% >/dev/null
  '';

  audioMixerWatch = pkgs.writeShellScript "audio-mixer-watch" ''
    set -eu

    apply() {
      "${audioMixerFix}"
    }

    apply

    "${pkgs.pulseaudio}/bin/pactl" subscribe | while IFS= read -r line; do
      case "$line" in
        *" on card "#*|*" on sink "#*|*" on source "#*)
          apply
          ;;
      esac
    done
  '';
in
{
  systemd.user.services.audio-mixer-watch = {
    description = "Keep ALSA mixer state sane on audio device changes";
    after = [ "pipewire.service" "wireplumber.service" ];
    wants = [ "pipewire.service" "wireplumber.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${audioMixerWatch}";
      Restart = "always";
      RestartSec = "2s";
    };
  };
}
