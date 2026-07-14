{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/32a2282f-2e17-4fd4-92f9-e53cd75e3e2b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DEB2-4712";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];
}
