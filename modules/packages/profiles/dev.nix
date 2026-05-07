{ config, lib, pkgs, username, nit, ... }:

let
  cfg = config.myModules.profiles.dev;
in
{
  options.myModules.profiles.dev = {
    enable = lib.mkEnableOption "developer profile";
    latex.enable = lib.mkEnableOption "LaTeX tools";
    java.enable = lib.mkEnableOption "Java development (JDK 21/25)";
    lsp.enable = lib.mkEnableOption "Common Language Servers";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gcc
      go
      go-swag
      nit.packages.${pkgs.system}.nit
      rustup
      typescript
      wpsoffice
    ]
    ++ lib.optionals cfg.latex.enable [
      texliveFull
    ]
    ++ lib.optionals cfg.java.enable [
      jdk21
      jdk25
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
