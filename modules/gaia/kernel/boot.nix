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

  # Use the default kernel package from NixOS.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;
}
