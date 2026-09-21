{ lib, ... }:

# Aurora has gaming unconditionally enabled (see hosts/aurora/default.nix
# where feature.nix sets gaming.enable = true).
{
  options.myModules.profiles.gaming.enable =
    lib.mkEnableOption "gaming applications" // {
      default = true;
    };

  imports = [
    ./steam.nix
  ];
}