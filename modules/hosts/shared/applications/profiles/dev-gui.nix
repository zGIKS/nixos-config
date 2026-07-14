{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.devGui;
in
{
  options.myModules.profiles.devGui.enable = lib.mkEnableOption "heavy GUI development applications";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      jetbrains.datagrip
    ];
  };
}
