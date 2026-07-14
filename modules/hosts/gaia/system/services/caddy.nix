{ pkgs, ... }:

let
  ports = {
    caddy = "8088";
    clair-api = "8081";
    clair-edge = "5000";
  };
in
{
  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" ''
      :${ports.caddy} {
        @api host clair-api.giks.net
        handle @api {
          reverse_proxy 127.0.0.1:${ports.clair-api}
        }

        @edge host clair-edge.giks.net
        handle @edge {
          reverse_proxy 127.0.0.1:${ports.clair-edge}
        }

        respond "not found" 404
      }
    '';
  };
}
