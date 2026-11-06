{ lib, config, pkgs, ... }:

{
  options.myModules.profiles.media.enable = lib.mkEnableOption "media applications";

  config = lib.mkIf config.myModules.profiles.media.enable {
    environment.systemPackages = with pkgs; [
      spotify
    ];
  };
}
