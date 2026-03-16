{ lib, pkgs, roles, homeLib, ... }:

let
  waybarConfigFiles = [
    {
      target = "waybar/config";
      source = ../../../home/programs/waybar/config;
    }
    {
      target = "waybar/style.css";
      source = ../../../home/programs/waybar/style.css;
    }
  ];
in
{
  home.packages = with pkgs;
    lib.optionals (lib.elem "desktop" roles) [
      waybar
    ];

  xdg.configFile = homeLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) waybarConfigFiles
  );
}
