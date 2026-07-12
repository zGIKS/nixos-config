{ config, lib, ... }:

let
  cfg = config.myModules.hardware.steam;
in
{
  options.myModules.hardware.steam = {
    enable = lib.mkEnableOption "Steam hardware support";
  };

  config = lib.mkIf cfg.enable {
    hardware.steam-hardware.enable = true;
  };
}
