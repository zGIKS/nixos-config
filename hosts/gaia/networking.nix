{ ... }:

{
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  services.resolved.fallbackDns = [
    "1.1.1.1"
    "8.8.8.8"
  ];
}
