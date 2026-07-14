{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.myModules.profiles.core.enable {
    environment.systemPackages = with pkgs; [
      pipes
    ];
  };
}
