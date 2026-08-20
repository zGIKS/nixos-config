{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.development;
in
{
  options.myModules.profiles.development.cli.enable = lib.mkEnableOption "development CLI applications" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf (cfg.enable && cfg.cli.enable) {
    environment.systemPackages = with pkgs; [
      gnumake
      gnutar
      vscode
      zellij
    ];
  };
}
