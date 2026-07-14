{ config, lib, pkgs, pomodog, ... }:

{
  config = lib.mkIf config.myModules.profiles.desktopApps.enable {
    environment.systemPackages = with pkgs; [
      pomodog.packages.${pkgs.stdenv.hostPlatform.system}.default
      brightnessctl
      grim
      gsimplecal
      gvfs
      tumbler
      thunar
      pavucontrol
      playerctl
      slurp
      sway-contrib.grimshot
      swappy
      wdisplays
      yazi
      wl-clipboard
      wofi
      kdePackages.ark
      waybar
      eww
    ];
  };
}
