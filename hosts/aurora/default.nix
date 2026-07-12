{ config, lib, pkgs, username, roles, keyboardLayout, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ../../modules/hosts/aurora/services
    ../../modules/hosts/aurora/system/kernel.nix

    ../../modules/hosts/aurora/system/defaults.nix
    ../../modules/hosts/aurora/hardware/bluetooth.nix
    ../../modules/hosts/aurora/hardware/steam.nix
    ../../modules/hosts/aurora/networking/base.nix
    ../../modules/hosts/aurora/networking/vpn.nix
    ../../modules/hosts/aurora/networking/tailscale.nix
    ../../modules/hosts/aurora/hardware/nvidia.nix
    ../../modules/hosts/aurora/packages/profiles/core.nix
    ../../modules/hosts/aurora/packages/profiles/desktop.nix
    ../../modules/hosts/aurora/packages/profiles/gaming.nix
    ../../modules/hosts/aurora/packages/profiles/fonts.nix
    ../../modules/hosts/aurora/packages/volta.nix
    ../../modules/hosts/aurora/session/sway.nix
    ../../modules/hosts/aurora/session/display-manager.nix
    ../../modules/hosts/aurora/session/portals.nix
    ../../modules/hosts/shared/users/giks.nix
  ]
  ++ lib.optionals (lib.elem "dev" roles) [
    ../../modules/hosts/aurora/packages/profiles/dev.nix
  ];

  # Shared module activations
  myModules.profiles.core.enable = true;
  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  myModules.hardware.steam.enable = true;
  myModules.profiles.gaming.enable = true;
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
