{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/profiles/host-common.nix
  ];

  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  programs.rog-control-center = {
    enable = true;
    autoStart = true;
  };

  programs.sway.extraOptions = [ "--unsupported-gpu" ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  services.supergfxd.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  environment.systemPackages = with pkgs; [
    supergfxctl
  ];
}
