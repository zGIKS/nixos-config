{ config, lib, ... }:

{
  config = lib.mkIf config.myHome.nvim.enable {
    programs.nixvim = {
      colorschemes.tokyonight = {
        enable = true;
        settings.style = "night";
      };

      plugins.web-devicons.enable = true;
    };
  };
}
