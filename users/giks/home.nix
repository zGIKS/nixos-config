{ username, ... }:
{
  home.stateVersion = "25.11";
  home.username = username;

  imports = [
    ../../modules/home/git.nix
    ../../modules/home/programs/shell.nix
    ../../modules/home/programs/apps.nix
    ../../modules/home/programs/sway.nix
    ../../modules/home/programs/waybar.nix
    ../../modules/home/programs/wofi.nix
  ];

  myHome.git = {
    enable = true;
    userName = "zGIKS";
    userEmail = "mateo@giks.net";
  };

  home.file.".gitignore_global".text = ''
  '';
}
