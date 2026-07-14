{ username, ... }:

{
  home-manager.users.${username}.myHome.apps.devGui.enable = true;
}
