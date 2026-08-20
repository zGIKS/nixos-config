{ config, lib, ... }:

{
  config = lib.mkIf config.myHome.nvim.enable {
    programs.nixvim.plugins.neo-tree = {
      enable = true;
      settings = {
        window.position = "left";
        filesystem = {
          hijack_netrw_behavior = "open_current";
          filtered_items = {
            hide_dotfiles = false;
            hide_gitignored = false;
          };
        };
      };
    };
  };
}
