{ config, lib, pkgs, username, roles, keyboardLayout, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ./services
    ./kernel

    ../../modules/shared/system/defaults.nix
    ../../modules/shared/hardware/bluetooth.nix
    ../../modules/shared/networking/base.nix
    ../../modules/shared/networking/vpn.nix
    ../../modules/shared/networking/tailscale.nix
    ../../modules/shared/services/pipewire.nix
    ../../modules/shared/services/printing.nix
    ../../modules/shared/services/keyring.nix
    ../../modules/shared/services/flatpak.nix
    ../../modules/shared/services/asus.nix
    ../../modules/shared/hardware/nvidia.nix
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
    ../../modules/shared/services/android-debugging.nix
    ../../modules/shared/services/docker.nix
  ];

  # Shared module activations
  myModules.profiles.core.enable = true;
  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  platform.services.androidDebugging.enable = lib.elem "dev" roles;
  platform.services.docker.enable = lib.elem "dev" roles;

  myModules.profiles.dev = {
    enable = lib.elem "dev" roles;
    latex.enable = lib.elem "dev" roles;
    lsp.enable = lib.elem "dev" roles;
  };

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

  # Dual-boot Windows (host-specific)
  boot.loader.grub.extraEntries = ''
    menuentry "Windows 11" {
      insmod part_gpt
      insmod fat
      search --no-floppy --file --set=root /EFI/Microsoft/Boot/bootmgfw.efi
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';

  # Flatpak session integration
  environment.sessionVariables.XDG_DATA_DIRS = lib.mkForce [
    "${config.services.displayManager.sessionData.desktops}/share"
    "/run/current-system/sw/share"
    "/etc/profiles/per-user/${username}/share"
    "/var/lib/flatpak/exports/share"
    "${config.users.users.${username}.home}/.local/share/flatpak/exports/share"
  ];

  # Host-specific packages
  environment.systemPackages = with pkgs; [ ];

  # Install heavier GUI dev apps via Home Manager on this host.
  home-manager.users.${username}.myHome.apps.devGui.enable = true;
}
