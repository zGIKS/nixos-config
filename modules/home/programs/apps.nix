{ lib, pkgs, roles, ... }:

{
  home.packages = with pkgs;
    lib.optionals (lib.elem "desktop" roles) [
      brightnessctl
      discord
      google-chrome
      grim
      gsimplecal
      jetbrains.datagrip
      slurp
      spotify
      sway-contrib.grimshot
      swappy
      yazi
      android-studio
      typora
      wl-clipboard
      wofi
      kdePackages.dolphin
    ]
    ++ lib.optionals (lib.elem "dev" roles) [
      zellij
      vscode
    ];
}
