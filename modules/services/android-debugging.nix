{ config, lib, pkgs, username, ... }:

let
  cfg = config.platform.services.androidDebugging;
in
{
  options.platform.services.androidDebugging.enable = lib.mkEnableOption "Android debugging over ADB";

  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;

    users.groups.adbusers = { };
    users.users.${username}.extraGroups = [ "adbusers" ];

    environment.systemPackages = with pkgs; [
      android-tools
      usbutils
    ];
  };
}
