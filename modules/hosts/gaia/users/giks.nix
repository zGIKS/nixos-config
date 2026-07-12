{ username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Matteo Aleman";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
