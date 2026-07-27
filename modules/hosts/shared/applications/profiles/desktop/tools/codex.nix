{ config, codexDesktopLinux, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.tools.codex;
in
{
  options.myModules.profiles.tools.codex.enable = lib.mkEnableOption "Codex desktop app" // {
    default = lib.elem "desktop" roles;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      codexDesktopLinux.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
