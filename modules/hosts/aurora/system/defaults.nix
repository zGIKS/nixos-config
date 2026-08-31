{ lib, ... }:

{
  myModules.system.unfreePackages = lib.mkAfter [
    "google-chrome"
    "idea"
    "android-studio"
    "wpsoffice"
    "nvidia-x11"
    "nvidia-kernel-modules"
    "nvidia-settings"
    "nvidia-persistenced"
    "nvidia-persistenced-1.0"
    "rustdesk"
    "steam"
    "steam-original"
    "steam-unwrapped"
  ];
}
