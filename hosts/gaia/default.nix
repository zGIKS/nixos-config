{ config, lib, username, roles, keyboardLayout, ... }:

{
  imports = [
    ../../modules/hosts/gaia/system/sops.nix
    ./hardware-configuration.nix
    ./disk.nix
    ../../modules/hosts/gaia/services
    ../../modules/hosts/gaia/system/kernel.nix

    ../../modules/hosts/gaia/system/defaults.nix
    ../../modules/hosts/gaia/hardware/bluetooth.nix
    ../../modules/hosts/gaia/networking/base.nix
    ../../modules/hosts/gaia/networking/tailscale.nix
    ../../modules/hosts/gaia/packages/profiles/core.nix
    ../../modules/hosts/shared/packages/profiles/desktop.nix
    ../../modules/hosts/shared/system/binary-compatibility.nix
    ../../modules/hosts/gaia/packages/profiles/fonts.nix
    ../../modules/hosts/gaia/session/sway.nix
    ../../modules/hosts/gaia/session/display-manager.nix
    ../../modules/hosts/gaia/session/portals.nix
    ../../modules/hosts/shared/users/giks.nix
  ]
  ++ lib.optionals (lib.elem "dev" roles) [
    ../../modules/hosts/gaia/packages/profiles/dev.nix
  ];

  myModules.profiles.core.enable = true;
  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  platform.services.docker.enable = lib.elem "dev" roles;

  myModules.profiles.dev = {
    enable = lib.elem "dev" roles;
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
