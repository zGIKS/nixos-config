{ config, lib, pkgs, pomodog, roles, ... }:

let
  cfg = config.myHome.apps;
in
{
  options.myHome.apps = {
    kimi.enable = lib.mkEnableOption "Kimi Code CLI" // {
      default = lib.elem "dev" roles;
    };
  };

  config.home.sessionPath = lib.optionals cfg.kimi.enable [
    "$HOME/.local/bin"
  ];

  config.home.activation.installKimiCli = lib.mkIf cfg.kimi.enable (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -x "$HOME/.local/bin/kimi" ]; then
        $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install --python ${pkgs.python313}/bin/python3.13 kimi-cli
      fi
    ''
  );

}
