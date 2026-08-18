{ lib, personalNotes, target, ... }:

let
  skills = [
    "operating-systems/nixos-multi-host-architecture"
    "software-design/design-system-patterns"
    "software-design/frontend-design"
    "software-design/impeccable"
    "software-design/shadcn"
    "software-design/tailwind-design-system"
    "software-design/ui-design"
    "software-design/vercel-composition-patterns"
    "software-design/web-design-guidelines"
    "software-engineering/domain-driven-design-ddd/angular"
    "software-engineering/domain-driven-design-ddd/flutter"
    "software-engineering/domain-driven-design-ddd/java-25"
    "software-engineering/domain-driven-design-ddd/next"
    "software-engineering/test-driven-development-tdb/java"
    "software-engineering/test-driven-development-tdb/next"
    "software-testing-qa/testing-by-method"
  ];
in
{
  home.file = lib.listToAttrs (map (skill: {
    name = "${target}/${skill}";
    value.source = "${personalNotes}/skills/${skill}";
  }) skills);
}
