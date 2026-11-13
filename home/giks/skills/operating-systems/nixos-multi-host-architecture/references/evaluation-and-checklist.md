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
- Complete evaluation of all flake outputs (packages, configurations, checks, formatters);
- Execution of all tests declared in `checks.<system>`;
- Validation of flake structure and schema.

Fast dry-run evaluations for specific machines:
```bash
# Dry-run evaluation of a host's top-level system derivation
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run

# Or using nixos-rebuild
nixos-rebuild build --flake .#<host> --dry-run
```

### 2. Multi-Machine NixOS VM Integration Tests (`pkgs.testers.runNixOSTest`)
NixOS provides first-class, declarative VM testing using `pkgs.testers.runNixOSTest` (or `nixosTest`).
It spins up isolated micro-VMs in QEMU running the actual NixOS system configurations and tests network communication, services, and systemd units using an interactive Python test script.

Add tests to flake `checks.<system>`:

```nix
# tests/service-integration.nix
{ pkgs }:

pkgs.testers.runNixOSTest {
  name = "api-and-db-integration-test";

  nodes = {
    # Node 1: Database Server
    database = { config, pkgs, ... }: {
      services.postgresql = {
        enable = true;
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

Run VM tests locally or in CI:
```bash
nix flake check
# Or run an individual test directly:
nix build .#checks.x86_64-linux.api-and-db-integration-test
```

### 3. Flake Formatter (`formatter.<system>`)
Standardize repository formatting via the native flake `formatter` output:
```nix
formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
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
- [ ] `system.stateVersion` is set to the initial install version and is **never** bumped on updates.
- [ ] Repository exposes official `formatter.<system>` output (`nixfmt-rfc-style`).
- [ ] `nix.settings.experimental-features = [ "nix-command" "flakes" ];` is enabled.

### Module Contracts & Dependency Injection
- [ ] Module arguments are injected via `_module.args` inside modules instead of polluting flake `specialArgs`.
- [ ] Flake `specialArgs` is reserved exclusively for values needed before module evaluation (such as passing `inputs`).
- [ ] Capabilities are controlled via namespaced module options (`lib.mkOption`, `lib.mkEnableOption`, `lib.mkPackageOption`).
- [ ] Option types use strict types (`types.str`, `types.bool`, `types.listOf`, `types.submodule`, `types.enum`).
- [ ] Invariants and mutual exclusivity rules are enforced via `assertions` and `warnings`.

### Services & Systemd Architecture
- [ ] Systemd dependency (`wants`, `requires`) and startup ordering (`after`, `before`) are strictly distinguished.
- [ ] Startup ordering is defined explicitly with `after` / `before` (not relying on `requires`/`wants` to order boot).
- [ ] Target hooks use `wantedBy = [ "multi-user.target" ];` ([Install] section).
- [ ] Daemons apply security hardening baselines (`DynamicUser = true`, `ProtectSystem = "strict"`, `ProtectHome = true`, `PrivateTmp = true`, `NoNewPrivileges = true`, `CapabilityBoundingSet = ""`).

### Overlays & Packaging
- [ ] Overlays are pure functions `(final: prev: { ... })`.
- [ ] Overlays avoid global overrides of foundational packages to prevent massive rebuild cascades.
- [ ] Packages are declared in NixOS modules, never in Home Manager (`home.packages` is absent).
- [ ] Home Manager contains user configuration and dotfiles only.

### Quality Gates & Automated Testing
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
