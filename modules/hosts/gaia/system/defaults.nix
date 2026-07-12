{ lib, ... }:

{
  time.timeZone = "America/Lima";
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  nixpkgs.config.allowUnfreePredicate = pkg: 
    let 
      name = lib.getName pkg;
    in 
      builtins.elem name [
        "google-chrome"
        "discord"
        "spotify"
        "datagrip"
        "typora"
        "vscode"
        "corefonts"
        "vista-fonts"
        "symbola"
        "brave"
        "libsciter"
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
}
