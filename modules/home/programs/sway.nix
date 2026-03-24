{ lib, homeLib, roles, ... }:

let
  swayConfigFiles = [
    {
      target = "sway/config";
      source = ../../../home/programs/sway/config;
    }
    {
      target = "sway/config.d/autostart.conf";
      source = ../../../home/programs/sway/config.d/autostart.conf;
    }
    {
      target = "sway/config.d/appearance.conf";
      source = ../../../home/programs/sway/config.d/appearance.conf;
    }
    {
      target = "sway/config.d/bar.conf";
      source = ../../../home/programs/sway/config.d/bar.conf;
    }
    {
      target = "sway/config.d/binds.conf";
      source = ../../../home/programs/sway/config.d/binds.conf;
    }
    {
      target = "sway/config.d/inputs.conf";
      source = ../../../home/programs/sway/config.d/inputs.conf;
    }
    {
      target = "sway/config.d/outputs.conf";
      source = ../../../home/programs/sway/config.d/outputs.conf;
    }
  ];
in
{
  xdg.configFile = (homeLib.mkConfigLinks (
    lib.optionals (lib.elem "desktop" roles) swayConfigFiles
  )) // lib.optionalAttrs (lib.elem "desktop" roles) {
    "swappy/config".text = ''
      [Default]
      save_dir=$HOME/Pictures/Screenshots
      save_filename_format=swappy-%Y%m%d-%H%M%S.png
      show_panel=true
      line_size=5
      text_size=20
      text_font=sans-serif
      paint_mode=brush
      early_exit=false
      fill_shape=false
      auto_save=false
    '';
  };
}
