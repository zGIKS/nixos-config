{ lib, ... }:

let
  agents = [ "architect" "developer" "explorer" "researcher" "reviewer" "tester" ];

  agentFile = agent: {
    name = ".codex/agents/${agent}.toml";
    value.text = ''
      name = "${agent}"
      description = "Shared ${agent} agent"
      developer_instructions = '''
      ${builtins.readFile ../shared/agents/${agent}.md}
      '''
    '';
  };
in
{
  # Codex requires TOML agents, so these files are generated from the shared
  # Markdown agents instead of maintaining a second copy of their prompts.
  home.file = lib.listToAttrs (map agentFile agents);
}
