{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.editors;
in
{
  options.myModules.profiles.editors.wpsoffice.enable =
    lib.mkEnableOption "WPS Office suite" // {
      default = true;
    };

  config = lib.mkIf (cfg.enable && cfg.wpsoffice.enable) {
    environment.systemPackages = [ pkgs.wpsoffice ];
  };
}