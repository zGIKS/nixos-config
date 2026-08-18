{ config, lib, pkgs, airi, ... }:

let
  cfg = config.myModules.profiles.ai;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.myModules.profiles.ai.codex.enable = lib.mkEnableOption "OpenAI Codex CLI" // {
    default = true;
  };

  config = lib.mkIf (cfg.enable && cfg.codex.enable) {
    environment.systemPackages = [ airi.packages.${system}.codex ];
  };
}
