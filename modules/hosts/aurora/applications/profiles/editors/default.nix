{ lib, roles, ... }:

{
  options.myModules.profiles.editors.enable =
    lib.mkEnableOption "editor and IDE applications" // {
      default = lib.elem "dev" roles;
    };

  imports = [
    ./idea.nix
    ./android-studio.nix
    ./wpsoffice.nix
  ];
}