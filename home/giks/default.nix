{ username, lib, ... }:
{
  home.stateVersion = "25.11";
  home.username = username;

  imports = [
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/nvim
    ./modules/theme.nix
    ./modules/pi
    ./modules/agents
    ./modules/session/sway.nix
    ./modules/session/waybar.nix
    ./modules/session/fuzzel.nix
    ./modules/session/eww.nix
  ];

  myHome.git.enable = true;
  myHome.nvim.enable = true;
  myHome.pi = {
    enable = true;
    # Merged into the live settings.json, so theme and model survive rebuilds.
    settings = {
      defaultThinkingLevel = "medium";
      enableSkillCommands = true;
      subagents = {
        projectRootResolution = "git-root";
        defaultThinking = "medium";
        agentOverrides = lib.genAttrs [
          "explorer"
          "developer"
          "tester"
          "reviewer"
          "researcher"
          "architect"
          "designer"
          "coordinator"
        ] (name: {
          thinking = if name == "explorer" then "low" else "medium";
          inheritProjectContext = true;
          inheritSkills = true;
          defaultContext = if builtins.elem name [ "architect" "coordinator" ] then "fork" else "fresh";
        });
      };
      packages = [
        "npm:@earendil-works/pi-coding-agent@1.5.0"
        "npm:@earendil-works/pi-client@1.1.0"
        "npm:@earendil-works/pi-server@1.1.0"
        "npm:pi-subagents@0.84.0"
        "npm:pi-web-access@0.46.0"
        "npm:pi-mcp-adapter@7.0.0"
        "npm:@narumitw/pi-lsp@0.49.11"
        "npm:@narumitw/pi-plan-mode@0.59.5"
        "npm:@piex-dev/xai-oauth"
        "npm:pi-antigravity"
      ];
    };
  };
  myHome.agents.enable = true;

  home.sessionVariables = {
    BROWSER = "brave";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "application/xhtml+xml" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
    };
  };

  home.file.".gitignore_global".text = ''
  '';
}
