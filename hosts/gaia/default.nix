{ lib, roles, keyboardLayout, ... }:

{
  imports = [
    ../../modules/hosts/gaia/system/sops.nix
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
    ../../modules/hosts/shared/applications/profiles/tools/pomodog.nix
    ../../modules/hosts/gaia/system/services
    ../../modules/hosts/gaia/boot/kernel.nix

    ../../modules/hosts/gaia/hardware/bluetooth.nix
    ../../modules/hosts/gaia/system/networking/base.nix
    ../../modules/hosts/gaia/system/networking/tailscale.nix
    ../../modules/hosts/shared/environment/profiles/core.nix
    ../../modules/hosts/shared/environment/profiles/desktop.nix
    ../../modules/hosts/shared/system/binary-compatibility.nix
    ../../modules/hosts/gaia/environment/profiles/fonts.nix
    ../../modules/hosts/gaia/environment/session/sway.nix
    ../../modules/hosts/gaia/environment/session/display-manager.nix
    ../../modules/hosts/gaia/environment/session/portals.nix
    ../../modules/hosts/shared/environment/users/giks.nix
  ]
  ++ lib.optionals (lib.elem "dev" roles) [
    ../../modules/hosts/gaia/applications/profiles/dev.nix
  ];

  myModules.profiles.core.enable = true;
  myModules.profiles.desktopApps.enable = true;
  myModules.profiles.devGui.enable = true;
  myModules.profiles.languages.go.enable = true;
  myModules.profiles.languages.lsp.enable = true;
  myModules.profiles.languages.node.enable = true;
  myModules.profiles.languages.python.enable = true;
  myModules.profiles.languages.rust.enable = true;
  myModules.profiles.tools.nit.enable = true;
  myModules.profiles.tools.pomodog.enable = true;
  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  platform.services.docker.enable = lib.elem "dev" roles;

  myModules.profiles.dev = {
    enable = lib.elem "dev" roles;
  };

  sops.defaultSopsFile = ../../secrets/gaia/secrets.yaml;

  networking.hostName = "gaia";
  services.xserver.xkb.layout = keyboardLayout;

}
