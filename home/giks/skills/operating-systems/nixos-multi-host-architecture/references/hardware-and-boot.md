# Hardware and Boot Layers

## 3. Hardware layer

Location: `modules/hosts/<scope>/hardware/`.

The hardware layer describes physical devices and hardware-dependent behavior.

Typical responsibilities:

- GPU drivers and firmware;
- Bluetooth and wireless devices;
- audio hardware;
- CPU or platform-specific settings;
- power-management behavior;
- device-specific kernel modules;
- hardware-dependent graphical workarounds.

Hardware discovery output should remain separate from hand-written hardware
policy whenever possible.

Do not place general applications, user preferences, or unrelated networking
rules in this layer.

### Hardware Fact Management (Patterns 5.1, 5.2, 5.5)

1. **Keep `hardware-configuration.nix` Generated and Unedited (Pattern 5.1)**:
   - Generated automatically by `nixos-generate-config`.
   - Contains discovered machine facts: kernel modules (`boot.initrd.availableKernelModules`), microcode updates, and platform quirks.
   - **Rule**: Never manually modify `hardware-configuration.nix`. Place all custom hardware policies (e.g. graphics drivers, CPU frequency governors, undervolting, custom kernel options) in separate, tracked modules (e.g., `modules/hosts/shared/hardware/nvidia.nix`).

2. **Official Hardware Profiles: `nixos-hardware` (Pattern 5.2)**:
   For laptops, standard workstations, and SBCs with known hardware quirks, import official vendor/model profiles from the `nixos-hardware` organization rather than maintaining complex hand-written hardware workarounds:
   ```nix
   # flake.nix
   inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

   # hosts/laptop-01/default.nix
   imports = [
     ./hardware-configuration.nix
     inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen3
   ];
   ```

3. **Emerging Declarative Hardware: `nixos-facter` (Pattern 5.5)**:
   Modern reproducible fleets can utilize `nixos-facter` to record immutable, JSON-serialized hardware facts without relying on legacy Perl generator scripts:
   ```nix
   hardware.facter.reportPath = ./facter.json;
   ```

## 4. Boot and kernel layer

Location: `modules/hosts/<scope>/boot/`.

The boot layer controls how the system starts and which kernel behavior it uses.

Typical responsibilities:

- bootloader configuration;
- kernel package selection;
- initrd configuration;
- kernel modules and parameters;
- early-boot networking;
- boot-time security and recovery settings;
- low-level system tuning.

Filesystem declarations belong in the filesystem layer unless they are
unavoidably coupled to initrd or bootloader behavior.

### Declarative Bootloader Standards (Pattern 5.3)

1. **Modern UEFI Systems (`systemd-boot`)**:
   Standard choice for modern UEFI x86_64 and AArch64 hardware:
   ```nix
   boot.loader.systemd-boot = {
     enable = true;
     configurationLimit = 15; # Limit generations in boot menu
     editor = false;          # Prevent arbitrary kernel parameter injection at console
   };
   boot.loader.efi.canTouchEfiVariables = true;
   ```

2. **Legacy BIOS or Complex Partitioning (`GRUB`)**:
   For dual-booting, legacy MBR disks, or ZFS-on-root:
   ```nix
   boot.loader.grub = {
     enable = true;
     device = "/dev/sda"; # Or "nodev" for UEFI GRUB
     efiSupport = true;
     canTouchEfiVariables = true;
   };
   ```
