{ config, lib, pomodog, roles, pkgs, ... }:

let
  cfg = config.myModules.profiles.productivity;
in
{
  options.myModules.profiles.productivity.pomodog.enable = lib.mkEnableOption "Pomodog desktop tool" // {
    default = lib.elem "desktop" roles;
  };

  config = lib.mkIf (cfg.enable && cfg.pomodog.enable) {
    environment.systemPackages = [
      pomodog.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
