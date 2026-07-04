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

  config = {
    sops.secrets.cloudflaredCredentials = { };

    myModules.services.cloudflared = {
      enable = true;
      tunnelId = "f9c5f49d-9225-4ea8-9795-10047d606079";
      routes = [
        {
          hostname = "clair-api.giks.net";
          upstream = "http://127.0.0.1:8081";
        }
        {
          hostname = "clair-edge.giks.net";
          upstream = "http://127.0.0.1:5000";
        }
      ];
      credentialsFile = config.sops.secrets.cloudflaredCredentials.path;
    };

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
