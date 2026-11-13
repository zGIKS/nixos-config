# Evaluation/Runtime, Flake Tooling, Implementation Order, and Validation Checklist

## 15. Evaluation and runtime

Nix evaluates and merges modules at build time before constructing the operating system derivations.
Module imports describe composition, option exposure, and visibility; **imports do not define runtime or boot order**.

### Systemd: Dependency vs Ordering (Factual Separation)

Runtime orchestration is managed entirely by systemd. It is critical never to confuse dependency activation with execution order:

1. **Dependency & Activation Only (`wants`, `requires`, `bindsTo`, `partOf`)**:
   - Express *what* units must be activated.
   - **Units connected by `wants` or `requires` start in parallel by default.**
   - They do **not** define boot or startup sequence.
2. **Startup Ordering Exclusively (`after`, `before`)**:
   - Startup order is defined **EXCLUSIVELY** by `after` and `before`.
   - If unit `A` requires unit `B` to be operational before `A` starts, `A` must declare `after = [ "B.service" ];`.
3. **Target Attachment (`wantedBy`, `requiredBy`)**:
   - Belongs to the systemd `[Install]` section.
   - Attaches a service to boot targets (e.g. `wantedBy = [ "multi-user.target" ];`).
   - Does **not** sequence execution within that target.

Keep evaluation-time module composition strictly separated from runtime orchestration.

---

## 16. Official Flake Tooling, Validation, and VM Testing

A scalable multi-host architecture relies on automated validation gates and native tooling to guarantee correctness before deployment.

### 1. Canonical Flake Validation: `nix flake check`
`nix flake check` is the canonical CI and pre-commit validation command. It performs:
- Schema validation and structural sanity checks of all flake outputs;
- Complete build execution of all test derivations declared in `checks.<system>.*`;
- Type-checking and evaluation of `packages`, `apps`, `devShells`, and `nixosConfigurations`.
*(Note: `nix flake check` checks derivations and flake structure; it does not execute `formatter.<system>`, which is run separately via `nix fmt`.)*

Evaluation and verification commands for specific hosts:
```bash
# Dry-build: evaluates the configuration and displays what would be built or fetched without building
nixos-rebuild dry-build --flake .#<host>

# Dry-run: evaluates configuration and shows systemd units that would be activated or restarted
nixos-rebuild dry-run --flake .#<host>

# Test in-memory: builds and activates the configuration immediately without updating bootloader or generation history
sudo nixos-rebuild test --flake .#<host>

# Build a runnable QEMU virtual machine for the host
nixos-rebuild build-vm --flake .#<host>
./result/bin/run-<host>-vm
```

### 2. Multi-Machine NixOS VM Integration Tests (`pkgs.testers.runNixOSTest`)
NixOS provides first-class, declarative VM testing using `pkgs.testers.runNixOSTest` (or `nixosTest`).
It spins up isolated micro-VMs in QEMU running the actual NixOS system configurations and tests network communication, services, and systemd units using an interactive Python test script.

#### Test Definition: `tests/service-integration.nix`

```nix
{ pkgs }:

pkgs.testers.runNixOSTest {
  name = "api-and-db-integration-test";

  nodes = {
    # Node 1: Database Server
    database = { config, pkgs, ... }: {
      services.postgresql = {
        enable = true;
        # Crucial: enableTCPIP is false by default in NixOS (Unix domain socket only)
        enableTCPIP = true;
        authentication = pkgs.lib.mkOverride 10 ''
          local all all trust
          host all all 192.168.1.0/24 trust
          host all all 127.0.0.1/32 trust
          host all all ::1/128 trust
        '';
        initialScript = pkgs.writeText "init.sql" ''
          CREATE DATABASE app;
        '';
      };
      networking.firewall.allowedTCPPorts = [ 5432 ];
    };

    # Node 2: API Client Application
    client = { config, pkgs, ... }: {
      environment.systemPackages = [ pkgs.curl pkgs.postgresql ];
    };
  };

  # Python test script executed against running QEMU machines
  testScript = ''
    start_all()

    # Wait for database systemd unit to reach active state
    database.wait_for_unit("postgresql.service")
    database.wait_for_open_port(5432)

    # Verify cross-node network reachability and query execution
    client.wait_for_unit("multi-user.target")
    client.succeed("pg_isready -h database -p 5432")
  '';
}
```

#### Cable Test into `flake.nix` `checks` Output

```nix
# flake.nix
outputs = { self, nixpkgs, ... }@inputs:
let
  supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
  forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
in
{
  # Wire tests into flake checks so `nix flake check` runs them automatically
  checks = forAllSystems (system: {
    db-integration = import ./tests/service-integration.nix {
      pkgs = nixpkgs.legacyPackages.${system};
    };
  });
};
```

Run VM tests locally or in CI:
```bash
# Runs all checks across the repository
nix flake check

# Or build/run an individual test directly:
nix build .#checks.x86_64-linux.db-integration
```

### 3. Flake Formatter (`formatter.<system>`)
Standardize repository formatting via the native flake `formatter` output using `pkgs.nixfmt` (the official RFC 166 formatter package; note that `nixfmt-rfc-style` is an obsolete alias):
```nix
formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
```
Enables running `nix fmt` across all Nix files in the repository without external wrappers.

### 4. Compile-Time Invariants: `assertions` and `warnings`
Enforce configuration constraints during Nix evaluation:
```nix
config = {
  assertions = [
    {
      assertion = config.services.nginx.enable -> (config.networking.firewall.allowedTCPPorts != []);
      message = "When Nginx is enabled, HTTP/HTTPS firewall ports must be explicitly declared.";
    }
  ];

  warnings = lib.optional (!config.security.sudo.execWheelOnly)
    "security.sudo.execWheelOnly is disabled on ${config.networking.hostName}. Consider enabling it for production hosts.";
};
```

---

## 17. Recommended Implementation Order

1. **Composition Root**: Define `flake.nix` with inputs deduplicated via `follows = "nixpkgs"`, outputs, and `formatter`.
2. **Host Composition**: Create `hosts/<host>/default.nix`, declare `nixpkgs.hostPlatform`, immutable `system.stateVersion`, and machine identity.
3. **Machine Facts**: Record hardware facts (`hardware-configuration.nix`) and filesystem layout (`disk.nix`).
4. **Boot and Kernel**: Configure EFI/GRUB bootloaders and kernel parameters.
5. **Networking Layer**: Establish host firewall rules, interfaces, and DNS.
6. **Reusable Modules & Options**: Write domain modules with `lib.mkOption`, typed options, and `_module.args` for injected context.
7. **Services Layer**: Define services with explicit systemd ordering (`after`/`before`), target attachment (`wantedBy`), and hardening baselines (`DynamicUser`, `ProtectSystem="strict"`).
8. **Applications & Profiles**: Define small role-based package profiles and pure, rebuild-safe overlays.
9. **Environment & Session**: Add desktop integration, fonts, and system locale.
10. **Home Manager Boundary**: Add user dotfiles configuration only; ensure zero package installations in Home Manager.
11. **Evaluation & Verification**: Verify configuration invariants with `assertions`, format code with `nix fmt`, validate flake with `nix flake check`, and test services with `runNixOSTest`.

---

## 18. Validation Checklist

### Flake & Host Composition
- [ ] The flake is the composition root and pins inputs cleanly.
- [ ] Flake inputs deduplicate nixpkgs via `inputs.<name>.inputs.nixpkgs.follows = "nixpkgs"`.
- [ ] Each host declares `nixpkgs.hostPlatform` inside its configuration rather than using the legacy `system` parameter in `nixosSystem`.
- [ ] `system.stateVersion` is tied to initial provisioning and is not bumped casually on routine updates.
- [ ] Repository exposes official `formatter.<system>` output (`pkgs.nixfmt`).
- [ ] `nix.settings.experimental-features = [ "nix-command" "flakes" ];` is enabled.

### Module Contracts & Dependency Injection
- [ ] Module arguments are injected via `_module.args` inside modules instead of polluting flake `specialArgs`.
- [ ] Flake `specialArgs` is reserved exclusively for values needed before module evaluation (such as passing `inputs`).
- [ ] Shared configuration uses typed options (`lib.mkOption`, `lib.mkEnableOption`, `lib.mkPackageOption`).
- [ ] Structured daemon configurations use RFC 42 `settings` with `freeformType` where appropriate.
- [ ] Invariants and mutual exclusivity rules are enforced via `assertions` and `warnings`.

### Services & Systemd Architecture
- [ ] Systemd dependency (`wants`, `requires`) and startup ordering (`after`, `before`) are strictly distinguished.
- [ ] Startup ordering is defined explicitly with `after` / `before` (not relying on `requires`/`wants` to order boot).
- [ ] Target hooks use `wantedBy = [ "multi-user.target" ];` ([Install] section).
- [ ] Daemons apply security hardening baselines (`DynamicUser = true`, `ProtectSystem = "strict"`, `ProtectHome = true`, `PrivateTmp = true`, `NoNewPrivileges = true`, `CapabilityBoundingSet = ""`).
- [ ] Capabilities prefer `services.<x>.enable` or `programs.<x>.enable` over raw `environment.systemPackages`.

### Secrets & Security
- [ ] Secrets are never stored in plaintext or in `/nix/store` (since the store is world-readable).
- [ ] Runtime credentials are referenced exclusively via `*File` options (`EnvironmentFile`, `passwordFile`, `initialScriptFile`) from secure runtime locations (`/run/secrets/`).

### Overlays & Packaging
- [ ] Overlays are pure functions `(final: prev: { ... })`.
- [ ] Overlays avoid global overrides of foundational packages to prevent massive rebuild cascades.
- [ ] Package overrides use targeted `pkg.override` / `overrideAttrs` when only one consumer needs them.
- [ ] Packages are declared in NixOS modules, never in Home Manager (`home.packages` is absent).
- [ ] Imperative package managers (`nix-env -i`, `nix profile install`) are forbidden.

### Quality Gates, Antipatterns & Automated Testing
- [ ] Code avoids the 8 official `nix.dev` antipatterns (no wide `with pkgs;`, no ambient `<nixpkgs>`, no `rec`, no IFD, filtered `src`, no shallow `//`).
- [ ] `nix flake check` passes cleanly without errors.
- [ ] Multi-node service workflows are validated with `pkgs.testers.runNixOSTest` micro-VM integration tests.

---

## Final Architecture

```text
Flake (flake.nix)
├── Formatter (formatter.<system>)
├── Overlays (overlays.default - pure & scoped)
├── VM Integration Tests (checks.<system>.runNixOSTest)
└── Host Composition (hosts/<host-name>/)
    ├── nixpkgs.hostPlatform & system.stateVersion
    ├── Machine Facts (hardware-configuration.nix & disk.nix)
    ├── Dependency Injection (_module.args)
    ├── Shared Modules (modules/hosts/shared/)
    │   ├── hardware
    │   ├── boot
    │   ├── filesystem
    │   ├── networking
    │   ├── services (hardened, explicit after/before ordering)
    │   ├── applications (profiles, safe overlays)
    │   └── environment
    ├── Host-Specific Modules (modules/hosts/<host-name>/)
    └── Home Manager (user configuration only; zero packages)
```
