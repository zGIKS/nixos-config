{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.browsers;
in
{
  options.myModules.profiles.browsers.google.enable =
    lib.mkEnableOption "Google Chrome browser" // {
      default = true;
    };

  config = lib.mkIf (cfg.enable && cfg.google.enable) {
    environment.systemPackages = [ pkgs.google-chrome ];
  };
}