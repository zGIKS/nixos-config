{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.core;
in
{
  options.myModules.profiles.core.enable = lib.mkEnableOption "core system profile";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bash-completion
      bun
      curl
      efibootmgr
      fish
      gh
      git
      htop
      neovim
      os-prober
      starship
      unzip
      wget
      zellij
    ];
  };
}
