{ username, ... }:
{
  home.stateVersion = "25.11";
  home.username = username;

  imports = [
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/nvim.nix
    ./modules/theme.nix
    ./modules/session/sway.nix
    ./modules/session/waybar.nix
    ./modules/session/wofi.nix
    ./modules/session/eww.nix
    ./modules/session/apps.nix
  ];

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
}
