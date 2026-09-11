{
  imports = [
    ./docker.nix
    ./keyring.nix
    ./mounts.nix
    ./pipewire.nix
    ../../../shared/system/services/openssh.nix
  ];
}
