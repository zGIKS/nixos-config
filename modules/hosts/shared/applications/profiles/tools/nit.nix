{ config, lib, nit, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.tools.nit;
in
{
  options.myModules.profiles.tools.nit.enable = lib.mkEnableOption "Nit development tool" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      nit.packages.${pkgs.stdenv.hostPlatform.system}.nit
    ];
  };
}
