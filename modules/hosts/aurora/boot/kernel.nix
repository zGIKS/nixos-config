{ config, lib, pkgs, ... }:

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

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  hardware.alsa.enablePersistence = true;

  boot.extraModprobeConfig = ''
    # ASUS ROG Strix G614JI internal speakers can fail to wake without this quirk.
    options snd-hda-intel model=1043:1c9f
  '';

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  swapDevices = [
    { device = "/swapfile"; size = 8 * 1024; }
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
  };
}
