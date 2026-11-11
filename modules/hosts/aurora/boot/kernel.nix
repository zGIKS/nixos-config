{ config, lib, pkgs, ... }:

{
  # Pin below linuxPackages_latest: newer kernels have been incompatible
  # with the NVIDIA driver version used by this host. 7.0 through 7.2 reached
  # upstream end of life and were removed from nixpkgs, so 7.3 is the oldest
  # 7.x series left.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_7_3;

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
