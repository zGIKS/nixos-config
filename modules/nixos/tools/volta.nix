{ config, lib, pkgs, ... }:

{
  options.myModules.tools.volta = {
    enable = lib.mkEnableOption "Volta runtime tooling";
    user = lib.mkOption {
      type = lib.types.str;
      default = "giks";
    };
  };

  config = lib.mkIf config.myModules.tools.volta.enable {
    programs.nix-ld.enable = true;

    environment.systemPackages = with pkgs; [
      volta
      codex
    ];

    environment.sessionVariables = {
      VOLTA_HOME = "/home/${config.myModules.tools.volta.user}/.volta";
    };

    environment.shellInit = ''
      export PATH="$HOME/.volta/bin:$PATH"
    '';
  };
}
