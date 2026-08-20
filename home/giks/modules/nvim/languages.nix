{ config, lib, ... }:

{
  config = lib.mkIf config.myHome.nvim.enable {
    programs.nixvim.plugins.treesitter = {
      enable = true;
      settings = {
        ensure_installed = [
          "lua"
          "rust"
          "go"
          "nix"
          "java"
          "json"
          "yaml"
          "toml"
          "vim"
          "vimdoc"
          "query"
        ];
        highlight.enable = true;
        indent.enable = true;
      };
    };
  };
}
