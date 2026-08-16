{ pi, personalNotes, ... }:

{
  imports = [ pi.homeModules.default ];

  programs.pi.coding-agent = {
    enable = true;
    skills = [
      "${personalNotes}/skills/software-engineering/domain-driven-design-ddd/next"
      "${personalNotes}/skills/software-engineering/domain-driven-design-ddd/java-25"
    ];
  };
}
