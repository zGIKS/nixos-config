{ config, lib, pkgs, ... }:

{
  options.myModules.profiles.desktop.enable = lib.mkEnableOption "desktop profile";

  config = lib.mkIf config.myModules.profiles.desktop.enable {
    fonts.packages = with pkgs; [
      inter
      material-design-icons
      nerd-fonts.jetbrains-mono
    ];

    fonts.fontconfig.defaultFonts = {
      sansSerif = [ "Inter" "DejaVu Sans" "Noto Sans" ];
      serif = [ "DejaVu Serif" "Noto Serif" ];
      monospace = [ "JetBrainsMono Nerd Font" "DejaVu Sans Mono" "Monospace" ];
    };

    environment.systemPackages = with pkgs; [
      bluez
      networkmanager
      wireplumber
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
