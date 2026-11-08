{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.shell;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fastfetch
    ];
  };
}
