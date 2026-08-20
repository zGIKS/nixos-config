{ lib, ... }:

{
  options.myHome.nvim = {
    enable = lib.mkEnableOption "Enable the Neovim configuration";
  };
}
