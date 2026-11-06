{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.languages.lsp;
in
{
  options.myModules.profiles.languages.lsp.enable = lib.mkEnableOption "common language servers" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lua-language-server
      nil
      bash-language-server
      eslint
      prettier
      pyright
      shfmt
      stylua
      svelte-language-server
      tailwindcss
      typescript-language-server
      vscode-langservers-extracted
      yaml-language-server
      rust-analyzer
    ];
  };
}
