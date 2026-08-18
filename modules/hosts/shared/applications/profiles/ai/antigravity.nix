{ config, lib, pkgs, airi, ... }:

let
  cfg = config.myModules.profiles.ai;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.myModules.profiles.ai.antigravity.enable = lib.mkEnableOption "Antigravity CLI (agy)" // {
    default = true;
  };

  config = lib.mkIf (cfg.enable && cfg.antigravity.enable) {
    environment.systemPackages = [ airi.packages.${system}.antigravity-cli ];
  };
}
