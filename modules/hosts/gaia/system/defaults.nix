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
        "idea"
        "android-studio"
        "typora"
        "vscode"
        "wpsoffice"
        "corefonts"
      "vista-fonts"
      "symbola"
      "nvidia-x11"
      "nvidia-kernel-modules"
      "nvidia-settings"
      "nvidia-persistenced"
      "nvidia-persistenced-1.0"
      "brave"
      "libsciter"
      "rustdesk"
      "steam"
      "steam-original"
      "steam-unwrapped"
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
}
