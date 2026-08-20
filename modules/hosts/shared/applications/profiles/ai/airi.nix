{ config, lib, pkgs, airi, ... }:

let
  cfg = config.myModules.profiles.ai;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.myModules.profiles.ai = {
    claudeCode.enable = lib.mkEnableOption "Claude Code" // { default = true; };
    codex.enable = lib.mkEnableOption "OpenAI Codex CLI" // { default = true; };
    antigravity.enable = lib.mkEnableOption "Antigravity CLI (agy)" // { default = true; };
    pi.enable = lib.mkEnableOption "Pi coding agent" // { default = true; };
    herdr.enable = lib.mkEnableOption "Herdr terminal workspace manager" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optionals cfg.claudeCode.enable [ airi.packages.${system}.claude-code ]
      ++ lib.optionals cfg.codex.enable [ airi.packages.${system}.codex ]
      ++ lib.optionals cfg.antigravity.enable [ airi.packages.${system}.antigravity-cli ]
      ++ lib.optionals cfg.pi.enable [ airi.packages.${system}.pi-coding-agent ]
      ++ lib.optionals cfg.herdr.enable [ airi.packages.${system}.herdr ];
  };
}
