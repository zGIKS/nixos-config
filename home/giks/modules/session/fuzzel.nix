{ lib, roles, platformLib, ... }:

let
  fuzzelConfigFiles = [
    {
      target = "fuzzel/fuzzel.ini";
      source = ../../../../home/programs/fuzzel/fuzzel.ini;
    }
    {
      target = "fuzzel/launcher.sh";
      source = ../../../../home/programs/fuzzel/launcher.sh;
    }
  ];
in
{
  xdg.configFile = platformLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) fuzzelConfigFiles
  );
}
