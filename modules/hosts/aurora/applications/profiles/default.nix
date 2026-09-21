{ lib, roles, ... }:

# Aggregator + role-based activator for aurora's application profile modules.
#
# This replaces the previous implicit enable lines that lived in
# hosts/aurora/default.nix. The actual package modules live in the
# subdirectories (browsers/, editors/, gaming/) and are imported via
# each subdir's default.nix.
{
  imports = [
    ./browsers
    ./editors
    ./gaming
  ];

  # Role-based activation. Mirrors the pattern used by
  # shared/environment/profiles/desktop-dev.nix but scoped to aurora-only modules.
  myModules.profiles.editors.enable = lib.elem "dev" roles;
}