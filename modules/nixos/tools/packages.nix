{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vscode
    starship
    zellij
    pipes
    alacritty
    bash-completion
    fish
    cava
    cmatrix
    discord
    fastfetch
    gh
    nano
    os-prober
    efibootmgr
    spotify
  ];
}
