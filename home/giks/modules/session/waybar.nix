{ lib, roles, platformLib, ... }:

let
  waybarConfigFiles = [
    {
      target = "waybar/config";
      source = ../../../../home/programs/waybar/config;
    }
    {
      target = "waybar/style.css";
      source = ../../../../home/programs/waybar/style.css;
    }
    {
      target = "waybar/icons/nixos.svg";
      source = ../../../../home/programs/waybar/icons/nixos.svg;
    }
  ];
in
{
  xdg.configFile = platformLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) waybarConfigFiles
  );
}
