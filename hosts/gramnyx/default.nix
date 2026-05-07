{ lib, username, roles, keyboardLayout, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/system/defaults.nix
    ../../modules/kernel/boot.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/networking/base.nix
    ../../modules/networking/vpn.nix
    ../../modules/services/pipewire.nix
    ../../modules/services/printing.nix
    ../../modules/services/keyring.nix
    ../../modules/services/flatpak.nix
    ../../modules/packages/profiles/core.nix
    ../../modules/packages/profiles/desktop.nix
    ../../modules/packages/profiles/fonts.nix
    ../../modules/packages/volta.nix
    ../../modules/session/sway.nix
    ../../modules/session/display-manager.nix
    ../../modules/session/portals.nix
    ../../modules/users/giks.nix
  ]
  ++ lib.optionals (lib.elem "dev" roles) [
    ../../modules/packages/profiles/dev.nix
    ../../modules/services/docker.nix
  ];

  myModules.profiles.core.enable = true;
  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  platform.services.docker.enable = lib.elem "dev" roles;

  myModules.profiles.dev = {
    enable = lib.elem "dev" roles;
    latex.enable = lib.elem "dev" roles;
    java.enable = lib.elem "dev" roles;
    lsp.enable = lib.elem "dev" roles;
  };

  networking.hostName = "gramnyx";
  services.xserver.xkb.layout = keyboardLayout;
}
