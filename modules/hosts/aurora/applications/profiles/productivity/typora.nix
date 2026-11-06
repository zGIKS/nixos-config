{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.productivity;
in
{
  options.myModules.profiles.productivity.typora.enable = lib.mkEnableOption "Typora markdown editor" // {
    default = lib.elem "desktop" roles;
  };

  config = lib.mkIf (cfg.enable && cfg.typora.enable) {
    environment.systemPackages = with pkgs; [
      typora
    ];
  };
}
