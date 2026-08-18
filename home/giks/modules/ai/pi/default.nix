{ pi, lib, personalNotes, ... }:
{
  imports = [
    pi.homeModules.default
    ./settings.nix
    ./packages.nix
    ./agents.nix
    (import ../shared/skills.nix {
      inherit lib personalNotes;
      target = ".pi/agent/skills";
    })
  ];
}
