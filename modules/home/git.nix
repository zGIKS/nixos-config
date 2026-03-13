{ config, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  programs.git = {
    enable = true;

    signing = {
      key = "${homeDir}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    settings = {
      user.name = "zGIKS";
      user.email = "mateo@giks.net";
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nano";
      core.excludesfile = "${homeDir}/.gitignore_global";
      commit.gpgsign = true;
      gpg.format = "ssh";
      credential."https://dev.azure.com".useHttpPath = true;
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
  };
}
