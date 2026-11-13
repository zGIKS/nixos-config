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

### Secret Management at the Operating System Level

1. **The Nix Store is World-Readable (`chmod a+r /nix/store`)**:
   - Every file, derivation, and string copied into `/nix/store` is globally readable by any unprivileged user or process running on the host.
   - **Absolute Rule**: **NEVER** write plaintext secrets, API keys, private certificates, or passwords inside Nix files.
   - **Path Literal Anti-Pattern**: Never pass a file path containing a secret as a Nix path literal (e.g. `passwordFile = ./secrets/db.pass;`). Nix copies path literals directly into `/nix/store/...` with world-readable permissions during evaluation.

2. **Official NixOS Secret Mechanism: `*File` Options and Runtime Credentials**:
   - Always reference secrets using strings pointing to runtime filesystem paths that exist outside the Nix store (e.g., in `/run/secrets/` on a memory-backed tmpfs or root-owned persistent state).
   - Use official NixOS module `*File` options where available, or systemd runtime credentials:
     ```nix
     # Real NixOS *File module options:
     services.nextcloud.config.adminpassFile = "/run/secrets/nextcloud-admin-pass";
     services.grafana.security.secretKeyFile = "/run/secrets/grafana-secret-key";

     # Native systemd runtime environment files and credentials:
     systemd.services.api.serviceConfig = {
       EnvironmentFile = "/run/secrets/api.env";
       LoadCredential = [ "db-password:/run/secrets/db.pass" ];
     };
     ```
   - Runtime provisioning of these files should be handled by a dedicated secret manager (e.g. `sops-nix`, `agenix`, or systemd encrypted credentials), ensuring they are decrypted into volatile memory with `0400` root permissions on boot.

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

### Prefer `programs.<x>.enable` and `services.<x>.enable` Over Raw Packages

A common mistake in NixOS configurations is adding software directly to `environment.systemPackages` when an official NixOS module exists:

```nix
# BAD: Only installs the binary; misses critical system integration
environment.systemPackages = [ pkgs.wireshark pkgs.gnupg pkgs.swaylock ];

# GOOD: Official NixOS modules configure capabilities, PAM, and permissions
programs.wireshark.enable = true; # Adds setuid dumpcap wrapper and wireshark user group
programs.gnupg.agent.enable = true; # Configures pinentry, GPG agent daemon, and socket forwarding
security.pam.services.swaylock = { }; # Required for swaylock to verify user passwords under PAM
```

#### Why `programs.*` and `services.*` are required:
- **Setuid / Capabilities**: Many tools require Linux capabilities or setuid bits (e.g. `dumpcap`, `ping`, `traceroute`). Nix store binaries are mounted `nosuid`. Only NixOS modules create setuid wrappers in `/run/wrappers/bin`.
- **PAM Integration**: Screen lockers (`swaylock`, `hyprlock`) and authentication agents fail without PAM service entries in `/etc/pam.d/`.
- **D-Bus & Polkit**: Daemons and desktop utilities require D-Bus service files in `/etc/dbus-1/system.d` and Polkit action rules. Raw packages in `systemPackages` do not register these with system daemons.
- **Rule**: Whenever a tool has an official module under `programs.<name>` or `services.<name>`, use the module rather than `environment.systemPackages`.

---

### Prohibit Imperative Package Managers

To maintain absolute reproducibility, auditable state, and reliable system rollbacks across all hosts:
- **Never use imperative package installation**:
  - Do not use `nix-env -i` or `nix-env -e`.
  - Do not use `nix profile install`.
- **Why**: Imperative package profiles create mutable state in `~/.nix-profile/` that shadows system-wide configurations, conflicts with declarative packages, breaks generation rollbacks (`nixos-rebuild switch --rollback` does not affect `nix-env`), and introduces untracked drift across your host fleet.

---

### Overlay vs `override` vs `overrideAttrs`

Choose the right mechanism for package customization based on scope and architectural boundaries:

| Mechanism | Purpose | Scope | When to use |
|---|---|---|---|
| `pkg.override { ... }` | Modifies inputs passed to a derivation function | Local to the caller | Toggling build flags or passing alternate libraries to a single program (e.g. `pkgs.ripgrep.override { withPCRE2 = true; }`). |
| `pkg.overrideAttrs (old: { ... })` | Modifies the raw `mkDerivation` attributes | Local to the caller | Applying source patches, bumping a specific package version, or modifying build phases (`patches = [ ./fix.patch ];`). |
| `overlays = [ ... ]` | Modifies the entire Nixpkgs package tree | Global to the host | When a package or library must be changed across **all** consumers and dependent services in the system. |

**Rule of Thumb**: Prefer local `override` or `overrideAttrs` when only one service or profile needs a modified tool. Use overlays only when widespread system-level replacement is strictly required.

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
     This changes the derivation hash of all dependent packages. Because these new hashes do not exist in upstream binary caches (`cache.nixos.org`), Nix cannot download pre-built substitutes and is forced to recompile thousands of packages locally from source on every host.
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
