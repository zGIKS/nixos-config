{ lib, roles, homeLib, ... }:

let
  wofiConfigFiles = [
    {
      target = "wofi/config";
      source = ../../../home/programs/wofi/config;
    }
    {
      target = "wofi/style.css";
      source = ../../../home/programs/wofi/style.css;
    }
    {
      target = "wofi/launcher.sh";
      source = ../../../home/programs/wofi/launcher.sh;
    }
  ];
in
{
  xdg.configFile = homeLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) wofiConfigFiles
  );
}
