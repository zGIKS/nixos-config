{ lib, homeLib, roles, ... }:

let
  swayConfigFiles = [
    {
      target = "sway/config";
      source = ../../../home/programs/sway/config;
    }
    {
      target = "sway/config.d/waybar.conf";
      source = ../../../home/programs/sway/config.d/waybar.conf;
    }
    {
      target = "sway/config.d/portal.conf";
      source = ../../../home/programs/sway/config.d/portal.conf;
    }
  ];
in
{
  xdg.configFile = homeLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) swayConfigFiles
  );
}
