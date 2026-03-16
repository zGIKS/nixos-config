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
  ];
in
{
  xdg.configFile = homeLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) wofiConfigFiles
  );
}
