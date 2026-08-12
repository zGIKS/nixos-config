{
  description = "giks NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    antigravityNix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codexDesktopLinux.url = "github:ilysenko/codex-desktop-linux";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nit, pomodog, antigravityNix, codexDesktopLinux, ... }:
    let
      system = "x86_64-linux";
      username = "giks";

      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      platformLib = import ./lib { inherit (nixpkgs) lib; };
      mkHost = hostName: { roles, keyboardLayout }:
        let
          hostOverlays = if hostName == "aurora" then
            (import ./modules/hosts/aurora/applications/overlays {
              inherit pkgsUnstable;
            })
          else {
            default = final: prev: { };
          };
          sharedOverlays = import ./modules/hosts/shared/applications/overlays {
            inherit pkgsUnstable;
          };
          specialArgs = {
            inherit username hostName platformLib nit pomodog antigravityNix codexDesktopLinux roles keyboardLayout;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./hosts/${hostName}
            { nixpkgs.overlays = [ sharedOverlays.default hostOverlays.default ]; }
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
