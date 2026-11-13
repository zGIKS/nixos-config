# Shared/Host-Specific Modules, Profiles, and Aggregators

## 10. Shared and host-specific modules

Use explicit scope to distinguish reusable modules from machine-specific ones:

```text
modules/hosts/shared/<domain>       reusable capability
modules/hosts/<host>/<domain>       host-specific capability
```

Shared modules must not depend on a particular host name. Host-specific modules
may depend on shared options and capabilities.

Good dependency direction:

```text
Host Composition
      │
      ├── Shared Profiles
      └── Host-Specific Profiles
              │
              └── System Options and Services
```

Avoid copying a shared module just to change one value. Prefer an option with a
safe default, a host override, or a small host-specific module.

## 11. Profiles, aggregators, and module depth

### Everything is a Module
In NixOS, every configuration file—from the root flake down to a single service definition—is a module evaluated by the same module system. Modules declare `options` and set `config`, composed through `imports`:
```nix
{ config, lib, pkgs, ... }:
{
  imports = [ ./sub-module.nix ];
  config.services.openssh.enable = true;
}
```

### Official Upstream Profiles
Nixpkgs provides built-in system profiles that encapsulate standard machine postures:
- `<nixpkgs/nixos/modules/profiles/headless.nix>` (disables graphical subsystems, sound, and interactive desktop services for headless servers).
- `<nixpkgs/nixos/modules/profiles/minimal.nix>` (strips documentation, manpages, and optional utilities for lightweight containers/VMs).
- `<nixpkgs/nixos/modules/profiles/per-user-pkgs.nix>` (optimizes multi-user system environments).

Import these in host compositions or base profiles where appropriate:
```nix
imports = [
  "${modulesPath}/profiles/headless.nix"
];
```

### Disabling Upstream Modules (`disabledModules`)
If an upstream NixOS module is incompatible, buggy, or requires a complete rewrite, use `disabledModules` rather than forking Nixpkgs:
```nix
{
  # Path relative to nixpkgs/nixos/modules/
  disabledModules = [ "services/security/fail2ban.nix" ];
  imports = [ ./modules/fail2ban-custom.nix ];
}
```

### Module Aggregators

An aggregator module imports smaller modules:

```text
applications/profiles/desktop/default.nix
└── tools/default.nix
    ├── audio.nix
    ├── display.nix
    └── launcher.nix
```

Aggregators are organizational units. They do not create runtime phases.

Keep import depth understandable. Deep nesting is acceptable when each level
has a clear responsibility, but arbitrary chains of `default.nix` files make
ownership and debugging harder.
