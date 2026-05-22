{ config, lib, pkgs, ... }:

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
      package = config.boot.kernelPackages.nvidiaPackages.stable;

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
