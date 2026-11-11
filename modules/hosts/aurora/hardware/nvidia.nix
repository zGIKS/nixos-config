{ config, lib, ... }:

let
  cfg = config.myModules.hardware.nvidia;
in
{
  options.myModules.hardware.nvidia = {
    enable = lib.mkEnableOption "NVIDIA proprietary driver stack with Prime offload";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      # stable (595.71.05) does not compile on Linux 7.2+: os-interface.c calls
      # strncpy without a declaration. 610.57.04 replaced it with strscpy.
      # https://github.com/NixOS/nixpkgs/issues/554125
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "610.57.04";
        sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
        sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
        openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
        settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
        persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
      };

      powerManagement = {
        enable = true;
        finegrained = true;
      };

      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    # Session workarounds required for NVIDIA + Sway
    programs.sway.extraOptions = [ "--unsupported-gpu" ];
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  };
}
