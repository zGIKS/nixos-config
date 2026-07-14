{ lib, roles, platformLib, ... }:

let
  ewwConfigFiles = [
    {
      target = "eww";
      source = ../../../../home/programs/eww;
      recursive = true;
      force = true;
    }
  ];
in
{
  xdg.configFile = platformLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) ewwConfigFiles
  );
}
