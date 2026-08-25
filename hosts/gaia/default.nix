{ lib, roles, keyboardLayout, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ../../modules/hosts/shared/boot/grub.nix
    ../../modules/hosts/shared/system/defaults.nix
    ../../modules/hosts/shared/applications/profiles/desktop
    ../../modules/hosts/shared/applications/profiles/development
    ../../modules/hosts/shared/applications/profiles/productivity
    ../../modules/hosts/shared/applications/profiles/shell
    ../../modules/hosts/shared/applications/profiles/ai
    ../../modules/hosts/gaia/system/services
    ../../modules/hosts/gaia/boot/kernel.nix

    ../../modules/hosts/gaia/hardware/bluetooth.nix
    ../../modules/hosts/gaia/system/networking/base.nix
    ../../modules/hosts/shared/system/networking/vpn.nix
    ../../modules/hosts/gaia/system/networking/tailscale.nix
    ../../modules/hosts/shared/environment/profiles/core.nix
    ../../modules/hosts/shared/environment/profiles/desktop-dev.nix
    ../../modules/hosts/shared/environment/profiles/desktop.nix
    ../../modules/hosts/shared/system/binary-compatibility.nix
    ../../modules/hosts/gaia/environment/profiles/fonts.nix
    ../../modules/hosts/gaia/environment/session/sway.nix
    ../../modules/hosts/gaia/environment/session/display-manager.nix
    ../../modules/hosts/gaia/environment/session/portals.nix
    ../../modules/hosts/shared/environment/users/giks.nix
  ];

  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  platform.services.docker.enable = lib.elem "dev" roles;

  networking.hostName = "gaia";
  services.xserver.xkb.layout = keyboardLayout;

}
