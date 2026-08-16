{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.languages.node;
in
{
  options.myModules.profiles.languages.node.enable = lib.mkEnableOption "Node.js development toolchain" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nodejs
    ];
  };
}
