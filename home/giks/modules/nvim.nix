{ config, lib, ... }:

with lib;

let
  cfg = config.myHome.nvim;
in
{
  options.myHome.nvim = {
    enable = mkEnableOption "Enable Neovim with VS Code-like configuration";
  };

  config = mkIf cfg.enable {
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
