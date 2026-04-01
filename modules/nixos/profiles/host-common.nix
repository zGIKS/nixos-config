{ pkgs, lib, username, hostName, roles, keyboardLayout, ... }:

{
  imports = [
    ../boot/grub-uefi.nix
    ../desktop/sway.nix
    ./core.nix
    ./desktop.nix
    ./dev.nix
    ../tools/volta.nix
  ];

  myModules.desktop.sway.enable = lib.elem "desktop" roles;
  myModules.profiles.core.enable = true;
  myModules.profiles.desktop.enable = lib.elem "desktop" roles;
  myModules.profiles.dev.enable = lib.elem "dev" roles;
  myModules.tools.volta = {
    enable = lib.elem "dev" roles;
    user = username;
  };

  boot.loader.grub.extraEntries = ''
    menuentry "Windows 11" {
      insmod part_gpt
      insmod fat
      search --no-floppy --file --set=root /EFI/Microsoft/Boot/bootmgfw.efi
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';

  networking.hostName = hostName;
  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  time.timeZone = "America/Lima";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = keyboardLayout;
    variant = "";
  };

  services.displayManager.sddm.enable = false;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  console.useXkbConfig = true;
  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    description = "Matteo Aleman";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
