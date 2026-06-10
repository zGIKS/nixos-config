{
  description = "giks NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, home-manager, nit, pomodog, ... }:
    let
      system = "x86_64-linux";
      username = "giks";

      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      platformLib = import ./lib { inherit (nixpkgs) lib; };
      overlays = import ./modules/packages/overlays { inherit pkgsUnstable; };

      mkHost = hostName: { roles, keyboardLayout }:
        let
          specialArgs = {
            inherit username hostName platformLib nit pomodog roles keyboardLayout sops-nix;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./hosts/${hostName}
            { nixpkgs.overlays = [ overlays.default ]; }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./home/giks;
            }
          ];
        };
    in {
      nixosConfigurations = {
        gaia = mkHost "gaia" {
          roles = [ "desktop" "dev" ];
          keyboardLayout = "latam";
        };
        aurora = mkHost "aurora" {
          roles = [ "desktop" "dev" ];
          keyboardLayout = "us";
        };
      };
    };
}
