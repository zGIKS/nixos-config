{ pkgs, ... }:

{
  imports = [
    ../../modules/nixos/boot/grub-uefi.nix
    ./hardware-configuration.nix
    ../../modules/nixos/desktop/plasma.nix
    ../../modules/nixos/tools/packages.nix
    ../../modules/nixos/tools/volta.nix
  ];

  boot.loader.grub.extraEntries = ''
    menuentry "Windows 11" {
      insmod part_gpt
      insmod fat
      search --no-floppy --file --set=root /EFI/Microsoft/Boot/bootmgfw.efi
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Lima";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "latam";
    variant = "";
  };

  console.keyMap = "la-latin1";
  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.giks = {
    isNormalUser = true;
    description = "Matteo Aleman";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
