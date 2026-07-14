{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.desktopApps;
in
{
  options.myModules.profiles.desktopApps.browsers.enable = lib.mkEnableOption "web browsers" // {
    default = lib.elem "desktop" roles;
  };

  config = lib.mkIf (cfg.enable && cfg.browsers.enable) {
    environment.systemPackages = with pkgs; [
      brave
    ];
  };
}
