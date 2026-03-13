{ pkgs, ... }:

{
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    volta
    codex
  ];

  environment.sessionVariables = {
    VOLTA_HOME = "/home/giks/.volta";
  };

  environment.shellInit = ''
    export PATH="$HOME/.volta/bin:$PATH"
  '';
}
