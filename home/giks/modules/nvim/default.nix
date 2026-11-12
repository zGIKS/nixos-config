# Neovim user configuration, installed as ~/.config/nvim/init.lua.
#
# The editor package and its plugins are installed by the NixOS neovim profile.
# This module only owns options, key behavior, and the generated init file.
{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.nvim;

  grammars = with pkgs.vimPlugins.nvim-treesitter-parsers; [
    lua
    rust
    go
    nix
    java
    json
    yaml
    toml
    vim
    vimdoc
    query
  ];

  plugins = with pkgs.vimPlugins; [
    tokyonight-nvim
    nvim-web-devicons
    nvim-treesitter
    plenary-nvim
    nui-nvim
    neo-tree-nvim
  ];

  packDir = pkgs.linkFarm "nvim-pack" (
    lib.imap0 (index: plugin: {
      name = "pack/nix/start/${lib.fixedWidthNumber 4 index}-${plugin.pname or plugin.name}";
      path = plugin;
    }) (plugins ++ grammars)
  );

  initLua = pkgs.writeText "init.lua" ''
    -- Nixvim's internal module table
    -- Can be used to share code throughout init.lua
    local _M = {}

    -- Set up globals {{{
    do
      local globals = {
        loaded_2html_plugin = 1,
        loaded_getscript = 1,
        loaded_getscriptPlugin = 1,
        loaded_gzip = 1,
        loaded_logiPat = 1,
        loaded_netrw = 1,
        loaded_netrwPlugin = 1,
        loaded_netrwSettings = 1,
        loaded_rrhelper = 1,
        loaded_tar = 1,
        loaded_tarPlugin = 1,
        loaded_vimball = 1,
        loaded_vimballPlugin = 1,
        loaded_zip = 1,
        loaded_zipPlugin = 1,
        mapleader = " ",
        maplocalleader = " ",
      }

      for key, value in pairs(globals) do
        vim.g[key] = value
      end
    end
    -- }}}

    -- Set up options {{{
    do
      local options = {
        autoread = true,
        clipboard = "unnamedplus",
        expandtab = true,
        ignorecase = true,
        mouse = "a",
        number = true,
        relativenumber = true,
        shiftwidth = 2,
        signcolumn = "yes",
        smartcase = true,
        smartindent = true,
        swapfile = false,
        tabstop = 2,
        termguicolors = true,
        undofile = true,
      }

      for key, value in pairs(options) do
        vim.opt[key] = value
      end
    end
    -- }}}

    vim.opt.packpath:prepend("${packDir}")
    vim.opt.runtimepath:prepend("${packDir}")

    require("tokyonight").setup({ style = "night" })
    vim.cmd.colorscheme("tokyonight")
    require("nvim-web-devicons").setup({})

    -- Grammars are installed through Nix, so treesitter never compiles them.
    require("nvim-treesitter").setup({
      highlight = { enable = true },
      indent = { enable = true },
    })

    do
      local augroup = vim.api.nvim_create_augroup("nix_treesitter", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "*",
        callback = function(args)
          local buf = args.buf
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
          if not lang or not vim.treesitter.language.add(lang) then
            return
          end

          local function undo(command)
            vim.b[buf].undo_ftplugin = (vim.b[buf].undo_ftplugin and vim.b[buf].undo_ftplugin .. " | " or "") .. command
          end

          if vim.treesitter.query.get(lang, "highlights") then
            vim.treesitter.start(buf, lang)
            undo(("call v:lua.vim.treesitter.stop(%d)"):format(buf))
          end

          if vim.treesitter.query.get(lang, "indents") then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            undo("setlocal indentexpr<")
          end
        end,
      })
    end

    require("neo-tree").setup({
      filesystem = {
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
        hijack_netrw_behavior = "open_current",
      },
      window = { position = "left" },
    })

    -- LSP servers are installed system-wide and resolved from $PATH.
    -- Neovim 0.11+ provides the default LSP keymaps.
    do
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local function configure(name, extra)
        vim.lsp.config(name, vim.tbl_extend("keep", extra or {}, { capabilities = capabilities }))
        vim.lsp.enable(name)
      end

      configure("bashls")
      configure("cssls")
      configure("eslint")
      configure("html")
      configure("jsonls")
      configure("lua_ls")
      configure("nil_ls")
      configure("pyright")
      configure("rust_analyzer")
      configure("ts_ls", {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
      })
      configure("yamlls")
    end

    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
      pattern = "*",
      command = "checktime",
    })
  '';
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # The init file is the whole configuration. Plugins live in the Nix store
    # and are prepended to the runtime path, so no plugin manager runs.
    xdg.configFile."nvim/init.lua".source = initLua;
  };
}
