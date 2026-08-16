{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.desktopApps;
in
{
  options.myModules.profiles.desktopApps.browsers.brave.enable = lib.mkEnableOption "brave browser" // {
    default = lib.elem "desktop" roles;
  };

  config = lib.mkIf (cfg.enable && cfg.browsers.brave.enable) {
    environment.systemPackages = with pkgs; [
      brave
    ];
  };
}
