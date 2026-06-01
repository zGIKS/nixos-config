{ config, lib, pkgs, username, roles, keyboardLayout, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/system/defaults.nix
    ../../modules/kernel/boot.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/networking/base.nix
    ../../modules/networking/vpn.nix
    ../../modules/networking/tailscale.nix
    ../../modules/services/pipewire.nix
    ../../modules/services/printing.nix
    ../../modules/services/keyring.nix
    ../../modules/services/flatpak.nix
    ../../modules/services/asus.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/kernel/memory.nix
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
    ../../modules/services/android-debugging.nix
    ../../modules/services/docker.nix
  ];

  # Shared module activations
  myModules.profiles.core.enable = true;
  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  platform.services.androidDebugging.enable = lib.elem "dev" roles;
  platform.services.docker.enable = lib.elem "dev" roles;

  myModules.profiles.dev = {
    enable = lib.elem "dev" roles;
    latex.enable = lib.elem "dev" roles;
    java.enable = lib.elem "dev" roles;
    lsp.enable = lib.elem "dev" roles;
  };

  # Host-specific facts
  networking.hostName = "aurora";
  services.xserver.xkb.layout = keyboardLayout;

  # Hardware layer activation
  myModules.hardware.nvidia.enable = true;
  myModules.kernel.memory.enable = true;

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
  environment.systemPackages = with pkgs; [
  ];

  # Install heavier GUI dev apps via Home Manager on this host.
  home-manager.users.${username}.myHome.apps.devGui.enable = true;
}
