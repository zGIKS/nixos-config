{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.services.cloudflared;
  yaml = pkgs.formats.yaml { };
in
{
  options.myModules.services.cloudflared = {
    enable = lib.mkEnableOption "Cloudflare Tunnel daemon";

    tunnelId = lib.mkOption {
      type = lib.types.str;
      description = "Cloudflare tunnel UUID.";
    };

    routes = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          hostname = lib.mkOption {
            type = lib.types.str;
            description = "Public hostname routed through the tunnel.";
          };

          upstream = lib.mkOption {
            type = lib.types.str;
            description = "Local service URL exposed through the tunnel.";
          };
        };
      });
      description = "Hostname to upstream routes exposed through the tunnel.";
    };

    credentialsFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the tunnel credentials JSON file.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cloudflared ];

    environment.etc."cloudflared/config.yml".source =
      yaml.generate "cloudflared-config.yml" {
        tunnel = cfg.tunnelId;
        "credentials-file" = cfg.credentialsFile;
        ingress = map (route: {
          hostname = route.hostname;
          service = route.upstream;
        }) cfg.routes ++ [
          { service = "http_status:404"; }
        ];
      };

    systemd.services.cloudflared = {
      description = "Cloudflare Tunnel";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run ${cfg.tunnelId}";
        Restart = "on-failure";
      };
    };
  };
}
