{ lib, pkgs, roles, homeLib, ... }:

let
  sharedConfigFiles = [
    {
      target = "alacritty/alacritty.toml";
      source = ../../../home/programs/alacritty/alacritty.toml;
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
  home.packages = with pkgs;
    [ alacritty fastfetch ]
    ++ lib.optionals (lib.elem "desktop" roles) [
      cava
      cmatrix
    ];

  xdg.configFile = homeLib.mkConfigLinks (
    sharedConfigFiles
    ++ lib.optionals (lib.elem "desktop" roles) cavaConfigFiles
  );
}
