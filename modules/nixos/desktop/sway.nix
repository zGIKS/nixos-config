{ config, lib, ... }:

{
  options.myModules.desktop.sway.enable = lib.mkEnableOption "Sway WM";

  config = lib.mkIf config.myModules.desktop.sway.enable {
    programs.sway = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
