{ ... }:

{
  home.stateVersion = "25.11";

  imports = [
    ./git.nix
  ];

  home.file.".gitignore_global".text = ''
  '';
}
