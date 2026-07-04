{ ... }:

{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig."10-alsa-stability" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "device.name" = "~alsa_card.*";
            }
          ];
          actions = {
            update-props = {
              # Keep the card awake and avoid flaky hardware volume paths.
              "session.suspend-timeout-seconds" = 0;
              "api.alsa.soft-mixer" = true;
            };
          };
        }
      ];
    };
    wireplumber.extraConfig."20-bluetooth-stability" = {
      "monitor.bluez.properties" = {
        # Keep headset switching predictable across A2DP and hands-free modes.
        "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        "bluez5.hfphsp-backend" = "native";
        "bluez5.enable-msbc" = true;
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-hw-volume" = true;
      };
    };
  };
}
