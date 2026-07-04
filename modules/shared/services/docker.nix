{ config, lib, pkgs, username, ... }:

let
  cfg = config.platform.services.docker;
in
{
  options.platform.services.docker.enable = lib.mkEnableOption "Docker virtualization";

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.package = pkgs.docker_29;
    users.extraGroups.docker.members = [ username ];

    environment.systemPackages = with pkgs; [
      docker_29
      docker-buildx
      docker-compose
    ];
  };
}
