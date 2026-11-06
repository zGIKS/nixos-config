{ lib, roles, ... }:

{
  options.myModules.profiles.ai.enable = lib.mkEnableOption "AI development tools" // {
    default = lib.elem "dev" roles;
  };

  imports = [ ./airi.nix ];
}
