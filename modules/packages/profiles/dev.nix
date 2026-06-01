{ config, lib, pkgs, username, nit, ... }:

let
  cfg = config.myModules.profiles.dev;
in
{
  options.myModules.profiles.dev = {
    enable = lib.mkEnableOption "developer profile";
    latex.enable = lib.mkEnableOption "LaTeX tools";
    lsp.enable = lib.mkEnableOption "Common Language Servers";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      go
      go-swag
      nit.packages.${pkgs.system}.nit
      rustup
      wpsoffice
    ]
    ++ lib.optionals cfg.latex.enable [
      texliveFull
    ]
    ++ lib.optionals cfg.lsp.enable [
      bash-language-server
      eslint
      prettier
      pyright
      svelte-language-server
      tailwindcss
      typescript-language-server
      vscode-langservers-extracted
    ];
  };
}
