{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myHome.nvim;
in
{
  options.myHome.nvim = {
    enable = mkEnableOption "Enable Neovim with VS Code-like configuration";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    home.packages = with pkgs; [
      lua-language-server
      nil
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-langservers-extracted
      yaml-language-server
      pyright
      rust-analyzer
      gcc
      nodejs
      python3
      cargo
      git
      gnumake
      unzip
      curl
      gnutar
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];

    xdg.configFile."nvim" = {
      source = ../../../home/programs/nvim;
      recursive = true;
      force = true;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
