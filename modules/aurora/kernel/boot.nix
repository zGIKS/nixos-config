{ lib, pkgs, ... }:

{
  boot.loader = {
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 8;
    };

    systemd-boot.enable = false;
    timeout = 3;
  };

  # Track the latest stable kernel provided by the pinned nixpkgs.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
}
