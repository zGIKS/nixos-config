{ config, lib, pkgs, ... }:

{
  options.myModules.profiles.dev.enable = lib.mkEnableOption "developer profile";

  config = lib.mkIf config.myModules.profiles.dev.enable {
    virtualisation.docker.enable = true;

    users.extraGroups.docker.members = [ "giks" ];

    environment.systemPackages = with pkgs; [
      bash-language-server
      docker
      docker-buildx
      docker-compose
      eslint
      go
      go-swag
      jdk
      prettier
      pyright
      rustup
      svelte-language-server
      tailwindcss
      texliveFull
      typescript
      typescript-language-server
      vscode-langservers-extracted
      wpsoffice
    ];
  };
}
