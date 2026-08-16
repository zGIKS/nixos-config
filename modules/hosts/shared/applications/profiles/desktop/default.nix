{ lib, roles, ... }:

{
  options.myModules.profiles.desktopApps.enable = lib.mkEnableOption "desktop applications" // {
    default = lib.elem "desktop" roles;
  };

  imports = [
    ./browsers.nix
    ./environment
    ./utilities
  ];
}
