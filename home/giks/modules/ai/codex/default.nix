{ lib, personalNotes, ... }:
{
  imports = [
    ./agents.nix
    ./settings.nix
    (import ../shared/skills.nix {
      inherit lib personalNotes;
      target = ".agents/skills";
    })
  ];
}
