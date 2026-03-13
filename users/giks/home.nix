{ config, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  home.stateVersion = "25.11";

  imports = [
    ../../modules/home/git.nix
  ];

  home.packages = with pkgs; [
    vscode
    alacritty
    cava
    cmatrix
    discord
    fastfetch
    spotify
    typora
  ];

  home.file.".gitignore_global".text = ''
  '';

  xdg.configFile."alacritty/alacritty.toml".source = ../../config/alacritty/alacritty.toml;
  xdg.configFile."fastfetch/config.jsonc".source = ../../config/fastfetch/config.jsonc;
  xdg.configFile."fish/config.fish".source = ../../config/fish/config.fish;
  xdg.configFile."starship.toml".source = ../../config/starship/starship.toml;
  xdg.configFile."cava/config".source = ../../config/cava/config;
  xdg.configFile."cava/themes/solarized_dark".source = ../../config/cava/themes/solarized_dark;
  xdg.configFile."cava/themes/tricolor".source = ../../config/cava/themes/tricolor;
  xdg.configFile."cava/shaders/bar_spectrum.frag".source = ../../config/cava/shaders/bar_spectrum.frag;
  xdg.configFile."cava/shaders/eye_of_phi.frag".source = ../../config/cava/shaders/eye_of_phi.frag;
  xdg.configFile."cava/shaders/northern_lights.frag".source = ../../config/cava/shaders/northern_lights.frag;
  xdg.configFile."cava/shaders/pass_through.vert".source = ../../config/cava/shaders/pass_through.vert;
  xdg.configFile."cava/shaders/spectrogram.frag".source = ../../config/cava/shaders/spectrogram.frag;
  xdg.configFile."cava/shaders/winamp_line_style_spectrum.frag".source = ../../config/cava/shaders/winamp_line_style_spectrum.frag;
}
