{ lib, personalNotes, target, flatten ? false, ... }:

let
  # flatName is only used when flatten = true. It defaults to the last path
  # segment, overridden where that would collide with another skill's last
  # segment (both DDD's and TDD's Next.js skills end in "next").
  skills = [
    { path = "operating-systems/nixos-multi-host-architecture"; }
    { path = "software-design/design-system-patterns"; }
    { path = "software-design/frontend-design"; }
    { path = "software-design/impeccable"; }
    { path = "software-design/shadcn"; }
    { path = "software-design/tailwind-design-system"; }
    { path = "software-design/ui-design"; }
    { path = "software-design/vercel-composition-patterns"; }
    { path = "software-design/web-design-guidelines"; }
    { path = "software-engineering/domain-driven-design-ddd/angular"; }
    { path = "software-engineering/domain-driven-design-ddd/flutter"; }
    { path = "software-engineering/domain-driven-design-ddd/java-25"; }
    { path = "software-engineering/domain-driven-design-ddd/next"; flatName = "ddd-next"; }
    { path = "software-engineering/test-driven-development-tdb/java"; }
    { path = "software-engineering/test-driven-development-tdb/next"; flatName = "tdd-next"; }
    { path = "software-testing-qa/testing-by-method/mutation"; flatName = "mutation-testing"; }
  ];
in
{
  home.file = lib.listToAttrs (map (skill:
    let
      flatName = skill.flatName or (lib.last (lib.splitString "/" skill.path));
    in
    {
      name = if flatten then "${target}/${flatName}" else "${target}/${skill.path}";
      value.source = "${personalNotes}/skills/${skill.path}";
    }
  ) skills);
}
