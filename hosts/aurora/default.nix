{ lib, roles, keyboardLayout, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ../../modules/hosts/shared/boot/grub.nix
    ../../modules/hosts/shared/system/defaults.nix
    ../../modules/hosts/shared/applications/profiles/desktop
    ../../modules/hosts/shared/applications/profiles/dev-gui.nix
    ../../modules/hosts/shared/applications/profiles/languages/go.nix
    ../../modules/hosts/shared/applications/profiles/languages/lsp.nix
    ../../modules/hosts/shared/applications/profiles/languages/node.nix
    ../../modules/hosts/shared/applications/profiles/languages/python.nix
    ../../modules/hosts/shared/applications/profiles/languages/rust.nix
    ../../modules/hosts/shared/applications/profiles/tools/nit.nix
    ../../modules/hosts/aurora/system/services
    ../../modules/hosts/aurora/boot/kernel.nix

    ../../modules/hosts/aurora/system/defaults.nix
    ../../modules/hosts/aurora/hardware/bluetooth.nix
    ../../modules/hosts/aurora/hardware/steam.nix
    ../../modules/hosts/aurora/system/networking/base.nix
    ../../modules/hosts/aurora/system/networking/vpn.nix
    ../../modules/hosts/aurora/system/networking/tailscale.nix
    ../../modules/hosts/aurora/hardware/nvidia.nix
    ../../modules/hosts/aurora/environment/profiles/core.nix
    ../../modules/hosts/aurora/applications/profiles/desktop-tools.nix
    ../../modules/hosts/shared/environment/profiles/core.nix
    ../../modules/hosts/shared/environment/profiles/desktop.nix
    ../../modules/hosts/shared/system/binary-compatibility.nix
    ../../modules/hosts/aurora/applications/profiles/gaming.nix
    ../../modules/hosts/aurora/applications/profiles/browsers.nix
    ../../modules/hosts/aurora/applications/profiles/media.nix
    ../../modules/hosts/aurora/environment/profiles/fonts.nix
    ../../modules/hosts/aurora/environment/session/sway.nix
    ../../modules/hosts/aurora/environment/session/display-manager.nix
    ../../modules/hosts/aurora/environment/session/portals.nix
    ../../modules/hosts/aurora/environment/session/flatpak.nix
    ../../modules/hosts/shared/environment/users/giks.nix
  ]
  ++ lib.optionals (lib.elem "dev" roles) [
    ../../modules/hosts/aurora/applications/profiles/dev.nix
  ];

  # Shared module activations
  myModules.profiles.core.enable = true;
  myModules.profiles.desktopApps.enable = true;
  myModules.profiles.devGui.enable = true;
  myModules.profiles.languages.go.enable = true;
  myModules.profiles.languages.lsp.enable = true;
  myModules.profiles.languages.node.enable = true;
  myModules.profiles.languages.python.enable = true;
  myModules.profiles.languages.rust.enable = true;
  myModules.profiles.tools.nit.enable = true;
  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  myModules.hardware.steam.enable = true;
  myModules.profiles.gaming.enable = true;
  platform.services.androidDebugging.enable = lib.elem "dev" roles;
  platform.services.docker.enable = lib.elem "dev" roles;

  myModules.profiles.dev = {
    enable = lib.elem "dev" roles;
    latex.enable = lib.elem "dev" roles;
  };
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

}
