---
name: nixos-multi-host-architecture
description: Design or review a maintainable, scalable, multi-host NixOS configuration using explicit architectural layers — flake composition root, host composition, hardware/boot/filesystem/networking/services/applications/environment domains, shared vs host-specific modules, module options, and the Home Manager boundary. Use whenever asked to structure, scaffold, or review a NixOS flake/repository, add a new host, split a monolithic configuration.nix, or decide where a piece of NixOS configuration belongs.
---

# Layered NixOS Architecture

Independent of a particular repository, host name, desktop environment,
package set, or deployment tool. Separates machine facts, operating-system
capabilities, applications, graphical sessions, and user preferences using
NixOS module composition instead of a single monolithic configuration file.

## Core rules

1. **Flake as Composition Root**:
   Declare `nixpkgs.hostPlatform` inside host modules (never pass the legacy `system` parameter to `nixosSystem`). Deduplicate inputs using `inputs.<name>.inputs.nixpkgs.follows = "nixpkgs"`, provide `formatter.<system>` with `pkgs.nixfmt` for native `nix fmt`, enable `nix-command` and `flakes` experimental features, and align `nix.registry` and `nix.nixPath` with flake inputs.
2. **`system.stateVersion` Tied to Initial Provisioning**:
   Records the state and data schema compatibility version. Do not bump it casually during routine system updates; maintain it pinned to the release where the host was first provisioned unless executing deliberate, documented state migrations.
3. **Machine Facts vs Reusable Modules**:
   Keep machine facts (hardware detection, disk partitions, host identity) isolated in `hosts/<host>/` and strictly separated from reusable operating-system modules.
4. **Dependency Injection — Prefer `_module.args` Over `specialArgs`**:
   Use explicit module options (`lib.mkOption` with `lib.types.*`) for typed configuration data. Use `_module.args` (evaluated as lazy raw attributes) for injecting context and helper libraries inside modules. Keep flake `specialArgs` minimal (strictly reserved for passing `inputs` or determining conditional imports before module evaluation).
5. **Namespaced Module Options & Strict Contracts**:
   Expose capabilities through namespaced options using `lib.mkOption`, `lib.mkEnableOption`, and `lib.mkPackageOption` with strict `lib.types`. Use RFC 42 structured `settings` with `freeformType` for daemon configs. Enforce compile-time invariants using `assertions` and `warnings`. Use `disabledModules` when overriding upstream modules.
6. **Systemd Ordering vs Dependency (Factual Separation)**:
   `wants`, `requires`, `bindsTo`, and `partOf` define dependency and activation only; units start concurrently in parallel. Startup order is defined **EXCLUSIVELY** by `after` and `before`. Target attachment belongs in `wantedBy` ([Install] section).
7. **Hardened Daemons & Declarative Packages**:
   Apply Linux namespace sandboxing by default (`DynamicUser = true`, `ProtectSystem = "strict"`, `ProtectHome = true`, `PrivateTmp = true`, `NoNewPrivileges = true`, `CapabilityBoundingSet = ""`). Prefer `services.<x>.enable` and `programs.<x>.enable` over raw `environment.systemPackages` to inherit PAM, polkit, dbus, and setuid wrappers. Prohibit imperative package managers (`nix-env -i`).
8. **Secrets Never in Plaintext or `/nix/store`**:
   The Nix store is world-readable (`chmod a+r /nix/store`). Never commit secrets or pass secret file paths as Nix path literals. Always use `*File` options (`EnvironmentFile`, `passwordFile`, `initialScriptFile`) pointing to runtime paths (`/run/secrets/`).
9. **Pure, Scoped, and Rebuild-Safe Overlays**:
   Overlays must be pure functions `(final: prev: { ... })`. Avoid global overrides of foundational packages that trigger rebuild cascades across the entire fleet. Prefer targeted `pkg.override` / `overrideAttrs` for local customizations.
10. **Strict Home Manager Boundary**:
    Home Manager is for user configuration and dotfiles only. It must **never** define, install, or download packages (`home.packages` is forbidden). All packages are owned by NixOS.
11. **Avoid Antipatterns & Automate Verification**:
    Strictly avoid the 8 official `nix.dev` antipatterns (no wide `with pkgs;`, no ambient `<nixpkgs>`, no `rec`, no IFD on critical paths, clean sources, no shallow `//`). Validate with `nix flake check`, VM tests (`pkgs.testers.runNixOSTest`), and verify hosts using `nixos-rebuild dry-build`, `test`, or `build-vm`.

## Architectural model

```text
Flake (flake.nix)
│   ├── Formatter (formatter.<system>)
│   ├── Overlays (overlays.<name> - pure & scoped)
│   └── VM Tests (checks.<system>.runNixOSTest)
│
├── Host Composition (hosts/<host-name>/)
│   ├── nixpkgs.hostPlatform & immutable system.stateVersion
│   ├── Machine Facts (hardware-configuration.nix, disk.nix)
│   ├── Injected Arguments (_module.args)
│   ├── Shared System Modules
│   └── Host-Specific Modules
│
├── Operating-System Domains (modules/hosts/shared/)
│   ├── Hardware
│   ├── Boot
│   ├── Filesystem
│   ├── Networking
│   ├── Services (hardened daemons, explicit after/before ordering)
│   ├── Applications (profiles, safe overlays)
│   └── Environment / Session
│
└── User Configuration
    └── Home Manager (user dotfiles and shell config only; no packages)
```

The domains are orthogonal responsibilities. A configuration may contain all
of them, but they are not required to form a linear stack.

## Build order

Follow this order — load each reference only when you reach that step; don't front-load all of them.

| # | Step | Reference |
|---|------|-----------|
| 1 | Flake and host composition (inputs, hostPlatform, stateVersion, follows, formatter) | [references/flake-and-host-composition.md](references/flake-and-host-composition.md) |
| 2 | Hardware and boot/kernel layers | [references/hardware-and-boot.md](references/hardware-and-boot.md) |
| 3 | Filesystem/storage and networking layers | [references/filesystem-and-networking.md](references/filesystem-and-networking.md) |
| 4 | Services (systemd ordering, hardening) and applications/profiles/overlays | [references/services-and-applications.md](references/services-and-applications.md) |
| 5 | Environment and graphical session layer | [references/environment-and-session.md](references/environment-and-session.md) |
| 6 | Shared vs host-specific modules, profiles, aggregators | [references/module-organization.md](references/module-organization.md) |
| 7 | Home Manager boundary (user config, no packages) | [references/home-manager-boundary.md](references/home-manager-boundary.md) |
| 8 | Module options, types, contracts, RFC 42 settings, and dependency injection (_module.args) | [references/options-and-dependency-injection.md](references/options-and-dependency-injection.md) |
| 9 | Evaluation vs runtime, flake tooling, VM integration tests, validation checklist | [references/evaluation-and-checklist.md](references/evaluation-and-checklist.md) |
| 10 | Official Nix antipatterns and best practices (nix.dev) | [references/antipatterns-and-best-practices.md](references/antipatterns-and-best-practices.md) |
