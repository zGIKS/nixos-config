# giks dotfiles

Configuración personal de NixOS con `flakes` y Home Manager.

## Estructura

- `hosts/` define máquinas concretas, actualmente `gramnyx`
- `modules/nixos/` contiene módulos del sistema y perfiles (`core`, `desktop`, `dev`)
- `modules/home/` contiene módulos reutilizables de Home Manager
- `home/programs/` guarda archivos de configuración enlazados a `$XDG_CONFIG_HOME`
- `users/giks/home.nix` ensambla la configuración del usuario

## Host actual

- Host: `gramnyx`
- Usuario: `giks`
- Roles activos: `desktop`, `dev`

## Comandos útiles

- Validar: `nix --extra-experimental-features 'nix-command flakes' flake check --no-build`
- Aplicar sistema: `sudo nixos-rebuild switch --flake .#gramnyx`
- Ver hostname actual: `hostname`

## Personalización rápida

- Cambia `hostName`, `username` y `roles` en `flake.nix`
- Añade paquetes base en `modules/nixos/profiles/core.nix`
- Añade paquetes de desarrollo en `modules/nixos/profiles/dev.nix`
- Añade programas de Home Manager en `modules/home/programs/`
