{ lib, pkgs, roles, homeLib, ... }:

let
  ewwConfigFiles = [
    {
      target = "eww/eww.yuck";
      source = ../../../home/programs/eww/eww.yuck;
    }
    {
      target = "eww/eww.scss";
      source = ../../../home/programs/eww/eww.scss;
    }
    {
      target = "eww/components/settings/toggle.sh";
      source = ../../../home/programs/eww/components/settings/toggle.sh;
    }
    {
      target = "eww/components/settings/close.sh";
      source = ../../../home/programs/eww/components/settings/close.sh;
    }
    {
      target = "eww/components/calendar/toggle.sh";
      source = ../../../home/programs/eww/components/calendar/toggle.sh;
    }
    {
      target = "eww/components/calendar/close.sh";
      source = ../../../home/programs/eww/components/calendar/close.sh;
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
