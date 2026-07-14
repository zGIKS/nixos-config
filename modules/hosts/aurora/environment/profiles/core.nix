{ config, lib, pkgs, ... }:

{
  options.myModules.profiles.core.enable = lib.mkEnableOption "core system profile";

  config = lib.mkIf config.myModules.profiles.core.enable {
    environment.systemPackages = with pkgs; [
      pipes
    ];
  };
}
