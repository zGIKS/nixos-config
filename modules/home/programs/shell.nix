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
    {
      target = "cava/themes/solarized_dark";
      source = ../../../home/programs/cava/themes/solarized_dark;
    }
    {
      target = "cava/themes/tricolor";
      source = ../../../home/programs/cava/themes/tricolor;
    }
    {
      target = "cava/shaders/bar_spectrum.frag";
      source = ../../../home/programs/cava/shaders/bar_spectrum.frag;
    }
    {
      target = "cava/shaders/eye_of_phi.frag";
      source = ../../../home/programs/cava/shaders/eye_of_phi.frag;
    }
    {
      target = "cava/shaders/northern_lights.frag";
      source = ../../../home/programs/cava/shaders/northern_lights.frag;
    }
    {
      target = "cava/shaders/pass_through.vert";
      source = ../../../home/programs/cava/shaders/pass_through.vert;
    }
    {
      target = "cava/shaders/spectrogram.frag";
      source = ../../../home/programs/cava/shaders/spectrogram.frag;
    }
    {
      target = "cava/shaders/winamp_line_style_spectrum.frag";
      source = ../../../home/programs/cava/shaders/winamp_line_style_spectrum.frag;
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
