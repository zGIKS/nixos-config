{
  description = "giks NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      username = "giks";
      hostName = "gramnyx";
      roles = [ "desktop" "dev" ];
      hosts = import ./hosts;
      homeLib = import ./modules/home/lib.nix { };
      specialArgs = {
        inherit username hostName roles homeLib;
      };
    in {
      nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          hosts.${hostName}
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username} = import ./users/${username}/home.nix;
          }
        ];
      };
    };
}
