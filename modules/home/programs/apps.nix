{ lib, pkgs, roles, ... }:

{
  home.packages = with pkgs;
    lib.optionals (lib.elem "desktop" roles) [
      discord
      spotify
      typora
    ]
    ++ lib.optionals (lib.elem "dev" roles) [
      vscode
    ];
}
