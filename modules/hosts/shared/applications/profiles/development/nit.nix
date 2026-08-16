{ config, lib, nit, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.ai;
in
{
  options.myModules.profiles.ai.nit.enable = lib.mkEnableOption "Nit development tool" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf (cfg.enable && cfg.nit.enable) {
    environment.systemPackages = [
      nit.packages.${pkgs.stdenv.hostPlatform.system}.nit
    ];
  };
}
