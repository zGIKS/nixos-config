{ config, lib, pkgs, ... }:

{
  options.myModules.profiles.desktop.enable = lib.mkEnableOption "desktop profile";

  config = lib.mkIf config.myModules.profiles.desktop.enable {
    fonts.packages = with pkgs; [
      inter
      material-design-icons
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      unifont
    ];

    fonts.fontconfig.defaultFonts = {
      sansSerif = [
        "JetBrainsMono Nerd Font"
        "Inter"
        "Noto Sans"
        "Noto Sans CJK SC"
        "Noto Color Emoji"
        "DejaVu Sans"
        "Unifont"
      ];
      serif = [
        "JetBrainsMono Nerd Font"
        "Noto Serif"
        "Noto Serif CJK SC"
        "DejaVu Serif"
        "Unifont"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono"
        "DejaVu Sans Mono"
        "Noto Color Emoji"
        "Unifont"
        "Monospace"
      ];
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
