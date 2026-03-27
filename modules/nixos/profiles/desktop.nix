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
      sansSerif = [ "JetBrainsMono Nerd Font" "Inter" "DejaVu Sans" "Noto Sans" ];
      serif = [ "JetBrainsMono Nerd Font" "DejaVu Serif" "Noto Serif" ];
      monospace = [ "JetBrainsMono Nerd Font" "DejaVu Sans Mono" "Monospace" ];
    };

    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      bluez
      networkmanager
      wireplumber
    ];

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
}
