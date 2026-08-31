{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.media;
in
{
  options.myModules.profiles.media.enable = lib.mkEnableOption "Aurora media applications";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mpv
      obs-studio
      rustdesk-flutter
    ];
  };
}
