{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.services.asus;
in
{
  options.myModules.services.asus = {
    enable = lib.mkEnableOption "ASUS ROG laptop services (asusd, supergfxd)";

    rogControlCenter = {
      enable = lib.mkEnableOption "ROG Control Center GUI" // {
        default = false;
      };

      autoStart = lib.mkEnableOption "automatically start ROG Control Center on session login" // {
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.supergfxctl ];

    services.asusd = {
      enable = true;
    };

    services.supergfxd.enable = true;

    programs.rog-control-center = {
      enable = cfg.rogControlCenter.enable;
      autoStart = cfg.rogControlCenter.autoStart;
    };
  };
}
