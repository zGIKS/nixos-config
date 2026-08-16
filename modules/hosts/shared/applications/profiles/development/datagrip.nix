{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.development;
in
{
  options.myModules.profiles.development.datagrip.enable = lib.mkEnableOption "DataGrip IDE";

  config = lib.mkIf (cfg.enable && cfg.datagrip.enable) {
    environment.systemPackages = with pkgs; [
      jetbrains.datagrip
    ];
  };
}
