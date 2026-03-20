{ lib, pkgs, roles, ... }:

{
  home.packages = with pkgs;
    lib.optionals (lib.elem "desktop" roles) [
      brightnessctl
      discord
      google-chrome
      gsimplecal
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
