{ pkgs, ... }:

{
  services.tailscale.enable = true; # runs tailscaled
  environment.systemPackages = [ pkgs.tailscale ];
}
