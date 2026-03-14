{ config, lib, pkgs, ... }:

{
  options.myModules.profiles.desktop.enable = lib.mkEnableOption "desktop profile";

  config = lib.mkIf config.myModules.profiles.desktop.enable {
    environment.systemPackages = with pkgs; [
      bluez
      brightnessctl
      eww
      google-java-format
      networkmanager
      wireplumber
      wofi
    ];
  };
}
