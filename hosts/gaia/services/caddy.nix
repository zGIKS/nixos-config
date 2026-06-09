{ pkgs, ... }:

{
  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" ''
      :8088 {
        @api host clair-api.giks.net
        handle @api {
          reverse_proxy 127.0.0.1:8081
        }

        @edge host clair-edge.giks.net
        handle @edge {
          reverse_proxy 127.0.0.1:5000
        }

        respond "not found" 404
      }
    '';
  };
}
