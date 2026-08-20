{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.myModules.profiles.desktopApps.enable {
    environment.systemPackages = with pkgs; [
      grim
      slurp
      sway-contrib.grimshot
      swappy
      wl-clipboard
    ];
  };
}
