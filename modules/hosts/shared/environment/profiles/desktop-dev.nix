{ lib, roles, ... }:

# roles comes from flake.nix specialArgs. The language/tool modules receive
# nit and pomodog through the same specialArgs mechanism.
{
  myModules.profiles.core.enable = true;
  myModules.profiles.desktopApps.enable = lib.elem "desktop" roles;
  myModules.profiles.development.datagrip.enable = true;

  myModules.profiles.languages.go.enable = lib.elem "dev" roles;
  myModules.profiles.languages.lsp.enable = lib.elem "dev" roles;
  myModules.profiles.languages.node.enable = lib.elem "dev" roles;
  myModules.profiles.languages.python.enable = lib.elem "dev" roles;
  myModules.profiles.languages.rust.enable = lib.elem "dev" roles;

  myModules.profiles.development.nit.enable = lib.elem "dev" roles;
  myModules.profiles.productivity.pomodog.enable = lib.elem "desktop" roles;
}
