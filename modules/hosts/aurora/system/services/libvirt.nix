{ config, lib, pkgs, username, ... }:

let
  cfg = config.platform.services.libvirt;
in
{
  options.platform.services.libvirt.enable = lib.mkEnableOption "KVM/libvirt virtual machines";

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };

    programs.virt-manager.enable = true;
    users.extraGroups.libvirtd.members = [ username ];
    environment.systemPackages = [ pkgs.virtio-win ];
  };
}
