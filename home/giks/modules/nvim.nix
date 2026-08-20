{ config, lib, nixvim, ... }:

with lib;

let
  cfg = config.myHome.nvim;
in
{
  imports = [ nixvim.homeModules.nixvim ];

  options.myHome.nvim = {
    enable = mkEnableOption "Enable a minimal Neovim configuration";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    programs.nixvim = {
      enable = true;
      # We intentionally follow nixpkgs (see flake.nix); the resulting
      # version-mismatch warning against nixvim's own pin is expected.
      version.enableNixpkgsReleaseCheck = false;

      # LSP servers come from the system profile
      # (modules/hosts/shared/applications/profiles/development/languages/lsp.nix).
      # Home Manager must not install packages, so nixvim is told to reuse
      # whatever is already on $PATH instead of pulling its own copies.

      globals = {
        mapleader = " ";
        maplocalleader = " ";
        loaded_gzip = 1;
        loaded_zip = 1;
        loaded_zipPlugin = 1;
        loaded_tar = 1;
        loaded_tarPlugin = 1;
        loaded_getscript = 1;
        loaded_getscriptPlugin = 1;
        loaded_vimball = 1;
        loaded_vimballPlugin = 1;
        loaded_2html_plugin = 1;
        loaded_logiPat = 1;
        loaded_rrhelper = 1;
        loaded_netrw = 1;
        loaded_netrwPlugin = 1;
        loaded_netrwSettings = 1;
      };

      opts = {
        number = true;
        relativenumber = true;
        signcolumn = "yes";
        termguicolors = true;

        mouse = "a";
        clipboard = "unnamedplus";
        undofile = true;
        swapfile = false;

        ignorecase = true;
        smartcase = true;

        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        smartindent = true;
      };

      colorschemes.tokyonight = {
        enable = true;
        settings.style = "night";
      };

      plugins = {
        web-devicons.enable = true;

        neo-tree = {
          enable = true;
          settings = {
            window.position = "left";
            filesystem = {
              hijack_netrw_behavior = "open_current";
              filtered_items = {
                hide_dotfiles = false;
                hide_gitignored = false;
              };
            };
          };
        };

        treesitter = {
          enable = true;
          settings = {
            ensure_installed = [
              "lua"
              "rust"
              "go"
              "nix"
              "java"
              "json"
              "yaml"
              "toml"
              "vim"
              "vimdoc"
              "query"
            ];
            highlight.enable = true;
            indent.enable = true;
          };
        };

        # LSP servers themselves are installed system-wide (shared dev profile);
        # `package = null` tells nixvim to use the binary already on $PATH
        # instead of pulling in another copy through Home Manager.
        # No custom keymaps: Neovim 0.11+ ships default LSP mappings
        # (grn, gra, grr, gri, K, ...) out of the box.
        lsp = {
          enable = true;
          servers = {
            lua_ls.enable = true;
            lua_ls.package = null;
            ts_ls.enable = true;
            ts_ls.package = null;
            html.enable = true;
            html.package = null;
            cssls.enable = true;
            cssls.package = null;
            jsonls.enable = true;
            jsonls.package = null;
            yamlls.enable = true;
            yamlls.package = null;
            bashls.enable = true;
            bashls.package = null;
            eslint.enable = true;
            eslint.package = null;
            pyright.enable = true;
            pyright.package = null;
            rust_analyzer.enable = true;
            rust_analyzer.package = null;
            rust_analyzer.installCargo = false;
            rust_analyzer.installRustc = false;
            nil_ls.enable = true;
            nil_ls.package = null;
          };
        };
      };
    };
  };
}
