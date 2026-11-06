{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.myModules.profiles.desktopApps.enable {
    # Only host-agnostic display utilities live here.
    # Per-host graphical monitor managers (e.g. nwg-displays, wdisplays) are
    # declared in each host's own applications/profiles/display.nix so the
    # choice is isolated to that host.
    environment.systemPackages = with pkgs; [
      brightnessctl
    ];
  };
}
