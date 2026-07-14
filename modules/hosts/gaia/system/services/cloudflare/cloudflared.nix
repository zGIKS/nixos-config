{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.services.cloudflared;
in
{
  options.myModules.services.cloudflared.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.cloudflared;
    description = "Package used to run the Cloudflare Tunnel daemon.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
