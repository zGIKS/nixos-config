# Plan de Migración a Clean OS Architecture

## Estado Actual — Diagnóstico

Tu repo actual tiene **un solo flake** (bien) con **2 hosts** (`gramnyx`, `mai`). El problema principal es que la configuración compartida vive en un **monolito** (`modules/nixos/profiles/host-common.nix`) que viola casi todas las reglas de separación de responsabilidades de la guía.

### Problemas identificados

| Problema | Ubicación | Impacto |
|---|---|---|
| **Monolito host-common.nix** | `modules/nixos/profiles/host-common.nix` | Mezcla hardware, networking, services, session, users, packages en un solo archivo. |
| **Servicios en capa de packages** | `profiles/dev.nix` tiene `virtualisation.docker.enable` | Docker es un daemon (Services), no un package. |
| **Session en capa de packages** | `profiles/desktop.nix` tiene `xdg.portal` | Portal es infraestructura de sesión gráfica. |
| **Hardware específico en host mezclado con session** | `hosts/mai/configuration.nix` | Tiene `services.asusd`, `hardware.nvidia`, `programs.sway.extraOptions` y variables de sesión Flatpak todo junto. |
| **Config host-específica en módulo compartido** | `host-common.nix` tiene `grub.extraEntries` (dual-boot) y `networking.hostName` | Si agregas un tercer host sin dual-boot, ese módulo rompe. |
| **Home Manager sin estructura de capas** | `modules/home/programs/*.nix` | Están bien separados por programa, pero podrían agruparse por responsabilidad (session vs devtools). |
| **Sin `lib/` ni `overlays/` explícitos** | — | `homeLib` se inyecta manualmente en `flake.nix`; el overlay unstable también. |

---

## Arquitectura Objetivo

Mantener **un solo flake** (recomendación de la guía) con esta estructura:

```
.
├── flake.nix
├── flake.lock
├── lib/
│   └── default.nix                 # helpers puros (mkConfigLinks, etc.)
├── overlays/
│   └── default.nix                 # overlays del repo (unstable, custom)
├── modules/
│   ├── hardware/
│   │   ├── cpu.nix
│   │   ├── gpu/
│   │   │   ├── nvidia.nix
│   │   │   └── intel.nix
│   │   ├── bluetooth.nix
│   │   └── audio.nix
│   ├── kernel/
│   │   └── boot.nix                # grub-uefi + generic bootloader
│   ├── filesystem/
│   │   └── (reservado)
│   ├── networking/
│   │   ├── base.nix                # networkmanager, resolved, hostname
│   │   ├── firewall.nix
│   │   └── vpn.nix                 # mullvad-vpn
│   ├── services/
│   │   ├── pipewire.nix
│   │   ├── printing.nix
│   │   ├── docker.nix
│   │   ├── greetd.nix
│   │   ├── flatpak.nix
│   │   ├── keyring.nix             # gnome-keyring + pam + seahorse
│   │   └── asus.nix                # asusd + supergfxd + rog-control-center
│   ├── packages/
│   │   ├── profiles/
│   │   │   ├── core.nix
│   │   │   ├── desktop.nix         # fonts + xdg.portal
│   │   │   ├── dev.nix             # herramientas dev (solo packages)
│   │   │   └── fonts.nix
│   │   └── volta.nix
│   ├── session/
│   │   ├── sway.nix                # programs.sway + xwayland
│   │   ├── waybar.nix
│   │   ├── wofi.nix
│   │   ├── eww.nix
│   │   ├── theme.nix               # gtk, qt, cursor, dconf
│   │   └── display-manager.nix     # greetd / sddm / etc.
│   └── users/
│       └── giks.nix                # definición del usuario base
├── hosts/
│   ├── gramnyx/
│   │   ├── default.nix             # composition root de gramnyx
│   │   └── hardware-configuration.nix
│   └── mai/
│       ├── default.nix             # composition root de mai
│       └── hardware-configuration.nix
├── home/                           # Home Manager modules separados por usuario
│   └── giks/
│       ├── default.nix
│       └── modules/
│           ├── git.nix
│           ├── shell.nix
│           ├── nvim.nix
│           ├── theme.nix
│           └── session/
│               ├── sway.nix
│               ├── waybar.nix
│               ├── wofi.nix
│               ├── eww.nix
│               └── apps.nix
└── assets/
    └── wallpapers/
```

---

## Reglas de Composición por Host

Cada `hosts/<host>/default.nix` se convierte en el **composition root** explícito. No debe haber lógica host-específica dentro de `modules/`.

### `hosts/mai/default.nix` (ASUS + NVIDIA Optimus)

```nix
{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    # Capas del sistema
    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/audio.nix
    ../../modules/hardware/gpu/nvidia.nix   # config genérica de nvidia
    ../../modules/kernel/boot.nix
    ../../modules/networking/base.nix
    ../../modules/networking/vpn.nix
    ../../modules/services/pipewire.nix
    ../../modules/services/printing.nix
    ../../modules/services/greetd.nix
    ../../modules/services/keyring.nix
    ../../modules/services/flatpak.nix
    ../../modules/services/docker.nix
    ../../modules/services/asus.nix          # asusd + supergfxd
    ../../modules/packages/profiles/core.nix
    ../../modules/packages/profiles/desktop.nix
    ../../modules/packages/profiles/fonts.nix
    ../../modules/packages/profiles/dev.nix
    ../../modules/packages/volta.nix
    ../../modules/session/sway.nix
    ../../modules/session/waybar.nix
    ../../modules/session/wofi.nix
    ../../modules/session/theme.nix
    ../../modules/session/display-manager.nix
    ../../modules/users/giks.nix
  ];

  # Host-specific facts SOLAMENTE aquí
  networking.hostName = "mai";
  services.xserver.xkb.layout = "us";

  # ASUS-specific overrides
  services.asusd.enable = true;
  services.supergfxd.enable = true;
  programs.rog-control-center.enable = true;

  # NVIDIA Prime (específico de este laptop)
  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Sway workaround para NVIDIA
  programs.sway.extraOptions = [ "--unsupported-gpu" ];
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  # Dual-boot Windows (específico de mai)
  boot.loader.grub.extraEntries = ''
    menuentry "Windows 11" {
      insmod part_gpt
      insmod fat
      search --no-floppy --file --set=root /EFI/Microsoft/Boot/bootmgfw.efi
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';

  # Packages específicos de mai
  environment.systemPackages = with pkgs; [
    supergfxctl
    beekeeper-studio
    gnome-software
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.3.4"
  ];
}
```

### `hosts/gramnyx/default.nix`

```nix
{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/audio.nix
    ../../modules/kernel/boot.nix
    ../../modules/networking/base.nix
    ../../modules/networking/vpn.nix
    ../../modules/services/pipewire.nix
    ../../modules/services/printing.nix
    ../../modules/services/greetd.nix
    ../../modules/services/keyring.nix
    ../../modules/services/flatpak.nix
    ../../modules/services/docker.nix
    ../../modules/packages/profiles/core.nix
    ../../modules/packages/profiles/desktop.nix
    ../../modules/packages/profiles/fonts.nix
    ../../modules/packages/profiles/dev.nix
    ../../modules/packages/volta.nix
    ../../modules/session/sway.nix
    ../../modules/session/waybar.nix
    ../../modules/session/wofi.nix
    ../../modules/session/theme.nix
    ../../modules/session/display-manager.nix
    ../../modules/users/giks.nix
  ];

  networking.hostName = "gramnyx";
  services.xserver.xkb.layout = "latam";
}
```

---

## Plan de Migración por Fases

### Fase 0: Preparación — Esqueleto y Utilidades

1. Crear directorios nuevos (`modules/hardware`, `modules/kernel`, `modules/networking`, `modules/services`, `modules/packages/profiles`, `modules/session`, `modules/users`, `lib/`, `overlays/`, `home/giks/modules/`).
2. Mover `modules/home/lib.nix` → `lib/default.nix`.
3. Crear `overlays/default.nix` con el overlay de unstable que hoy vive en `flake.nix`.
4. Actualizar `flake.nix` para inyectar `platformLib` via `specialArgs` y aplicar `overlays.default`.

**Commit sugerido:** `chore: scaffold clean os architecture directories`

---

### Fase 1: Capa Kernel

1. Mover `modules/nixos/boot/grub-uefi.nix` → `modules/kernel/boot.nix`.
2. Eliminar el `grub.extraEntries` de ahí (se vuelve host-specific en `hosts/mai/default.nix`).
3. Ambos hosts importan `modules/kernel/boot.nix`.

**Commit sugerido:** `refactor(kernel): extract boot config to kernel layer`

---

### Fase 2: Capa Hardware

Extraer todo lo que habla con el hardware físico:

| Origen | Destino |
|---|---|
| `host-common.nix`: `hardware.bluetooth` | `modules/hardware/bluetooth.nix` |
| `host-common.nix`: `services.blueman` | `modules/hardware/bluetooth.nix` (blueman es UI de bluetooth, pero gestiona hardware) |
| `host-common.nix`: `services.pipewire` + `alsa` + `pulse` | `modules/hardware/audio.nix` o `modules/services/pipewire.nix` (recomendado: Services) |
| `mai/configuration.nix`: `hardware.nvidia` genérico | `modules/hardware/gpu/nvidia.nix` (sin la sección `prime`) |
| `mai/configuration.nix`: `hardware.graphics` | `modules/hardware/gpu/nvidia.nix` o módulo genérico |

**Nota:** `asusd`, `supergfxd`, `rog-control-center` son **hardware específico ASUS**, pero también son services/daemons. La guía recomienda poner daemons en Services. Crear `modules/services/asus.nix` que sea importado solo por `mai`.

**Commit sugerido:** `refactor(hardware): extract bluetooth, audio, gpu abstractions`

---

### Fase 3: Capa Networking

Extraer todo lo relacionado a red:

| Origen | Destino |
|---|---|
| `host-common.nix`: `networking.networkmanager.enable` | `modules/networking/base.nix` |
| `host-common.nix`: `services.resolved.enable` | `modules/networking/base.nix` |
| `host-common.nix`: `services.mullvad-vpn` | `modules/networking/vpn.nix` |
| `host-common.nix`: `networking.hostName` | **Queda en cada host** |
| `host-common.nix`: `services.xserver.xkb.layout` | **Session/Host** |

**Commit sugerido:** `refactor(networking): extract base connectivity and vpn`

---

### Fase 4: Capa Services

Extraer todos los daemons y servicios del sistema:

| Origen | Destino |
|---|---|
| `host-common.nix`: `services.pipewire` + `alsa` + `pulse` + `wireplumber` + `rtkit` | `modules/services/pipewire.nix` |
| `host-common.nix`: `services.printing.enable` | `modules/services/printing.nix` |
| `host-common.nix`: `services.greetd` + `services.displayManager.sddm` | `modules/services/greetd.nix` o `modules/session/display-manager.nix` |
| `host-common.nix`: `services.gnome.gnome-keyring` + `programs.seahorse` + `security.pam` | `modules/services/keyring.nix` |
| `host-common.nix`: `services.flatpak` + `services.packagekit` | `modules/services/flatpak.nix` |
| `profiles/dev.nix`: `virtualisation.docker.enable` | `modules/services/docker.nix` |
| `mai/configuration.nix`: `services.asusd` + `services.supergfxd` + `programs.rog-control-center` | `modules/services/asus.nix` |

**Commit sugerido:** `refactor(services): extract all system daemons to services layer`

---

### Fase 5: Capa Packages

Reorganizar perfiles sin lógica de servicios:

| Origen | Destino |
|---|---|
| `profiles/core.nix` | `modules/packages/profiles/core.nix` (sin cambios) |
| `profiles/desktop.nix` (fonts + xdg.portal) | Dividir: fonts → `modules/packages/profiles/fonts.nix`; xdg.portal → `modules/session/portals.nix` |
| `profiles/dev.nix` (sin docker) | `modules/packages/profiles/dev.nix` (solo packages) |
| `modules/nixos/tools/volta.nix` | `modules/packages/volta.nix` |

**Commit sugerido:** `refactor(packages): split profiles and remove service logic`

---

### Fase 6: Capa Session

Extraer toda la experiencia gráfica y desktop:

| Origen | Destino |
|---|---|
| `modules/nixos/desktop/sway.nix` | `modules/session/sway.nix` |
| `host-common.nix`: `services.xserver.enable` + `xkb` | `modules/session/display-manager.nix` o host (xkb es específico) |
| `host-common.nix`: `services.greetd` | `modules/session/display-manager.nix` |
| `host-common.nix`: `xdg.portal` | `modules/session/portals.nix` |
| Home modules: waybar, wofi, eww, theme | Se quedan en Home Manager (ver Fase 8) |
| `mai/configuration.nix`: `programs.sway.extraOptions`, `WLR_NO_HARDWARE_CURSORS` | `hosts/mai/default.nix` (hardware-specific workaround) |

**Commit sugerido:** `refactor(session): extract display manager, portals, wm config`

---

### Fase 7: Capa Users

1. Extraer definición de usuario de `host-common.nix` → `modules/users/giks.nix`.
2. Dejar `users.users.giks.extraGroups` configurable o fija según prefieras.
3. Eliminar `users.users.giks.packages = []` vacío.

**Commit sugerido:** `refactor(users): extract user definition to users layer`

---

### Fase 8: Home Manager Limpio

Reorganizar `modules/home/` → `home/giks/modules/` con estructura por capas:

```
home/giks/modules/
├── git.nix
├── shell.nix
├── nvim.nix
├── theme.nix           # gtk, qt, cursor
└── session/
    ├── sway.nix        # config files + inputs.conf host-specific
    ├── waybar.nix
    ├── wofi.nix
    ├── eww.nix
    └── apps.nix
```

**Importante:** `home/giks/modules/session/sway.nix` tiene `keyboardLayout` inyectado para generar `inputs.conf`. Esto es correcto (inyección de dependencia). Mantenerlo.

**Commit sugerido:** `refactor(home): reorganize home-manager modules by layer`

---

### Fase 9: Recomposición del Flake

Actualizar `flake.nix` para:

1. Eliminar `hostConfigs` embebido; usar `mapAttrs` sobre un set de hosts más declarativo.
2. Pasar `platformLib` en `specialArgs` y `extraSpecialArgs`.
3. Aplicar overlay desde `overlays/default.nix`.
4. Simplificar `users/giks/home.nix` para que importe desde `home/giks/modules/`.

Ejemplo de estructura objetivo del `outputs`:

```nix
{
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nit, pomodog, ... }:
    let
      system = "x86_64-linux";
      username = "giks";
      platformLib = import ./lib { inherit lib; };
      pkgsUnstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };

      overlays = import ./overlays { inherit pkgsUnstable; };

      mkHost = hostName: extraArgs:
        let
          specialArgs = {
            inherit username hostName platformLib nit pomodog;
          } // extraArgs;
        in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./hosts/${hostName}
            { nixpkgs.overlays = [ overlays.default ]; }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./home/${username};
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        gramnyx = mkHost "gramnyx" {
          roles = [ "desktop" "dev" ];
          keyboardLayout = "latam";
        };
        mai = mkHost "mai" {
          roles = [ "desktop" "dev" ];
          keyboardLayout = "us";
        };
      };
    };
}
```

**Commit sugerido:** `refactor(flake): simplify composition and inject platformLib`

---

### Fase 10: Limpieza y Validación

1. Eliminar `modules/nixos/` viejo (cuando todo esté migrado).
2. Eliminar `users/giks/home.nix` viejo (reemplazado por `home/giks/default.nix`).
3. Ejecutar `nix flake check`.
4. Hacer `nixos-rebuild build --flake .#mai` y `--flake .#gramnyx` para validar evaluación sin switch.
5. Arreglar referencias rotas.

**Commit sugerido:** `chore: remove legacy module paths`

---

## Matriz de Migración Detallada

| # | Archivo origen | Responsabilidad actual | Destino propuesto | Acción |
|---|---|---|---|---|
| 1 | `flake.nix` | Composition root | `flake.nix` | Refactor `specialArgs`, inyectar `platformLib`, extraer overlays |
| 2 | `modules/home/lib.nix` | Helpers puros | `lib/default.nix` | Mover + expandir |
| 3 | `modules/nixos/boot/grub-uefi.nix` | Bootloader | `modules/kernel/boot.nix` | Mover; quitar `extraEntries` |
| 4 | `modules/nixos/profiles/host-common.nix` | **MONOLITO** | Múltiples capas | **Descomponer completamente** |
| 4a | `host-common.nix` → hw bits | Bluetooth, audio | `modules/hardware/` | Extraer |
| 4b | `host-common.nix` → net bits | NetworkManager, VPN | `modules/networking/` | Extraer |
| 4c | `host-common.nix` → svc bits | Pipewire, printing, greetd, keyring, flatpak | `modules/services/` | Extraer |
| 4d | `host-common.nix` → pkg bits | Fonts, allowUnfree list | `modules/packages/` | Extraer |
| 4e | `host-common.nix` → session bits | X11, display manager, tuigreet | `modules/session/` | Extraer |
| 4f | `host-common.nix` → user bits | `users.users.giks` | `modules/users/giks.nix` | Extraer |
| 5 | `modules/nixos/profiles/core.nix` | Core packages | `modules/packages/profiles/core.nix` | Mover (sin cambios) |
| 6 | `modules/nixos/profiles/desktop.nix` | Fonts + xdg.portal | `modules/packages/profiles/fonts.nix` + `modules/session/portals.nix` | Dividir |
| 7 | `modules/nixos/profiles/dev.nix` | Dev packages + Docker | `modules/packages/profiles/dev.nix` (solo pkgs) + `modules/services/docker.nix` | Dividir |
| 8 | `modules/nixos/desktop/sway.nix` | Sway enable | `modules/session/sway.nix` | Mover |
| 9 | `modules/nixos/tools/volta.nix` | Volta tool | `modules/packages/volta.nix` | Mover |
| 10 | `hosts/mai/configuration.nix` | Hardware ASUS + NVIDIA + session hacks | `hosts/mai/default.nix` | Consolidar imports + overrides host-specific |
| 11 | `hosts/gramnyx/configuration.nix` | Casi vacío | `hosts/gramnyx/default.nix` | Consolidar imports |
| 12 | `users/giks/home.nix` | Entry point HM | `home/giks/default.nix` | Mover + rewire imports |
| 13 | `modules/home/programs/*.nix` | Home modules | `home/giks/modules/` | Reorganizar en `session/` y root |

---

## Principios Aplicados Específicamente

1. **Sin archivos monolíticos gigantes**: `host-common.nix` (124 líneas, 7 responsabilidades) → 10+ módulos especializados.
2. **Sin mezclar concerns**: Docker deja de vivir en `dev.nix` (packages) y pasa a `services/docker.nix`.
3. **Sin configuración host-specific en módulos compartidos**: `grub.extraEntries` (dual-boot Windows) solo existe en `mai`.
4. **Composición explícita**: Cada host importa exactamente las capas que necesita. `gramnyx` no importa `modules/services/asus.nix`.
5. **Un flake, múltiples hosts**: Se mantiene la estructura actual, solo se limpia.
6. **Inyección de dependencias**: `keyboardLayout`, `roles`, `platformLib` se pasan via `specialArgs`.

---

## Riesgos y Mitigaciones

| Riesgo | Mitigación |
|---|---|
| Romper la configuración de `mai` al separar NVIDIA/ASUS | Mantener los mismos valores de config, solo cambiar la ubicación del archivo. Hacer `nixos-rebuild build` antes de `switch`. |
| Perder el estado de Home Manager | `home-manager.backupFileExtension = "backup"` ya está activo. Verificar que `home.file` y `xdg.configFile` se generen en las mismas rutas. |
| Referencias rotas a `../../../home/programs/` | Los paths relativos de `home/` modules cambiarán de profundidad. Ajustar `source = ./../../home/programs/...` según la nueva ubicación. |
| Evaluación lenta por muchos imports pequeños | NixOS maneja bien los imports. Si hay preocupación, usar `modules/default.nix` que re-exporta todo. |

---

## Próximos Pasos

1. **Revisa este plan** y decide si quieres ajustar alguna asignación de responsabilidad (por ejemplo, si prefieres `modules/session/display-manager.nix` vs `modules/services/greetd.nix`).
2. Si estás de acuerdo, puedo empezar a ejecutar **Fase 0 y Fase 1** automáticamente.
3. Recomiendo hacer un `git branch feature/clean-os-arch` antes de empezar.
