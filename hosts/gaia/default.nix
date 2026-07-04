{ config, lib, username, roles, keyboardLayout, ... }:

{
  imports = [
    ../../modules/shared/system/sops.nix
    ./hardware-configuration.nix
    ./disk.nix
    ../../modules/shared/services/cloudflared.nix
    ./services
    ./kernel

    ../../modules/shared/system/defaults.nix
    ../../modules/shared/hardware/bluetooth.nix
    ../../modules/shared/networking/base.nix
    ../../modules/shared/networking/tailscale.nix
    ../../modules/shared/services/pipewire.nix
    ../../modules/shared/services/printing.nix
    ../../modules/shared/services/keyring.nix
    ../../modules/shared/services/flatpak.nix
    ../../modules/shared/packages/profiles/core.nix
    ../../modules/shared/packages/profiles/desktop.nix
    ../../modules/shared/packages/profiles/fonts.nix
    ../../modules/shared/packages/volta.nix
    ../../modules/shared/session/sway.nix
    ../../modules/shared/session/display-manager.nix
    ../../modules/shared/session/portals.nix
    ../../modules/shared/users/giks.nix
  ]
  ++ lib.optionals (lib.elem "dev" roles) [
    ../../modules/shared/packages/profiles/dev.nix
    ../../modules/shared/services/docker.nix
  ];

  myModules.profiles.core.enable = true;
  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  platform.services.docker.enable = lib.elem "dev" roles;

  myModules.profiles.dev = {
    enable = lib.elem "dev" roles;
    latex.enable = lib.elem "dev" roles;
    lsp.enable = lib.elem "dev" roles;
  };

  sops.defaultSopsFile = ../../secrets/gaia/secrets.yaml;

  networking.hostName = "gaia";
  services.xserver.xkb.layout = keyboardLayout;

  boot.loader.grub.extraEntries = ''
    menuentry "Windows 11" {
      insmod part_gpt
      insmod fat
      search --no-floppy --file --set=root /EFI/Microsoft/Boot/bootmgfw.efi
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';

  # Install heavier GUI dev apps via Home Manager on this host.
  home-manager.users.${username}.myHome.apps.devGui.enable = true;
}
