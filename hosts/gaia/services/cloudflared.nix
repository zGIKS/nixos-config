{ config, ... }:

{
  sops.secrets.cloudflaredCredentials = { };

  myModules.services.cloudflared = {
    enable = true;
    tunnelId = "f9c5f49d-9225-4ea8-9795-10047d606079";
    routes = [
      {
        hostname = "clair-api.giks.net";
        upstream = "http://127.0.0.1:8088";
      }
      {
        hostname = "clair-edge.giks.net";
        upstream = "http://127.0.0.1:8088";
      }
    ];
    credentialsFile = config.sops.secrets.cloudflaredCredentials.path;
  };
}
