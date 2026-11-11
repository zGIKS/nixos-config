# Pi user configuration.
#
# The settings merge is adapted from the MIT-licensed pi.nix Home Manager
# module (Copyright (c) 2026 Lukas, https://github.com/lukasl-dev/pi.nix).
# See ./NOTICE. Only the settings.json merge is kept: that is the part this
# configuration actually uses. The package itself is installed by NixOS.
{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.pi;
  settingsPath = pkgs.writeText "pi-settings.json" (builtins.toJSON cfg.settings);
in
{
  options.myHome.pi = {
    enable = lib.mkEnableOption "Pi coding-agent user configuration";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Declarative fragment merged into ~/.pi/agent/settings.json on
        activation. Existing unmanaged keys are preserved; declared values win.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # settings.json stays a regular file. Pi rewrites it (theme, model,
    # changelog), so a home-manager symlink would be clobbered or made
    # immutable. jq deep-merges the declarative fragment over the live file.
    home.activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      dir="$HOME/.pi/agent"
      file="$dir/settings.json"
      if [ -L "$file" ]; then
        rm -f "$file"
      fi
      mkdir -p "$dir"
      tmp="$(mktemp "$dir/settings.json.XXXXXX")"
      if [ -f "$file" ]; then
        ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$file" ${lib.escapeShellArg settingsPath} > "$tmp"
      else
        printf '%s\n' '{}' | ${lib.getExe pkgs.jq} -s '.[0] * .[1]' - ${lib.escapeShellArg settingsPath} > "$tmp"
      fi
      chmod 600 "$tmp"
      if [ ! -f "$file" ] || ! cmp -s "$tmp" "$file"; then
        mv "$tmp" "$file"
      else
        rm -f "$tmp"
      fi
    '';
  };
}
