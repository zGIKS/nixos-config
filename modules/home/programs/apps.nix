{ lib, pkgs, roles, ... }:

{
  home.packages = with pkgs;
    lib.optionals (lib.elem "desktop" roles) [
      brightnessctl
      discord
      google-chrome
      grim
      gsimplecal
      slurp
      spotify
      sway-contrib.grimshot
      swappy
      yazi
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
