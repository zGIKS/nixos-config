{ lib, roles, keyboardLayout, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix

    # Boot
    ../../modules/hosts/aurora/boot/grub.nix
    ../../modules/hosts/aurora/boot/kernel.nix

    # System
    ../../modules/hosts/aurora/system/defaults.nix
    ../../modules/hosts/aurora/system/binary-compatibility.nix
    ../../modules/hosts/aurora/system/networking/base.nix
    ../../modules/hosts/aurora/system/networking/tailscale.nix
    ../../modules/hosts/aurora/system/networking/vpn.nix
    ../../modules/hosts/aurora/system/services

    # Hardware
    ../../modules/hosts/aurora/hardware/bluetooth.nix
    ../../modules/hosts/aurora/hardware/nvidia.nix
    ../../modules/hosts/aurora/hardware/steam.nix

    # Environment
    ../../modules/hosts/aurora/environment/profiles/core.nix
    ../../modules/hosts/aurora/environment/profiles/desktop.nix
    ../../modules/hosts/aurora/environment/profiles/desktop-dev.nix
    ../../modules/hosts/aurora/environment/profiles/fonts.nix
    ../../modules/hosts/aurora/environment/session/sway.nix
    ../../modules/hosts/aurora/environment/session/display-manager.nix
    ../../modules/hosts/aurora/environment/session/portals.nix
    ../../modules/hosts/aurora/environment/session/flatpak.nix
    ../../modules/hosts/aurora/environment/users/giks.nix

    # Applications
    ../../modules/hosts/aurora/applications/profiles/default.nix
    ../../modules/hosts/aurora/applications/profiles/desktop
    ../../modules/hosts/aurora/applications/profiles/desktop-tools.nix
    ../../modules/hosts/aurora/applications/profiles/display.nix
    ../../modules/hosts/aurora/applications/profiles/media.nix
    ../../modules/hosts/aurora/applications/profiles/development
    ../../modules/hosts/aurora/applications/profiles/productivity
    ../../modules/hosts/aurora/applications/profiles/shell
    ../../modules/hosts/aurora/applications/profiles/ai
  ];

  # Module activations
  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  myModules.hardware.steam.enable = true;
  platform.services.androidDebugging.enable = lib.elem "dev" roles;
  platform.services.docker.enable = lib.elem "dev" roles;

  myModules.profiles.languages.latex.enable = lib.elem "dev" roles;
  myModules.profiles.media.enable = true;

  # Host-specific facts
  networking.hostName = "aurora";
  services.xserver.xkb.layout = keyboardLayout;

  # Hardware layer activation
  myModules.hardware.nvidia.enable = true;

  # Services layer activation
  myModules.services.asus = {
    enable = true;
    rogControlCenter.enable = true;
  };
  platform.services.libvirt.enable = true;

}
