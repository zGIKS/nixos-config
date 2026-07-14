# giks dotfiles

Configuración personal de NixOS con `flakes` y Home Manager.

## Estructura

- `hosts/` define máquinas concretas, actualmente `gaia` y `aurora`
- `modules/nixos/` contiene módulos del sistema y perfiles (`core`, `desktop`, `dev`)
- `modules/home/` contiene módulos reutilizables de Home Manager
- `home/programs/` guarda archivos de configuración enlazados a `$XDG_CONFIG_HOME`
- `users/giks/home.nix` ensambla la configuración del usuario

## Host actual

- Hosts: `gaia`, `aurora`
- Usuario: `giks`
- Roles activos: `desktop`, `dev`

## Comandos útiles

- Validar: `nix --extra-experimental-features 'nix-command flakes' flake check --no-build`
- Actualizar dependencias: `nix flake update`
- Aplicar sistema: `sudo nixos-rebuild switch --flake .#gaia`
- Aplicar sistema: `sudo nixos-rebuild switch --flake .#aurora`
- Ver hostname actual: `hostname`

## Actualización por PC

- `gaia`: `sudo nixos-rebuild switch --flake .#gaia`
- `aurora`: `sudo nixos-rebuild switch --flake .#aurora`

Flujo típico para actualizar todo:

1. Ejecuta `nix flake update` para refrescar `flake.lock`.
2. Aplica la configuración en la PC correspondiente con `nixos-rebuild switch`.
3. Si cambiaste cosas del usuario, vuelve a iniciar sesión para que Home Manager recargue la sesión.

## Personalización rápida

- Cambia `hostName`, `username` y `roles` en `flake.nix`
- Añade paquetes base en `modules/nixos/profiles/core.nix`
- Añade paquetes de desarrollo en `modules/nixos/profiles/dev.nix`
- Añade programas de Home Manager en `modules/home/programs/`
