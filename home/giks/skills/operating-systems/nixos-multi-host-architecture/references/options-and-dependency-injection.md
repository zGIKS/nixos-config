# Options, Module Contracts, and Dependency Injection

## 13. Options and module contracts

Configurable capabilities should expose namespaced options and keep their internal
implementation private behind those options.

### NixOS Option Definition Types

NixOS provides a rich type system in `lib.types` to enforce constraints at evaluation time:

| Type | Description | Example |
|------|-------------|---------|
| `types.bool` | Boolean value | `true`, `false` |
| `types.str` | Arbitrary string | `"hello"` |
| `types.int` | Integer | `8080` |
| `types.port` | Valid TCP/UDP port (0–65535) | `443` |
| `types.path` | File or directory path | `/etc/config.json` |
| `types.package` | Derivation/package | `pkgs.ripgrep` |
| `types.enum [ ... ]` | Exact set of allowed strings | `types.enum [ "debug" "info" "warn" "error" ]` |
| `types.listOf <type>` | List of homogeneous elements | `types.listOf types.str` |
| `types.attrsOf <type>` | Attribute set of homogeneous values | `types.attrsOf types.package` |
| `types.nullOr <type>` | Value of `<type>` or `null` | `types.nullOr types.str` |
| `types.submodule { ... }` | Structured nested configuration schema | (see example below) |

### Option Constructors

1. **`lib.mkOption { ... }`**:
   The general-purpose option declaration:
   ```nix
   port = lib.mkOption {
     type = types.port;
     default = 8080;
     description = "Port on which the service listens.";
     example = 9090;
   };
   ```

2. **`lib.mkEnableOption "description"`**:
   Standard shorthand for a boolean enable flag defaulting to `false`:
   ```nix
   enable = lib.mkEnableOption "the Prometheus node exporter";
   ```

3. **`lib.mkPackageOption pkgs "name" { ... }`**:
   Standard constructor for configurable package selection, defaulting to `pkgs.<name>`:
   ```nix
   package = lib.mkPackageOption pkgs "prometheus-node-exporter" {
     default = [ "prometheus-node-exporter" ];
     example = "pkgs.prometheus-node-exporter";
   };
   ```

### Merge Functions and Priority

The NixOS module system uses priorities to resolve conflicting definitions:

- **`lib.mkIf condition expression`**: Conditionally evaluates configuration. If `false`, the enclosed attrs are completely pruned from evaluation.
- **`lib.mkDefault value`**: Assigns priority 1000 (overridable default). Used in shared modules and profiles so hosts can easily override values.
- **`lib.mkForce value`**: Assigns priority 50 (forces value over normal assignments). Use sparingly, only when an architectural boundary must guarantee an override.
- **`lib.mkMerge [ ... ]`**: Merges multiple configuration attribute sets explicitly.

### Structured Settings Options (RFC 42 & `freeformType`)

Instead of writing repetitive, flat option definitions for every single parameter of an upstream service, use the RFC 42 `settings` pattern with a generator from `pkgs.formats`:

```nix
options.platform.services.app.settings = lib.mkOption {
  type = lib.types.submodule {
    # Allow any valid YAML configuration keys without individual option declarations
    freeformType = (pkgs.formats.yaml { }).type;

    options = {
      # Declare explicit options only for values NixOS must inspect or validate
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Service port (also opened in firewall).";
      };
    };
  };
  default = { };
  description = "Structured service configuration serialized directly to config file.";
};
```
Generate configuration files using `pkgs.formats.yaml`, `pkgs.formats.json`, `pkgs.formats.toml`, or `pkgs.formats.ini`:
```nix
configFile = (pkgs.formats.yaml { }).generate "app-config.yaml" cfg.settings;
```

### Overriding Upstream Modules: `disabledModules`

When replacing an upstream NixOS module (for example to backport an updated service definition or patch upstream logic), do not fork Nixpkgs. Use `disabledModules`:

```nix
{
  # Path relative to nixpkgs/nixos/modules/ (note directory modules end in /default.nix)
  disabledModules = [ "services/web-servers/caddy/default.nix" ];

  imports = [
    # Import your custom module implementation
    ./modules/custom-caddy.nix
  ];
}
```

### Compile-time Validation: Assertions & Warnings

Every module contract should validate its operational invariants at evaluation time:

- **`assertions`**: List of attribute sets `{ assertion = <bool>; message = "<string>"; }`. If any condition evaluates to `false`, evaluation aborts with the message.
- **`warnings`**: List of strings displayed during evaluation for non-fatal configuration issues or impending deprecations.

### Complete Module Contract Example

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.platform.services.app;
in
{
  options.platform.services.app = {
    enable = lib.mkEnableOption "the production application service";

    package = lib.mkPackageOption pkgs "my-app" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "TCP port the application binds to.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [ "debug" "info" "warn" "error" ];
      default = "info";
      description = "Logging verbosity.";
    };

    endpoints = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          path = lib.mkOption {
            type = lib.types.str;
            description = "URL mount path.";
          };
          rateLimit = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "Requests per minute limit.";
          };
        };
      });
      default = { };
      description = "Configured application endpoints.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Invariant assertions
    assertions = [
      {
        assertion = cfg.port != 80 && cfg.port != 443;
        message = "platform.services.app: Cannot bind directly to privileged port ${toString cfg.port}; use a reverse proxy.";
      }
    ];

    systemd.services.app = {
      description = "Production Application Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/app --port ${toString cfg.port} --log-level ${cfg.logLevel}";
        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
      };
    };
  };
}
```

---

## 14. Dependency Injection: Prefer `_module.args` Over `specialArgs`

### The Rule
> **Prefer `_module.args.<name> = ...` for injecting module arguments, context, and helpers over passing them through flake `specialArgs`.**

### Rationale: Why `_module.args` is Superior

1. **Evaluated Inside the Module System**:
   `_module.args` is defined within NixOS modules. This keeps `flake.nix` clean and minimal, avoiding the anti-pattern of turning the composition root into a parameter dump.
2. **Participates in Priority (`mkDefault` / `mkForce`)**:
   Arguments injected via `_module.args` can use `lib.mkDefault`, allowing hosts or child profiles to override injected defaults gracefully. Flake `specialArgs` cannot participate in priority merging.
3. **Overridable and Scoped**:
   Host composition modules or profile aggregators can supply or modify arguments scoped to their needs without coordinating with `flake.nix`.
4. **Testable & Isolated**:
   Modules injecting or consuming `_module.args` can be tested in isolation (e.g. inside `pkgs.testers.runNixOSTest`) without mocking flake-level infrastructure.

### Type Semantics of `_module.args` vs Typed Options

It is important to understand the type guarantees of each mechanism:
- **`_module.args` is untyped**: In the NixOS option system, `_module.args` is defined with type `types.lazyAttrsOf types.raw`. It evaluates arguments lazily as raw Nix expressions without performing schema validation, type checking, or constraint assertions.
- **Use `options` for Typed Configuration**: For any system or domain configuration (ports, hostnames, boolean toggles, credentials paths), declare explicit options using `lib.mkOption` and `lib.types.*`. Access them via `config.<namespace>`.
- **Use `_module.args` for Helpers and Raw Context**: Reserve `_module.args` for injecting utility libraries, flake inputs, platform helper functions, or raw instances that cannot be cleanly modeled as typed options.

### When to use `specialArgs` vs `_module.args`

- **Use `specialArgs` ONLY for**:
  Values strictly required **before** module system evaluation begins. Specifically:
  - Passing flake `inputs` so module files can reference flake inputs directly.
  - Parameters required to determine which file paths to include in `imports = [ ... ]` (conditional imports evaluated prior to option merging).
- **Use `_module.args` for**:
  All other values, helpers, metadata, domain parameters, and cross-cutting capabilities.

### Dependency Injection Example

#### Injecting arguments in a shared profile or host:
```nix
# hosts/srv-core-01/default.nix
{ config, lib, pkgs, ... }:

{
  # Inject host metadata and platform helpers into all modules evaluated for this host
  _module.args = {
    hostRole = "api-gateway";
    clusterDomain = "internal.corp";
    platformHelpers = import ../../lib/helpers.nix { inherit lib pkgs; };
  };
}
```

#### Consuming the injected argument in any module:
```nix
# modules/hosts/shared/system/services/gateway.nix
{ config, lib, pkgs, hostRole, clusterDomain, platformHelpers, ... }:

{
  # Injected arguments are directly available in the module header!
  config = lib.mkIf (hostRole == "api-gateway") {
    networking.domain = clusterDomain;
    # ...
  };
}
```
