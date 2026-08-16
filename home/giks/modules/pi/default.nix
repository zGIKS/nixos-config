{ pi, personalNotes, ... }:
{
  imports = [
    pi.homeModules.default
    ./settings.nix
    ./skills.nix
    ./packages.nix
    ./agents
  ];
}
