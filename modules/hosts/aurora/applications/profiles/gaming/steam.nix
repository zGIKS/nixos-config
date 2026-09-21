{ config, lib, ... }:

let
  cfg = config.myModules.profiles.gaming;
in
{
  options.myModules.profiles.gaming.steam.enable =
    lib.mkEnableOption "Steam client" // {
      default = true;
    };

  config = lib.mkIf (cfg.enable && cfg.steam.enable) {
    programs.steam.enable = true;
  };
}