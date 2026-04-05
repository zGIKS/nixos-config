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
    # Install Neovim
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    # Install required dependencies for the Neovim configuration
    home.packages = with pkgs; [
      # LSP servers (these will be managed by Mason, but having them available helps)
      lua-language-server
      nil # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-langservers-extracted # html, css, json, eslint
      yaml-language-server
      pyright
      rust-analyzer

      # Tools needed for plugins
      gcc # Required for telescope-fzf-native and treesitter
      nodejs # Required for Mason
      python3 # Required for some LSP servers
      cargo # Required for rust-analyzer
      git # Required for lazy.nvim and gitsigns

      # Additional tools that Mason will use
      gnumake # Required for building fzf
      unzip # Required for Mason
      curl # Required for Mason downloads
      gnutar # Required for Mason extractions

      # Fonts with Nerd Font support for icon-capable terminals/UI.
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];

    # Manage the full Neovim config directory as a single XDG entry.
    xdg.configFile."nvim" = {
      source = ../../../home/programs/nvim;
      recursive = true;
      force = true;
    };

    # Set up environment variables
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
