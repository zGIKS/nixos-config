{ lib, roles, ... }:

{
  options.myModules.profiles.desktopApps.enable = lib.mkEnableOption "desktop applications" // {
    default = lib.elem "desktop" roles;
  };

  imports = [
    ./brave.nix
    ./environment
    ./utilities
  ];
}
