{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.kernel.memory;
in
{
  options.myModules.kernel.memory = {
    enable = lib.mkEnableOption "kernel memory tuning (zram, swap, sysctl)";
  };

  config = lib.mkIf cfg.enable {
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
  };
}
