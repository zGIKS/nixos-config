{ lib, homeLib, roles, ... }:

let
  swayConfigFiles = [
    {
      target = "sway/config";
      source = ../../../home/programs/sway/config;
    }
  ];
in
{
  xdg.configFile = homeLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) swayConfigFiles
  );
}
