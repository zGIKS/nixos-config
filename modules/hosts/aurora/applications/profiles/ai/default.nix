{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.ai;

  # Vendored from https://github.com/09641061/airi. Each tool fetches its
  # official prebuilt release; versions and hashes stay pinned beside this profile.
  aiPackages = pkgs.callPackage ./packages { };
in
{
  options.myModules.profiles.ai = {
    enable = lib.mkEnableOption "AI development tools" // {
      default = lib.elem "dev" roles;
    };
    claudeCode.enable = lib.mkEnableOption "Claude Code" // { default = true; };
    codex.enable = lib.mkEnableOption "OpenAI Codex CLI" // { default = true; };
    antigravity.enable = lib.mkEnableOption "Antigravity CLI (agy)" // { default = true; };
    piCodingAgent.enable = lib.mkEnableOption "Pi coding agent" // { default = true; };
    herdr.enable = lib.mkEnableOption "Herdr terminal workspace manager" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      lib.optional cfg.claudeCode.enable aiPackages.claude-code
      ++ lib.optional cfg.codex.enable aiPackages.codex
      ++ lib.optional cfg.antigravity.enable aiPackages.antigravity-cli
      ++ lib.optional cfg.piCodingAgent.enable aiPackages.pi-coding-agent
      ++ lib.optional cfg.herdr.enable aiPackages.herdr;
  };
}
