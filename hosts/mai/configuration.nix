{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/profiles/host-common.nix
  ];

  services.flatpak.enable = true;
  services.packagekit.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.3.4"
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
    # Override DM's XDG_DATA_DIRS (used for sessions) and append Flatpak exports
    # so launchers like Wofi (drun) can see Flatpak .desktop entries.
    XDG_DATA_DIRS = lib.mkForce [
      "${config.services.displayManager.sessionData.desktops}/share"
      "/run/current-system/sw/share"
      "/etc/profiles/per-user/${username}/share"
      "/var/lib/flatpak/exports/share"
      "${config.users.users.${username}.home}/.local/share/flatpak/exports/share"
    ];
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
    beekeeper-studio
    flatpak
    gnome-software
  ];
}
