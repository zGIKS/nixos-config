# Services and Applications Layers

## 7. Services layer

Location: `modules/hosts/<scope>/system/services/`.

The services layer manages long-running system processes, daemons, and scheduled jobs.

Typical responsibilities:
- Service enablement and configuration;
- Systemd units, dependencies, ordering, and security sandboxing;
- Containerization and virtualization (Docker, Podman, libvirt);
- Databases and caching daemons (PostgreSQL, Redis);
- Network daemons (OpenSSH, Nginx, HAProxy);
- Desktop system daemons (PipeWire, CUPS, Polkit).

Keep a service's required package next to its service module when the package has no meaning outside that service.
Service modules should expose clean options instead of requiring hosts to modify internal unit configurations directly.

---

### Systemd Architecture: Ordering vs Dependency

A common and critical misconception in systemd is conflating **dependency** with **startup order**. They are separate concepts managed by different directives:

#### 1. Dependency & Activation (`wants`, `requires`, `bindsTo`, `partOf`)
- These directives define **which** units get pulled in or activated when a service starts.
- **They do NOT define startup order!**
- If unit `A` specifies `requires = [ "B.service" ];` or `wants = [ "B.service" ];`, **both units start concurrently in parallel** unless explicit ordering is configured.
- `requires`: Hard dependency; if unit `B` fails to start, unit `A` is deactivated.
- `wants`: Soft dependency; unit `B` is started alongside `A`, but failure of `B` does not prevent `A` from running.
- `bindsTo`: Stronger than `requires`; if unit `B` stops (cleanly or by crash), unit `A` is immediately stopped.
- `partOf`: Propagates stop and restart commands from the master unit to this unit.

#### 2. Startup Ordering (`after`, `before`)
- Startup and shutdown ordering is defined **EXCLUSIVELY** by `after` and `before`.
- If unit `A` needs unit `B` to be fully started and operational before `A` initializes, unit `A` **MUST** declare:
  ```nix
  after = [ "B.service" ];
  requires = [ "B.service" ]; # or wants
  ```
- During shutdown, the order is strictly reversed: `after` units are stopped *before* the units they depend on.

#### 3. Target Attachment (`wantedBy`, `requiredBy`)
- `wantedBy` and `requiredBy` correspond to systemd's `[Install]` section.
- They determine which target (such as `multi-user.target` or `graphical.target`) hooks this service when the system boots or switches configuration:
  ```nix
  systemd.services.example = {
    wantedBy = [ "multi-user.target" ];
  };
  ```
- They do **not** dictate execution order within that target.

---

### Systemd Service Hardening Standards

All production systemd services running daemons or networked workloads should apply standard Linux namespace sandboxing and privilege reduction.

#### Core Hardening Directives

| Directive | Security Effect |
|-----------|-----------------|
| `DynamicUser = true` | Allocates an ephemeral, unprivileged UID/GID (from 61184–65519) on service start. Removed on exit. Eliminates static `/etc/passwd` accounts. |
| `ProtectSystem = "strict"` | Mounts the entire filesystem hierarchy (`/usr`, `/boot`, `/etc`, `/root`, etc.) strictly **read-only** to the unit, leaving only `/dev`, `/proc`, and `/sys` writable where needed. |
| `ProtectHome = true` | Renders `/home`, `/root`, and `/run/user` completely inaccessible and empty to the process. |
| `PrivateTmp = true` | Allocates an isolated `/tmp` and `/var/tmp` mount namespace, preventing symlink attacks and inter-process temporary file snooping. |
| `NoNewPrivileges = true` | Sets the `PR_SET_NO_NEW_PRIVS` flag, preventing child processes from escalating privileges via `setuid`/`setgid` binaries or filesystem capabilities. |
| `CapabilityBoundingSet = ""` | Drops **all** Linux kernel capabilities (e.g., `CAP_SYS_ADMIN`, `CAP_NET_ADMIN`, `CAP_CHOWN`), restricting the process to unprivileged userspace actions. |

#### Complete Hardened Service Example

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.platform.services.api;
in
{
  options.platform.services.api.enable =
    lib.mkEnableOption "the internal API daemon";

  config = lib.mkIf cfg.enable {
    systemd.services.api-daemon = {
      description = "Internal API Daemon";

      # Target attachment ([Install])
      wantedBy = [ "multi-user.target" ];

      # Startup ordering: MUST explicitly define after/before
      after = [ "network-online.target" "postgresql.service" ];
      wants = [ "network-online.target" ];
      requires = [ "postgresql.service" ];

      serviceConfig = {
        ExecStart = "${pkgs.my-api}/bin/api-server";
        Restart = "on-failure";
        RestartSec = 5;

        # --- Hardening Baseline ---
        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";

        # --- Additional Sandboxing ---
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        MemoryDenyWriteExecute = true;
        LockPersonality = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];

        # Read/Write isolation for application state
        StateDirectory = "api-daemon"; # Creates /var/lib/api-daemon owned by DynamicUser
      };
    };
  };
}
```

---

## 8. Applications and package profiles layer

Location: `modules/hosts/<scope>/applications/`.

This layer makes system applications and tools available across machines. It should use small,
purpose-driven profiles rather than one indiscriminate package list.

Recommended structure:

```text
applications/
├── overlays/
│   └── default.nix
└── profiles/
    ├── desktop/
    ├── development/
    ├── languages/
    ├── media/
    └── tools/
```

Typical responsibilities:
- Command-line utilities and shell environments;
- Desktop applications and browsers;
- Development toolchains and language runtimes;
- Package overrides, extensions, and custom derivations.

System packages must be declared through NixOS options such as
`environment.systemPackages`, `fonts.packages`, or the package option of the
owning service. Home Manager must **never** manage package installation.

---

### Overlays Architecture: Scoped, Pure, and Rebuild-Safe

Overlays modify or extend the package set (`pkgs`). If misconfigured, an overlay can force
recompilation of thousands of packages from source across your entire fleet.

#### Overlay Placement
1. **Flake Outputs (`overlays.<name>`)**: Export reusable overlays for external consumers or flake-level tests.
2. **NixOS Module Declaration (`nixpkgs.overlays = [ ... ];`)**: The canonical location to wire overlays into system evaluation.

#### Principles for Safe Overlays

1. **Keep Overlays Pure**:
   An overlay must be a pure function of two arguments:
   ```nix
   final: prev: {
     # final: contains the fully composed package set (use for package dependencies)
     # prev: contains the package set before this overlay (use for super/overridden packages)
   }
   ```

2. **Avoid Global Foundation Overrides (Rebuild Cascades)**:
   - **Anti-Pattern**: Overriding foundational packages at the root of the dependency graph:
     ```nix
     # DANGEROUS: Forces a complete rebuild of the entire world (glibc, gcc, python, systemd)
     final: prev: {
       openssl = prev.openssl.override { withCryptodev = true; };
     }
     ```
     This invalidates Hydra/NixOS binary cache signatures and forces hours of compilation on every host.
   - **Best Practice (New Package Attributes)**:
     Add your custom or patched package under a unique attribute name so downstream packages only pull it when explicitly requested:
     ```nix
     final: prev: {
       opensslCustom = prev.openssl.override { withCryptodev = true; };
       myInternalTool = final.callPackage ../../../pkgs/my-tool { };
     }
     ```

3. **Leaf Package Overrides**:
   Overriding leaf applications that have no downstream dependents (e.g. `neovim`, `tmux`, `ripgrep`) is safe and will not cause rebuild cascades:
   ```nix
   final: prev: {
     ripgrep = prev.ripgrep.override { withPCRE2 = true; };
   }
   ```
