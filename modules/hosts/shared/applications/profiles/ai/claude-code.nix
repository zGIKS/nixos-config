{ config, lib, pkgs, airi, ... }:

let
  cfg = config.myModules.profiles.ai;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.myModules.profiles.ai.claudeCode.enable = lib.mkEnableOption "Claude Code" // {
    default = true;
  };

  config = lib.mkIf (cfg.enable && cfg.claudeCode.enable) {
    environment.systemPackages = [ airi.packages.${system}.claude-code ];
  };
}
