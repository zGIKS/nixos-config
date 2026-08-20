{ config, lib, nixvim, ... }:

let
  cfg = config.myHome.nvim;
in
{
  imports = [
    nixvim.homeModules.nixvim
    ./options.nix
    ./core.nix
    ./appearance.nix
    ./navigation.nix
    ./languages.nix
    ./lsp.nix
  ];

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    programs.nixvim = {
      enable = true;
      # We intentionally follow nixpkgs; the resulting version-mismatch
      # warning against nixvim's own pin is expected.
      version.enableNixpkgsReleaseCheck = false;
    };
  };
}
