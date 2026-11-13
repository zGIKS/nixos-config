# Flake and Host Composition

## 1. Flake and composition root

Location: repository root, normally `flake.nix`.

The flake defines system inputs, reusable functions, overlays, modules, and
deployable configurations. It is responsible for top-level composition, not
for holding machine-specific configuration details.

### Native Flake Standards

1. **Input deduplication (`follows`)**:
   Flake inputs that depend on `nixpkgs` (such as Home Manager, hardware modules,
   or third-party tools) should pin their `nixpkgs` reference to the root flake's
   nixpkgs input via `inputs.<name>.inputs.nixpkgs.follows = "nixpkgs"`.
   Without this, each input pulls its own pinned nixpkgs commit, resulting in:
   - multiple distinct evaluations of nixpkgs;
   - bloated `flake.lock` files;
   - duplicated store paths and duplicate libraries in the Nix store;
   - significantly higher evaluation time and memory consumption during builds.

2. **Modern `hostPlatform` over legacy `system`**:
   Do **not** pass the legacy `system` argument to `nixpkgs.lib.nixosSystem { system = "..."; }`.
   Instead, declare `nixpkgs.hostPlatform = "x86_64-linux";` (or the appropriate architecture)
   inside the host configuration module or hardware composition.
   This aligns with modern NixOS conventions, unifies cross-compilation support, and
   allows pkgs to configure itself cleanly inside the module evaluation.

3. **Minimal `specialArgs` vs `_module.args`**:
   Keep `specialArgs` in `nixosSystem` minimal. Only use `specialArgs` for parameters
   strictly needed *before* module evaluation begins (such as passing flake `inputs`
   or parameters determining conditional module `imports`). For all internal module
   arguments, helpers, and domain context, inject them via `_module.args` inside modules.
   - Why: `_module.args` is evaluated inside the module system, participates in priority
     (`mkDefault`, `mkForce`), can be overridden by individual modules/hosts, and prevents
     polluting `flake.nix`.

4. **Flake Formatter (`formatter.<system>`)**:
   Expose an official formatter output so that `nix fmt` works out of the box across
   the entire repository (e.g. `nixfmt-rfc-style`).

5. **Experimental Features**:
   Ensure `nix.settings.experimental-features = [ "nix-command" "flakes" ];` is enabled
   in shared system configuration to guarantee consistent CLI behavior across all hosts.

### Canonical `flake.nix` Example

```nix
{
  description = "Production multi-host NixOS infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # Official formatter for `nix fmt`
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );

      # Reusable flake overlays (exported for downstream consumers or integration)
      overlays = {
        default = import ./modules/overlays;
        customPackages = final: prev: {
          myApp = final.callPackage ./pkgs/my-app { };
        };
      };

      # NixOS Host Configurations
      nixosConfigurations = {
        srv-core-01 = nixpkgs.lib.nixosSystem {
          # Minimal specialArgs: only pass flake inputs needed for module imports
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/srv-core-01
          ];
        };

        workstation-01 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/workstation-01
          ];
        };
      };
    };
}
```

---

## 2. Host composition layer

Location: `hosts/<host-name>/`.

The host directory is the composition boundary for one physical or logical machine.
Its entry module (`default.nix`) imports the capabilities, profiles, and machine facts
required by that host.

### Structure of a Host Directory

```text
hosts/<host-name>/
├── default.nix                 # Composition root for this host
├── hardware-configuration.nix # Discovered hardware facts
├── disk.nix                    # Filesystem layout / Disko specification
└── secrets/                    # Host-scoped secret references (e.g. agenix/sops)
```

### Host Composition Responsibilities

- **Platform Architecture**: Declares `nixpkgs.hostPlatform = "x86_64-linux";`.
- **State Version**: Declares `system.stateVersion = "24.11";` (see stateVersion rules below).
- **Machine Identity**: Declares `networking.hostName` and host identity facts.
- **Hardware & Storage**: Imports `hardware-configuration.nix` and `disk.nix`.
- **Capability Selection**: Enables shared service and profile options (e.g. `platform.services.sshd.enable = true;`).
- **Dependency Injection**: Injects host-scoped helpers or context via `_module.args`.

### Example `hosts/srv-core-01/default.nix`

```nix
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Machine facts
    ./hardware-configuration.nix
    ./disk.nix

    # Shared system domains
    ../../modules/hosts/shared/boot/efi.nix
    ../../modules/hosts/shared/system/networking/base.nix
    ../../modules/hosts/shared/system/services/sshd.nix
    ../../modules/hosts/shared/applications/profiles/server.nix
  ];

  # Modern hostPlatform declaration inside configuration
  nixpkgs.hostPlatform = "x86_64-linux";

  # Nix daemon configuration
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Machine identity
  networking.hostName = "srv-core-01";

  # Capability enablement via namespaced options
  platform.services.sshd = {
    enable = true;
    port = 2222;
  };

  # Host-level dependency injection via _module.args
  _module.args.hostMetadata = {
    datacenter = "eu-west-1";
    role = "database-replica";
  };

  # State version: immutable record of initial installation
  system.stateVersion = "24.11";
}
```

---

## 3. The `system.stateVersion` Rule

`system.stateVersion` records the NixOS release version when the machine state was first initialized (e.g. `"24.11"`).

### Why it exists
NixOS services often have stateful components (database file layouts, internal directory formats, configuration file defaults).
If NixOS were to change these defaults automatically during a channel or flake upgrade, existing data could be corrupted or services could fail to start.
`system.stateVersion` instructs NixOS modules to preserve backwards-compatible behaviors for stateful data.

### The Absolute Rule
> **NEVER bump or change `system.stateVersion` during regular system updates or upgrades.**

- Updating `system.stateVersion` does **NOT** update your system packages or kernel; that is done entirely by updating flake inputs (`nix flake update`).
- Changing `system.stateVersion` will silently switch state file locations, database assumptions, or service defaults, frequently causing data corruption or service crashes.
- Leave `system.stateVersion` fixed at the value set when the host was first created.

---

## 4. Overlay Architecture in Multi-Host Flakes

Overlays allow customizing package sets, applying patches, or adding packages.
In a multi-host architecture, overlays must be structured to prevent massive build cascades.

### Placement: Flake Output vs NixOS Module

1. **Flake Output (`overlays.<name>`)**:
   Flake-exported overlays are pure functions `(final: prev: { ... })` made available to consumers
   of the flake or imported into NixOS modules.
2. **NixOS Module Declaration (`nixpkgs.overlays`)**:
   Modules inject overlays into the NixOS package set via:
   ```nix
   nixpkgs.overlays = [
     inputs.self.overlays.default
     (final: prev: {
       myCustomTool = final.callPackage ./pkgs/my-tool { };
     })
   ];
   ```

### Scoped, Pure Overlays vs Rebuild Cascades

- **Pure & Scoped**: Overlays must be deterministic functions of `final` (the completed package set) and `prev` (the previous package set).
- **Avoid Global Overrides**: Overriding foundational libraries (e.g. `glibc`, `openssl`, `python3`, `systemd`) at the top of the package tree forces Nix to rebuild every dependent package locally from source across all hosts, bypassing Hydra/binary caches.
- **Rule**: Prefer package additions (`final.myPackage = ...`) or targeted localized overrides (e.g. `final.myApp = prev.myApp.override { ... };`) rather than modifying packages that sit at the root of large dependency trees.
