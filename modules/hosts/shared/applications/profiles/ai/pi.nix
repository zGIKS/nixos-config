{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.ai;
in
{
  options.myModules.profiles.ai.pi.enable = lib.mkEnableOption "Pi coding agent" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf (cfg.enable && cfg.pi.enable) {
    environment.systemPackages = with pkgs; [
      pi-coding-agent
    ];
  };
}
