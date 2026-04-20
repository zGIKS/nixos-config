{ lib, pkgs, roles, homeLib, ... }:

let
  ewwConfigFiles = [
    {
      target = "eww";
      source = ../../../home/programs/eww;
      recursive = true;
      force = true;
    }
  ];
in
{
  home.packages = with pkgs;
    lib.optionals (lib.elem "desktop" roles) [
      eww
    ];

  xdg.configFile = homeLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) ewwConfigFiles
  );
}
