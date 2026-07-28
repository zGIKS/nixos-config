{ config, antigravityNix, lib, pkgs, ... }:

{
  config = lib.mkIf config.myModules.profiles.desktopApps.enable {
    environment.systemPackages = [
      antigravityNix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
