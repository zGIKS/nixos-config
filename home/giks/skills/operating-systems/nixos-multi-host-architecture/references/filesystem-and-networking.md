# Filesystem, Storage, and Networking Layers

## 5. Filesystem and storage layer

Location: `hosts/<host-name>/` for machine facts and
`modules/hosts/<scope>/system/storage/` for reusable policy.

This layer manages storage layout and persistence.

Typical responsibilities:

- filesystems and mount points;
- encrypted devices;
- swap;
- RAID or volume management;
- disk layout policy;
- persistence and impermanence policy;
- storage-related scheduled maintenance.

Host-specific device identifiers belong in the host directory. Reusable mount
or persistence policy belongs in a module.

### Declarative Storage Specifications

1. **Persistent Device Identifiers (UUIDs or Labels)**:
   Never use kernel-assigned disk names like `/dev/sda1` or `/dev/nvme0n1p2`, as they can change between boots or upon hardware changes. Always reference devices by UUID or filesystem label:
   ```nix
   # hosts/<host>/disk.nix
   fileSystems."/" = {
     device = "/dev/disk/by-label/nixos-root";
     # Or: device = "/dev/disk/by-uuid/3fa85f64-42b1-4c12-870a-0c2d334e5678";
     fsType = "ext4";
     options = [ "noatime" "discard" ];
   };

   fileSystems."/boot" = {
     device = "/dev/disk/by-label/BOOT";
     fsType = "vfat";
     options = [ "fmask=0077" "dmask=0077" ];
   };

   swapDevices = [
     { device = "/dev/disk/by-label/nixos-swap"; }
   ];
   ```

2. **Declarative LUKS Encryption in Initrd**:
   Configure full-disk or partition encryption declaratively for early-boot unlocking:
   ```nix
   boot.initrd.luks.devices."cryptroot" = {
     device = "/dev/disk/by-uuid/e8179ca1-3329-4d69-b5f7-92003c4314c1";
     preLVM = true;
     allowDiscards = true;
   };
   ```

## 6. Networking layer

Location: `modules/hosts/<scope>/system/networking/`.

The networking layer manages communication and network policy.

Typical responsibilities:

- host names;
- firewall policy;
- DNS;
- NetworkManager or equivalent networking;
- VPNs;
- routing;
- wireless policy;
- Tailscale or similar network integration.

The networking layer may configure connectivity required by a service, but the
service daemon itself belongs in the services layer.

### Declarative Networking Patterns

1. **Host Identity and Declarative Firewall**:
   Every host must declare its identity and explicit firewall policy:
   ```nix
   networking.hostName = "srv-core-01";
   networking.firewall = {
     enable = true;
     allowedTCPPorts = [ 22 80 443 ];
     allowedUDPPorts = [ ];
     allowPing = true;
   };
   ```

2. **NetworkManager for Desktops and Laptops**:
   For interactive workstations, laptops, and machines with roaming wireless or VPN requirements:
   ```nix
   networking.networkmanager.enable = true;
   # Avoid running conflicting legacy DHCP daemons alongside NetworkManager
   networking.useDHCP = lib.mkDefault false;
   ```

3. **`systemd-networkd` for Servers and Headless Hosts**:
   For stable server infrastructure, virtualization hosts, and cloud instances, use `systemd-networkd`:
   ```nix
   networking.useNetworkd = true;
   systemd.network = {
     enable = true;
     networks."10-lan" = {
       matchConfig.Name = "en*";
       networkConfig = {
         DHCP = "ipv4";
         IPv6AcceptRA = true;
       };
     };
   };
   ```
