{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.languages.rust;
in
{
  options.myModules.profiles.languages.rust.enable = lib.mkEnableOption "Rust development toolchain" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rustup
      cargo
    ];
  };
}
