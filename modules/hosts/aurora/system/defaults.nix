{ config, lib, ... }:

{
  config = {
    time.timeZone = "America/Lima";
    i18n.defaultLocale = "en_US.UTF-8";
    console.useXkbConfig = true;

    nixpkgs.config.allowUnfree = true;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "25.11";
  };
}
