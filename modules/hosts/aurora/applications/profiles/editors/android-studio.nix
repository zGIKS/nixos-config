{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.profiles.editors;
in
{
  options.myModules.profiles.editors.android-studio.enable =
    lib.mkEnableOption "Android Studio IDE" // {
      default = true;
    };

  config = lib.mkIf (cfg.enable && cfg.android-studio.enable) {
    environment.systemPackages = [ pkgs.android-studio ];
  };
}