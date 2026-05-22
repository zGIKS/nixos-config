{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.services.asus;
in
{
  options.myModules.services.asus = {
    enable = lib.mkEnableOption "ASUS ROG laptop services (asusd, supergfxd)";

    userService = {
      enable = lib.mkEnableOption "per-user asusd instance" // {
        default = false;
      };
    };

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
      enableUserService = cfg.userService.enable;
    };

    services.supergfxd.enable = true;

    programs.rog-control-center = {
      enable = cfg.rogControlCenter.enable;
      autoStart = cfg.rogControlCenter.autoStart;
    };
  };
}
