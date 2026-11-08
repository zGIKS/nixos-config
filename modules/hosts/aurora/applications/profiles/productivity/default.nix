{ lib, roles, ... }:

{
  options.myModules.profiles.productivity.enable = lib.mkEnableOption "productivity applications" // {
    default = lib.elem "desktop" roles;
  };

  imports = [
    ./typora.nix
    ./pomodog.nix
  ];
}
