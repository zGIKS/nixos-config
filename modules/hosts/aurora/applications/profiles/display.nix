{
  config,
  lib,
  pkgs,
  ...
}:

# Aurora-specific graphical display configuration tool.
# Replaces wdisplays so monitor geometry, refresh rate and rotation can be
# saved graphically to ~/.config/sway/outputs. The include for that file is
# declared once in the shared sway config.
{
  config = lib.mkIf config.myModules.profiles.desktopApps.enable {
    environment.systemPackages = with pkgs; [
      nwg-displays
    ];
  };
}
