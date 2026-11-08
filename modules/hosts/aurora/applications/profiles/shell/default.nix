{ lib, roles, ... }:

{
  options.myModules.profiles.shell.enable = lib.mkEnableOption "shell applications" // {
    default = lib.elem "desktop" roles;
  };

  imports = [
    ./foot.nix
    ./fastfetch.nix
  ];
}
