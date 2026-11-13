# Environment and Session Layer

## 9. Environment and session layer

Location: `modules/hosts/<scope>/environment/`.

This layer configures the system environment and graphical session.

Recommended structure:

```text
environment/
├── profiles/
└── session/
```

Typical responsibilities:

- locale and environment defaults;
- fonts;
- display managers;
- portals;
- graphical session enablement;
- Sway, GNOME, KDE, or another system-level desktop integration;
- Flatpak policy;
- system-wide session services.

User-specific keybindings, application preferences, and dotfiles belong in
user configuration, not in this layer.

---

### Environment Variables: `variables` vs `sessionVariables`

NixOS provides two distinct options for defining environment variables, with different scopes in the process lifecycle:

| Option | Location & Target | Lifetime & Visibility |
|---|---|---|
| `environment.variables` | Written to `/etc/profile` | Loaded exclusively by interactive POSIX login shells. Not visible to non-shell graphical applications or systemd user units. |
| `environment.sessionVariables` | Written to `/etc/profile` AND `/etc/security/pam_env.conf` (or graphical wrapper) | Loaded during PAM session setup. Inherited by graphical desktop environments, Wayland/X11 compositors, and systemd user services. |

#### Architectural Rule:
- Use `environment.sessionVariables` for variables that must be respected across both desktop and terminal tools (e.g. `EDITOR = "nvim";`, `NIXOS_OZONE_WL = "1";`, `XDG_DATA_DIRS`).
- Use `environment.variables` only for shell-specific environment settings where PAM or desktop propagation is explicitly undesirable.

---

### Declarative Display Managers and Compositors

Desktop and graphical session enablement belongs at the system layer in NixOS:

```nix
# modules/hosts/shared/environment/session/sway.nix
{ config, lib, pkgs, ... }:

{
  # System-level compositor integration (configures pam, setuid, and seatd)
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Display manager and login greeting
  services.displayManager.ly.enable = true;

  # Desktop portals for sandboxed applications and screensharing
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Common desktop session variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_CURRENT_DESKTOP = "sway";
  };
}
```
