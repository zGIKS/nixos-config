{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.languages.latex;
in
{
  options.myModules.profiles.languages.latex.enable = lib.mkEnableOption "LaTeX toolchain (texliveFull)" // {
    default = lib.elem "dev" roles;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      texliveFull
    ];
  };
}
