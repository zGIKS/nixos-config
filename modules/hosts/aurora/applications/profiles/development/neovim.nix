{ config, lib, pkgs, roles, ... }:

let
  cfg = config.myModules.profiles.development;
in
{
  options.myModules.profiles.development.neovim.enable =
    lib.mkEnableOption "Neovim and the plugins its user configuration loads" // {
      default = lib.elem "dev" roles;
    };

  config = lib.mkIf (cfg.enable && cfg.neovim.enable) {
    # Plugins and grammars are referenced from the Home Manager init.lua, which
    # prepends them to Neovim's packpath. The package stays here so the user
    # configuration never installs it. Providers stay off, matching the wrapper
    # Nixvim produced for this configuration.
    environment.systemPackages = [
      (pkgs.neovim.override {
        withNodeJs = false;
        withPerl = false;
        withPython3 = false;
        withRuby = false;
      })
    ];

  };
}
