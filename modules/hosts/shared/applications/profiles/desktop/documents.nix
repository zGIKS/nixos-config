{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.desktopApps;
in
{
  options.myModules.profiles.desktopApps.documents.enable = lib.mkEnableOption "document applications" // {
    default = lib.elem "desktop" roles;
  };

  config = lib.mkIf (cfg.enable && cfg.documents.enable) {
    environment.systemPackages = with pkgs; [
      typora
    ];
  };
}
