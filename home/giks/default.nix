{ username, airi, pkgs, ... }:
let
  piPackage = airi.packages.${pkgs.stdenv.hostPlatform.system}.pi-coding-agent;
  piPackageWithXaiVersion = pkgs.symlinkJoin {
    name = "pi-coding-agent-${piPackage.version}-xai-oauth";
    inherit (piPackage) version meta;
    paths = [ piPackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/pi"
      makeWrapper "${piPackage}/bin/pi" "$out/bin/pi" \
        --set-default PI_XAI_CLIENT_VERSION 1.0.13
    '';
  };
in
{
  home.stateVersion = "25.11";
  home.username = username;

  imports = [
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/nvim
    ./modules/theme.nix
    airi.homeModules.ai
    ./modules/session/sway.nix
    ./modules/session/waybar.nix
    ./modules/session/fuzzel.nix
    ./modules/session/eww.nix
  ];

  programs.pi.coding-agent.package = piPackageWithXaiVersion;

  myHome.git.enable = true;
  myHome.nvim.enable = true;

  home.sessionVariables = {
    BROWSER = "brave";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "application/xhtml+xml" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
    };
  };

  home.file.".gitignore_global".text = ''
  '';

  home.file.".gemini/antigravity-cli/settings.json".force = true;
}
