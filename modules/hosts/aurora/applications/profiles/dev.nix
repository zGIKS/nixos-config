{ config, lib, pkgs, username, ... }:

let
  cfg = config.myModules.profiles.dev;
in
{
  options.myModules.profiles.dev = {
    enable = lib.mkEnableOption "developer profile";
    latex.enable = lib.mkEnableOption "LaTeX tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wpsoffice
      zed-editor
      jetbrains.idea
      android-studio
    ]
    ++ lib.optionals cfg.latex.enable [
      texliveFull
    ]
    ;
  };
}
