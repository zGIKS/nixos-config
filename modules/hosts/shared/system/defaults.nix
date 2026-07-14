{ config, lib, ... }:

{
  options.myModules.system.unfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [
      "datagrip"
      "typora"
      "vscode"
      "corefonts"
      "vista-fonts"
      "symbola"
      "brave"
      "libsciter"
    ];
  };

  config = {
    time.timeZone = "America/Lima";
    i18n.defaultLocale = "en_US.UTF-8";
    console.useXkbConfig = true;

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) config.myModules.system.unfreePackages;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "25.11";
  };
}
