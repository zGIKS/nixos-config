{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.languages.go;
in
{
  options.myModules.profiles.languages.go.enable = lib.mkEnableOption "Go development tools" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      go
      go-swag
    ];
  };
}
