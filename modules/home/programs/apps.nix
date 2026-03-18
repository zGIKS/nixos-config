{ lib, pkgs, roles, ... }:

{
  home.packages = with pkgs;
    lib.optionals (lib.elem "desktop" roles) [
      brightnessctl
      discord
      eww
      google-chrome
      gsimplecal
      librewolf
      spotify
      yazi
      typora
      wofi
    ]
    ++ lib.optionals (lib.elem "dev" roles) [
      zellij
      vscode
    ];
}
