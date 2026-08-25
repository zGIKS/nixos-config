{ config, lib, ... }:

{
  imports = [
    ./sops.nix
  ];

  options.myModules.system.unfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config = {
    myModules.system.unfreePackages = [
      "datagrip"
      "typora"
      "vscode"
      "corefonts"
      "vista-fonts"
      "symbola"
      "brave"
      "google-antigravity"
      "libsciter"
      "discord-ptb"
    ];

    time.timeZone = "America/Lima";
    i18n.defaultLocale = "en_US.UTF-8";
    console.useXkbConfig = true;

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) config.myModules.system.unfreePackages;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "25.11";
  };
}
