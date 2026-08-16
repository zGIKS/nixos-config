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

    settings = {
      defaultThinkingLevel = "medium";
      enableSkillCommands = true;
      packages = [
        "npm:pi-subagents"
        "npm:pi-web-access"
        "npm:@narumitw/pi-lsp"
        "npm:@narumitw/pi-plan-mode"
      ];
      subagents = {
        projectRootResolution = "git-root";
        defaultThinking = "medium";

        agentOverrides = {
          explorer = {
            thinking = "low";
            inheritProjectContext = true;
            inheritSkills = true;
            defaultContext = "fresh";
          };

          researcher = {
            thinking = "medium";
            inheritProjectContext = true;
            inheritSkills = true;
            defaultContext = "fresh";
          };

          architect = {
            thinking = "high";
            inheritProjectContext = true;
            inheritSkills = true;
            defaultContext = "fork";
          };

          developer = {
            thinking = "medium";
            inheritProjectContext = true;
            inheritSkills = true;
            defaultContext = "fork";
          };

          tester = {
            thinking = "medium";
            inheritProjectContext = true;
            inheritSkills = true;
            defaultContext = "fresh";
          };

          reviewer = {
            thinking = "high";
            inheritProjectContext = true;
            inheritSkills = true;
            defaultContext = "fresh";
          };
        };
      };
    };
  };
}
