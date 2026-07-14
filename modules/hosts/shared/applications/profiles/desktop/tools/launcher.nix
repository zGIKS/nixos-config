{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.myModules.profiles.desktopApps.enable {
    environment.systemPackages = with pkgs; [
      wofi
    ];
  };
}
