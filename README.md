# giks dotfiles

Configuración personal de NixOS con Flakes y Home Manager.

## Estructura

- `hosts/aurora/`: Composición específica del host (hardware, discos y selección de módulos).
- `modules/hosts/aurora/`: Módulos del sistema organizados por capas:
  - `boot/`: Configuración de GRUB y kernel Linux.
  - `hardware/`: Drivers NVIDIA, Bluetooth y soporte Steam.
  - `system/`: Servicios (Docker, PipeWire, ASUS ROG, OpenSSH, Tailscale, etc.).
  - `environment/`: Sesión Sway, display manager (`greetd`), fuentes y perfiles.
  - `applications/`: Perfiles de paquetes de desarrollo, escritorio, IA y navegadores.
- `home/giks/`: Configuración de usuario con Home Manager (Git, Neovim, Pi, terminal, agentes).
- `home/programs/`: Archivos de configuración enlazados a `$XDG_CONFIG_HOME` (Waybar, Sway, Foot, Fish, Fuzzel, Eww).

## Host actual

- Host: `aurora` (ASUS ROG Strix)
- Usuario: `giks`
- Roles activos: `desktop`, `dev`

## Comandos útiles

- Validar configuración: `nix flake check --no-build`
- Evaluar paquetes del sistema: `nix eval .#nixosConfigurations.aurora.config.environment.systemPackages`
- Aplicar cambios al sistema: `sudo nixos-rebuild switch --flake .#aurora`
- Actualizar dependencias del flake: `nix flake update`

## Actualización de herramientas de IA

Los paquetes de IA (`antigravity`, `claude`, `codex`, `herdr`, `pi`) se gestionan en:
`modules/hosts/aurora/applications/profiles/ai/packages/<herramienta>/`

Cada uno cuenta con su script `update.sh` que consulta upstream, descarga el binario o release oficial, calcula su hash SRI y actualiza su `default.nix` automáticamente:
```bash
./modules/hosts/aurora/applications/profiles/ai/packages/antigravity/update.sh
./modules/hosts/aurora/applications/profiles/ai/packages/claude/update.sh
./modules/hosts/aurora/applications/profiles/ai/packages/codex/update.sh
./modules/hosts/aurora/applications/profiles/ai/packages/herdr/update.sh
./modules/hosts/aurora/applications/profiles/ai/packages/pi/update.sh
```
