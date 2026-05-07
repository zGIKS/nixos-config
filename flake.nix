{
  description = "giks NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nit = {
      url = "github:zGIKS/nit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pomodog = {
      url = "github:zGIKS/pomodog";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, nit, pomodog, ... }:
    let
      system = "x86_64-linux";
      username = "giks";
      hosts = import ./hosts;
      homeLib = import ./modules/home/lib.nix { };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      hostConfigs = {
        gramnyx = {
          roles = [ "desktop" "dev" ];
          keyboardLayout = "latam";
        };
        mai = {
          roles = [ "desktop" "dev" ];
          keyboardLayout = "us";
        };
      };
    in {
      nixosConfigurations = nixpkgs.lib.mapAttrs
        (hostName: hostConfig:
          let
            specialArgs = {
              inherit username hostName homeLib;
              inherit nit pomodog;
              inherit (hostConfig) roles keyboardLayout;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system specialArgs;
            modules = [
              hosts.${hostName}
              {
                nixpkgs.overlays = [
                  (final: prev: {
                    vscode = pkgsUnstable.vscode;
                    vscode-fhs = pkgsUnstable.vscode-fhs;
                    zed-editor = pkgsUnstable.zed-editor;
                  })
                ];
              }
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "backup";
                home-manager.extraSpecialArgs = specialArgs;
                home-manager.users.${username} = import ./users/${username}/home.nix;
              }
            ];
          })
        hostConfigs;
    };
}
