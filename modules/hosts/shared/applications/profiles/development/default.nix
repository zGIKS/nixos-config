{ lib, roles, ... }:

{
  options.myModules.profiles.development.enable = lib.mkEnableOption "development profile" // {
    default = lib.elem "dev" roles;
  };

  imports = [
    ./cli.nix
    ./datagrip.nix
    ./nit.nix
    ./languages
  ];
}
