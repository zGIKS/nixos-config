{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.desktopApps;
in
{
  options.myModules.profiles.desktopApps.devTools.enable = lib.mkEnableOption "development applications" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf (cfg.enable && cfg.devTools.enable) {
    environment.systemPackages = with pkgs; [
      gnumake
      gnutar
      vscode
      zellij
    ];
  };
}
