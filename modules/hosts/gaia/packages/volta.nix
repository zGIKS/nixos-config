{ pkgs, username, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    libcap
  ];

  environment.systemPackages = with pkgs; [
    bubblewrap
    volta
  ];
}
