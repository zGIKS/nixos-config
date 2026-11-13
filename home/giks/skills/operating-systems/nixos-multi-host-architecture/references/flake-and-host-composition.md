# Flake and Host Composition

## 1. Flake and composition root

Location: repository root, normally `flake.nix`.

The flake defines system inputs, reusable functions, overlays, modules, and
deployable configurations. It is responsible for top-level composition, not
for holding machine-specific configuration details.

### Native Flake Standards

1. **Input deduplication (`follows`)**:
   Flake inputs that consume `nixpkgs` (such as Home Manager, hardware modules,
   or system tools) can pin their `nixpkgs` reference to the root flake's
   input via `inputs.<name>.inputs.nixpkgs.follows = "nixpkgs"`.
   - **Purpose**: Consolidates entries in `flake.lock` and ensures that shared
     tools and NixOS modules resolve against the same locked Nixpkgs tree as the host.
   - **Nix Manual Context**: The Nix Manual notes that overriding every transitive
     input is not always necessary if the dependency's packages are self-contained or
     not evaluated by the host. Apply `follows` deliberately where lockfile deduplication
     and package set consistency across modules are required.

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
   the entire repository using `pkgs.nixfmt` (the standard RFC 166 package; `nixfmt-rfc-style` is an obsolete alias):
   ```nix
   formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
   ```

5. **Flakes as Experimental Features vs Traditional Channels**:
   Flakes and the `nix` CLI are currently marked as **experimental features** in upstream Nix.
   Traditional NixOS uses channels (`nix-channel`) and `<nixpkgs>` via `NIX_PATH`.
   Flake-based systems must explicitly enable experimental features in configuration:
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

6. **Aligning `nix.registry` and `nix.nixPath` with the Flake**:
   In flake-managed systems, legacy tools (`nix-shell`, `nix-build`, `<nixpkgs>`) still query `NIX_PATH`.
   To guarantee that all system tools use the exact same Nixpkgs revision as the flake:
   ```nix
   # Pin the system flake registry to match the flake input
   nix.registry.nixpkgs.flake = inputs.nixpkgs;

   # Map NIX_PATH / <nixpkgs> directly to the locked flake input in /etc
   environment.etc."nix/inputs/nixpkgs".source = "${inputs.nixpkgs}";
   nix.nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
   ```

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
      # Official formatter for `nix fmt` (using official pkgs.nixfmt package)
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixfmt
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

  # State version: tied to initial provisioning
  system.stateVersion = "24.11";
}
```

### Worked Example: Adding a New Host (`workstation-02`)

1. **Record Machine Facts**:
   On the target physical or virtual machine, generate hardware facts:
   ```bash
   nixos-generate-config --dir /tmp/facts
   ```
   Copy `/tmp/facts/hardware-configuration.nix` to `hosts/workstation-02/hardware-configuration.nix`.
2. **Create Host Composition (`hosts/workstation-02/default.nix`)**:
   ```nix
   { config, lib, pkgs, inputs, ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ../../modules/hosts/shared/boot/efi.nix
       ../../modules/hosts/shared/applications/profiles/desktop.nix
     ];

     nixpkgs.hostPlatform = "x86_64-linux";
     networking.hostName = "workstation-02";
     system.stateVersion = "24.11";
   }
   ```
3. **Register in `flake.nix`**:
   ```nix
   nixosConfigurations.workstation-02 = nixpkgs.lib.nixosSystem {
     specialArgs = { inherit inputs; };
     modules = [ ./hosts/workstation-02 ];
   };
   ```
4. **Validate and Deploy**:
   ```bash
   nix flake check
   nixos-rebuild dry-build --flake .#workstation-02
   ```

---

## 3. The `system.stateVersion` Rule

`system.stateVersion` records the NixOS release version when the machine state was first initialized (e.g. `"24.11"`).

### Why it exists
NixOS services frequently manage stateful data (PostgreSQL database schemas, OpenSSH host key algorithms, user group IDs, state directory layouts).
When a new NixOS release introduces a change to default state locations or formats, checking `system.stateVersion` ensures that existing systems preserve backwards-compatible defaults, preventing breaking changes or data corruption.

### Official NixOS Guidance
> **Do not bump `system.stateVersion` casually during routine system updates or flake upgrades.**

- Updating `system.stateVersion` does **NOT** update packages, libraries, or the Linux kernel. Software updates are achieved entirely by updating flake inputs (`nix flake update`) and rebuilding.
- The official NixOS manual states that `stateVersion` should remain pinned to the release where the machine was first provisioned.
- While it is possible to change it, doing so requires manually reading release notes for every intermediate release, backing up data, and executing necessary data migrations. In multi-host infrastructure, keep it tied to the provisioning version.

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

### Mixing Stable and Unstable Nixpkgs (Pattern 11.5)

In multi-host flakes, hosts may need recent packages from `nixpkgs-unstable` alongside a stable channel base:

```nix
# Exposing unstable packages via _module.args without global overlay pollution
{ inputs, pkgs, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  _module.args.pkgs-unstable = pkgs-unstable;
}
```

- **Architectural Risks**:
  - **Duplicate Closures**: Pulling large desktop apps or services from both stable and unstable causes duplicate glibc, LLVM, or Python runtimes in the Nix store.
  - **ABI Incompatibilities**: Never mix system daemons (like display managers, PipeWire, or systemd services) between stable and unstable. Confine unstable packages strictly to standalone terminal utilities or leaf applications (e.g. `neovim`, `vscode`).

### Permitting Unfree Software Declaratively (Pattern 11.6)

Configure `nixpkgs.config.allowUnfree` explicitly in host modules:
```nix
nixpkgs.config.allowUnfree = true;

# Or using a targeted predicate for finer auditing:
nixpkgs.config.allowUnfreePredicate = pkg:
  builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "nvidia-x11"
  ];
```
