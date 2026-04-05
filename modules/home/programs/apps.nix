{ config, lib, pkgs, roles, ... }:

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
    lib.optionals cfg.base.enable [
      brightnessctl
      grim
      gsimplecal
      nautilus
      pavucontrol
      slurp
      sway-contrib.grimshot
      swappy
      yazi
      wl-clipboard
      wofi
      kdePackages.ark
    ]
    ++ lib.optionals cfg.browsers.enable [
      brave
    ]
    ++ lib.optionals cfg.media.enable [
      discord
      spotify
    ]
    ++ lib.optionals cfg.documents.enable [
      typora
      kdePackages.okular
    ]
    ++ lib.optionals cfg.devGui.enable [
      jetbrains.datagrip
      android-studio
    ]
    ++ lib.optionals cfg.devTools.enable [
      vscode
      zellij
    ];
}
