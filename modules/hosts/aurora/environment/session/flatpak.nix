{ config, lib, username, ... }:

{
  environment.sessionVariables.XDG_DATA_DIRS = lib.mkForce [
    "${config.services.displayManager.sessionData.desktops}/share"
    "/run/current-system/sw/share"
    "/etc/profiles/per-user/${username}/share"
    "/var/lib/flatpak/exports/share"
    "${config.users.users.${username}.home}/.local/share/flatpak/exports/share"
  ];
}
