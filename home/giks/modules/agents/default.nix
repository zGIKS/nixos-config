# Agent prompts and skills shared by the coding CLIs.
#
# Prompts, skill files, and the per-tool projections come from the airi
# configuration (https://github.com/09641061/airi), now maintained here.
# Two skills carry their own upstream terms inside their frontmatter:
# software-design/frontend-design and software-design/vercel-composition-patterns.
{ config, lib, ... }:

let
  cfg = config.myHome.agents;

  agentNames = [
    "architect"
    "coordinator"
    "designer"
    "developer"
    "explorer"
    "researcher"
    "reviewer"
    "tester"
  ];

  claudeModels = {
    architect = "sonnet";
    coordinator = "sonnet";
    designer = "sonnet";
    developer = "sonnet";
    explorer = "haiku";
    researcher = "sonnet";
    reviewer = "sonnet";
    tester = "sonnet";
  };

  # Shared prompts use a generic tool vocabulary. Claude Code only understands
  # its own capitalized built-in names, and it refuses an agent whose tool list
  # names tools it does not have, so unknown tokens are dropped.
  claudeToolNames = {
    read = "Read";
    bash = "Bash";
    edit = "Edit";
    write = "Write";
  };

  findSkills =
    prefix: dir:
    lib.concatLists (
      lib.mapAttrsToList (
        name: type:
        let
          path = if prefix == "" then name else "${prefix}/${name}";
        in
        if type != "directory" then
          [ ]
        else if builtins.pathExists (dir + "/${name}/SKILL.md") then
          [ path ]
        else
          findSkills path (dir + "/${name}")
      ) (builtins.readDir dir)
    );

  skills = findSkills "" ../../skills;

  flatSkillNames = map (path: lib.last (lib.splitString "/" path)) skills;
  duplicateSkillNames = lib.subtractLists (lib.unique flatSkillNames) flatSkillNames;

  skillFiles =
    target: flatten:
    lib.listToAttrs (
      map (
        path:
        let
          flatName = lib.last (lib.splitString "/" path);
        in
        {
          name = if flatten then "${target}/${flatName}" else "${target}/${path}";
          value.source = ../../skills/${path};
        }
      ) skills
    );

  sharedAgentFiles = targets:
    lib.listToAttrs (
      lib.concatMap (
        target:
        map (agent: {
          name = "${target}/${agent}.md";
          value.source = ../../agents/${agent}.md;
        }) agentNames
      ) targets
    );

  closingFrontmatter = lines:
    if lines == [ ] then
      null
    else if builtins.head lines == "---" then
      0
    else
      let
        next = closingFrontmatter (builtins.tail lines);
      in
      if next == null then null else next + 1;

  splitAgent = agent:
    let
      lines = lib.splitString "\n" (builtins.readFile (../../agents/${agent}.md));
      closingIndex =
        if lines != [ ] && builtins.head lines == "---" then
          closingFrontmatter (builtins.tail lines)
        else
          null;
      frontmatter = if closingIndex == null then [ ] else lib.sublist 1 closingIndex lines;
      body = if closingIndex == null then lines else lib.drop (closingIndex + 2) lines;
      descriptionLine = lib.findFirst (line: lib.hasPrefix "description:" line) null frontmatter;
      toolsLine = lib.findFirst (line: lib.hasPrefix "tools:" line) null frontmatter;
    in
    {
      description = lib.removePrefix "description:" descriptionLine;
      tools = if toolsLine == null then null else lib.removePrefix "tools:" toolsLine;
      body = lib.concatStringsSep "\n" body;
    };

  claudeAgentFile = agent:
    let
      parsed = splitAgent agent;
      tokens = map lib.trim (
        lib.splitString "," (
          lib.removePrefix "\"" (lib.removeSuffix "\"" (lib.trim parsed.tools))
        )
      );
      translated = builtins.filter (tool: tool != null) (
        map (tool: claudeToolNames.${tool} or null) tokens
      );
      toolsLine = lib.optionalString (translated != [ ]) "tools: ${lib.concatStringsSep "," translated}\n";
    in
    {
      name = ".claude/agents/${agent}.md";
      value.text = ''
        ---
        name: ${agent}
        description:${parsed.description}
        ${toolsLine}model: ${claudeModels.${agent}}
        ---
        ${parsed.body}
      '';
    };

  codexAgentFile = agent:
    let
      parsed = splitAgent agent;
    in
    {
      name = ".codex/agents/${agent}.toml";
      value.text = ''
        name = "${agent}"
        description = "Shared ${agent} agent"
        developer_instructions = """
        ${parsed.body}
        """
      '';
    };
in
{
  options.myHome.agents.enable = lib.mkEnableOption "shared coding-agent prompts and skills";

  config = lib.mkIf cfg.enable (
    assert lib.assertMsg (duplicateSkillNames == [ ])
      "agent skills: flattened skill directories would collide: ${toString duplicateSkillNames}";
    {
      home.file =
        (sharedAgentFiles [
          ".pi/agent/agents"
          ".agents/agents"
        ])
        // (skillFiles ".claude/skills" true)
        // (skillFiles ".gemini/config/skills" true)
        // (skillFiles ".agents/skills" false)
        // (skillFiles ".pi/agent/skills" false)
        // lib.listToAttrs (map claudeAgentFile agentNames)
        // lib.listToAttrs (map codexAgentFile agentNames)
        // {
          ".gemini/antigravity-cli/settings.json" = {
            force = true;
            text = builtins.toJSON {
              toolPermission = "always-proceed";
              artifactReviewPolicy = "always-proceed";
              allowNonWorkspaceAccess = true;
              permissions.allow = [
                "read_file(/home/giks/.config)"
              ];
            };
          };
        };

      # Codex writes trust decisions into config.toml, so it must stay a
      # writable regular file rather than a store symlink.
      home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        config="$HOME/.codex/config.toml"
        if [ -L "$config" ] || [ ! -e "$config" ]; then
          rm -f "$config"
          mkdir -p "$HOME/.codex"
          cat > "$config" <<'EOF'
        [features]
        code_mode_host = true
        EOF
          chmod 600 "$config"
        elif grep -q '^code_mode_host[[:space:]]*=' "$config"; then
          sed -i 's/^code_mode_host[[:space:]]*=.*/code_mode_host = true/' "$config"
          chmod 600 "$config"
        else
          if ! grep -q '^\[features\]' "$config"; then
            printf '\n[features]\ncode_mode_host = true\n' >> "$config"
          else
            sed -i '/^\[features\]/a code_mode_host = true' "$config"
          fi
          chmod 600 "$config"
        fi
      '';
    }
  );
}
