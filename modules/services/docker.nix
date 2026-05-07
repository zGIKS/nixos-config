{ config, lib, pkgs, username, ... }:

let
  cfg = config.platform.services.docker;
in
{
  options.platform.services.docker.enable = lib.mkEnableOption "Docker virtualization";

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    users.extraGroups.docker.members = [ username ];

    environment.systemPackages = with pkgs; [
      docker
      docker-buildx
      docker-compose
    ];
  };
}
