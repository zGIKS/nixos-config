{ lib, pkgs, roles, ... }:

{
  home.packages = with pkgs;
    lib.optionals (lib.elem "desktop" roles) [
      brightnessctl
      discord
      eww
      gsimplecal
      spotify
      typora
      wofi
    ]
    ++ lib.optionals (lib.elem "dev" roles) [
      vscode
    ];
}
