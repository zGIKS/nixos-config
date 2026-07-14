{ config, lib, pkgs, username, nit, ... }:

let
  cfg = config.myModules.profiles.dev;
in
{
  options.myModules.profiles.dev = {
    enable = lib.mkEnableOption "developer profile";
    lsp.enable = lib.mkEnableOption "Common Language Servers";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      go
      go-swag
      nit.packages.${pkgs.stdenv.hostPlatform.system}.nit
      rustup
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
