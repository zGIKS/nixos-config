{ config, lib, pomodog, roles, pkgs, ... }:

let
  cfg = config.myModules.profiles.tools.pomodog;
in
{
  options.myModules.profiles.tools.pomodog.enable = lib.mkEnableOption "Pomodog desktop tool" // {
    default = lib.elem "desktop" roles;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pomodog.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
