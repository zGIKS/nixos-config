{ lib, pkgs, roles, ... }:

{
  home.packages = with pkgs;
    lib.optionals (lib.elem "desktop" roles) [
      brightnessctl
      brave
      discord
      google-chrome
      grim
      gsimplecal
      jetbrains.datagrip
      pavucontrol
      slurp
      spotify
      sway-contrib.grimshot
      swappy
      yazi
      android-studio
      typora
      wl-clipboard
      wofi
      kdePackages.ark
      kdePackages.dolphin
      kdePackages.okular
    ]
    ++ lib.optionals (lib.elem "dev" roles) [
      zellij
      vscode
    ];
}
