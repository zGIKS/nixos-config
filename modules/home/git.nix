{ config, lib, username, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  options.myHome.git = {
    enable = lib.mkEnableOption "git defaults";
    userName = lib.mkOption {
      type = lib.types.str;
      default = username;
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "${username}@localhost";
    };
    signingKey = lib.mkOption {
      type = lib.types.str;
      default = "${homeDir}/.ssh/id_ed25519.pub";
    };
  };

  config = lib.mkIf config.myHome.git.enable {
    programs.git = {
      enable = true;

      signing = {
        key = config.myHome.git.signingKey;
        signByDefault = true;
      };

      settings = {
        user.name = config.myHome.git.userName;
        user.email = config.myHome.git.userEmail;
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
  };
}
