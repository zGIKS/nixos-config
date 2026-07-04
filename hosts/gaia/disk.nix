{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ee76f657-e18f-4c4d-8e65-d9b510b64422";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0ECC-F156";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];
}
