{ pi, personalNotes, ... }:

{
  imports = [ pi.homeModules.default ];

  programs.pi.coding-agent = {
    enable = true;
    skills = [
      "${personalNotes}/skills/operating-systems/nixos-multi-host-architecture"
      "${personalNotes}/skills/software-engineering/domain-driven-design-ddd/angular"
      "${personalNotes}/skills/software-engineering/domain-driven-design-ddd/flutter"
      "${personalNotes}/skills/software-engineering/domain-driven-design-ddd/java-25"
      "${personalNotes}/skills/software-engineering/domain-driven-design-ddd/next"
    ];
  };
}
