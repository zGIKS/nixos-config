{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.dev;
in
{
  options.myModules.profiles.dev.enable = lib.mkEnableOption "developer profile";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wpsoffice
      zed-editor
      jetbrains.idea
      android-studio
    ];
  };
}
