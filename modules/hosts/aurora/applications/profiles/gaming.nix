{ config, lib, ... }:

let
  cfg = config.myModules.profiles.gaming;
in
{
  options.myModules.profiles.gaming = {
    enable = lib.mkEnableOption "gaming profile";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
