{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.editors;
in
{
  options.myModules.profiles.editors.idea.enable =
    lib.mkEnableOption "JetBrains IDEA IDE" // {
      default = true;
    };

  config = lib.mkIf (cfg.enable && cfg.idea.enable) {
    environment.systemPackages = [ pkgs.jetbrains.idea ];
  };
}