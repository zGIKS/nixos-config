{ config, lib, ... }:

{
  config = lib.mkIf config.myHome.nvim.enable {
    programs.nixvim = {
      globals = {
        mapleader = " ";
        maplocalleader = " ";
        loaded_gzip = 1;
        loaded_zip = 1;
        loaded_zipPlugin = 1;
        loaded_tar = 1;
        loaded_tarPlugin = 1;
        loaded_getscript = 1;
        loaded_getscriptPlugin = 1;
        loaded_vimball = 1;
        loaded_vimballPlugin = 1;
        loaded_2html_plugin = 1;
        loaded_logiPat = 1;
        loaded_rrhelper = 1;
        loaded_netrw = 1;
        loaded_netrwPlugin = 1;
        loaded_netrwSettings = 1;
      };

      extraConfigLua = ''
        vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
          pattern = "*",
          command = "checktime",
        })
      '';

      opts = {
        autoread = true;
        number = true;
        relativenumber = true;
        signcolumn = "yes";
        termguicolors = true;
        mouse = "a";
        clipboard = "unnamedplus";
        undofile = true;
        swapfile = false;
        ignorecase = true;
        smartcase = true;
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        smartindent = true;
      };
    };
  };
}
