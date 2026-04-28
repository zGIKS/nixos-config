{ config, lib, pkgs, pomodog, roles, ... }:

let
  cfg = config.myHome.apps;
in
{
  options.myHome.apps = {
    base.enable = lib.mkEnableOption "base desktop applications" // {
      default = lib.elem "desktop" roles;
    };
    browsers.enable = lib.mkEnableOption "web browsers" // {
      default = lib.elem "desktop" roles;
    };
    media.enable = lib.mkEnableOption "media and chat desktop applications" // {
      default = lib.elem "desktop" roles;
    };
    documents.enable = lib.mkEnableOption "document and archive desktop applications" // {
      default = lib.elem "desktop" roles;
    };
    devGui.enable = lib.mkEnableOption "heavy GUI development applications" // {
      default = false;
    };
    devTools.enable = lib.mkEnableOption "development desktop applications" // {
      default = lib.elem "dev" roles;
    };
  };

  config.home.packages = with pkgs;
    [
      pomodog.packages.${pkgs.system}.default
    ]
    ++ lib.optionals cfg.base.enable [
      brightnessctl
      grim
      gsimplecal
      xfce.thunar
      pavucontrol
      playerctl
      slurp
      sway-contrib.grimshot
      swappy
      wdisplays
      yazi
      wl-clipboard
      wofi
      kdePackages.ark
    ]
    ++ lib.optionals cfg.browsers.enable [
      brave
      google-chrome
    ]
    ++ lib.optionals cfg.media.enable [
      discord
      mpv
      obs-studio
      rustdesk-flutter
      spotify
    ]
    ++ lib.optionals cfg.documents.enable [
      typora
    ]
    ++ lib.optionals cfg.devGui.enable [
      jetbrains.idea
      jetbrains.datagrip
      android-studio
    ]
    ++ lib.optionals cfg.devTools.enable [
      vscode
      zed-editor
      zellij
    ];
}
