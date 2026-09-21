{ lib, roles, ... }:

{
  options.myModules.profiles.browsers.enable =
    lib.mkEnableOption "browser applications" // {
      default = lib.elem "desktop" roles;
    };

  imports = [
    ./google.nix
  ];
}