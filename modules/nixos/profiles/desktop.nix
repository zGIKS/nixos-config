{ config, lib, pkgs, ... }:

{
  options.myModules.profiles.desktop.enable = lib.mkEnableOption "desktop profile";

  config = lib.mkIf config.myModules.profiles.desktop.enable {
    environment.systemPackages = with pkgs; [
      bluez
      brightnessctl
      eww
      gsimplecal
      google-java-format
      networkmanager
      waybar
      wireplumber
      wofi
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}
