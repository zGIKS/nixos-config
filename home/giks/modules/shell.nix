{ lib, roles, platformLib, ... }:

let
  sharedConfigFiles = [
    {
      target = "foot/foot.ini";
      source = ../../../home/programs/foot/foot.ini;
    }
    {
      target = "fastfetch/config.jsonc";
      source = ../../../home/programs/fastfetch/config.jsonc;
    }
    {
      target = "fish/config.fish";
      source = ../../../home/programs/fish/config.fish;
    }
    {
      target = "starship.toml";
      source = ../../../home/programs/starship/starship.toml;
    }
  ];

  cavaConfigFiles = [
    {
      target = "cava/config";
      source = ../../../home/programs/cava/config;
    }
  ];
in
{
  xdg.configFile = platformLib.mkConfigLinks (
    sharedConfigFiles
    ++ lib.optionals (lib.elem "desktop" roles) cavaConfigFiles
  );
}
