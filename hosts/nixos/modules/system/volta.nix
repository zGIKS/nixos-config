{ lib, pkgs, ... }:

let
  voltaPackages = [
    "node@lts"
    "pnpm"
    "yarn"
    "@anthropic-ai/claude-code"
    "@github/copilot"
    "@google/gemini-cli"
    "eslint"
    "prettier"
    "@astrojs/language-server"
    "tailwindcss"
    "typescript"
    "typescript-language-server"
    "@tailwindcss/language-server"
    "bash-language-server"
    "pyright"
    "svelte-language-server"
    "vscode-langservers-extracted"
  ];

  voltaPackageList = pkgs.writeText "volta-packages" ''
    ${lib.concatStringsSep "\n" voltaPackages}
  '';
in
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

  systemd.services.volta-sync-giks = {
    description = "Sync Volta-managed Node tooling";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    restartTriggers = [ voltaPackageList ];

    path = with pkgs; [
      bash
      coreutils
      volta
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "giks";
    };

    script = ''
      set -euo pipefail

      export HOME="/home/giks"
      export USER="giks"
      export VOLTA_HOME="$HOME/.volta"
      export PATH="${pkgs.volta}/bin:$VOLTA_HOME/bin:$PATH"

      mkdir -p "$VOLTA_HOME"

      while IFS= read -r package; do
        [ -n "$package" ] || continue
        ${pkgs.volta}/bin/volta install "$package"
      done < ${voltaPackageList}
    '';
  };
}
