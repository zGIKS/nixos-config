{ lib, homeLib, roles, ... }:

let
  ewwConfigFiles = [
    {
      target = "eww";
      source = ../../../home/programs/eww;
    }
  ];
in
{
  xdg.configFile = homeLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) ewwConfigFiles
  );
}
