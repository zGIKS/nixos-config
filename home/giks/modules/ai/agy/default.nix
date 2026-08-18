{ lib, personalNotes, ... }:
{
  imports = [
    ./agents.nix
    (import ../shared/skills.nix {
      inherit lib personalNotes;
      target = ".gemini/antigravity-cli/skills";
    })
  ];
}
