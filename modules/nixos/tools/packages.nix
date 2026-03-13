{ config, lib, pkgs, ... }:

{
  options.myModules.tools.base.enable = lib.mkEnableOption "base developer and system tooling";

  config = lib.mkIf config.myModules.tools.base.enable {
    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      starship
      zellij
      pipes
      bash-completion
      fish
      gh
      nano
      os-prober
      efibootmgr
      docker
      docker-compose
      docker-buildx
      rustup
      go
      go-swag
      jdk
      google-java-format
      texliveFull
      eslint
      prettier
      tailwindcss
      typescript
      typescript-language-server
      bash-language-server
      pyright
      svelte-language-server
      vscode-langservers-extracted
      copilot-cli
    ];
  };
}
