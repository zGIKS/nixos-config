{ config, lib, ... }:

{
  options.myModules.desktop.plasma.enable = lib.mkEnableOption "Plasma Desktop";

  config = lib.mkIf config.myModules.desktop.plasma.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
