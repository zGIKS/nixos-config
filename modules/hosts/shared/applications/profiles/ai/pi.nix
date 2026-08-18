{ config, lib, pkgs, airi, ... }:

let
  cfg = config.myModules.profiles.ai;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.myModules.profiles.ai.pi.enable = lib.mkEnableOption "Pi coding agent" // {
    default = true;
  };

  config = lib.mkIf (cfg.enable && cfg.pi.enable) {
    environment.systemPackages = [ airi.packages.${system}.pi-coding-agent ];
  };
}
