{ username, ... }:
{
  home.stateVersion = "25.11";
  home.username = username;

  imports = [
    ../../modules/home/git.nix
    ../../modules/home/programs/shell.nix
    ../../modules/home/programs/apps.nix
    ../../modules/home/programs/eww.nix
    ../../modules/home/programs/sway.nix
    ../../modules/home/programs/waybar.nix
    ../../modules/home/programs/wofi.nix
    ../../modules/home/programs/theme.nix
  ];

  myHome.git = {
    enable = true;
    userName = "zGIKS";
    userEmail = "mateo@giks.net";
  };

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
