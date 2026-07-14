{ ... }:

{
  boot.loader = {
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 8;
      extraEntries = ''
        menuentry "Windows 11" {
          insmod part_gpt
          insmod fat
          search --no-floppy --file --set=root /EFI/Microsoft/Boot/bootmgfw.efi
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };

    systemd-boot.enable = false;
    timeout = 3;
  };
}
