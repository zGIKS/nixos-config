{ ... }:

{
  home.stateVersion = "25.11";

  imports = [
    ../../modules/home/git.nix
  ];

  home.file.".gitignore_global".text = ''
  '';
}
