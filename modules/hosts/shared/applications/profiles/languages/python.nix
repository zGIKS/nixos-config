{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.languages.python;
in
{
  options.myModules.profiles.languages.python.enable = lib.mkEnableOption "Python development toolchain" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      python3
      python313
      uv
    ];
  };
}
