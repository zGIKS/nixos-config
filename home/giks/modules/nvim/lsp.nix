{ config, lib, ... }:

{
  config = lib.mkIf config.myHome.nvim.enable {
    programs.nixvim.plugins.lsp = {
      enable = true;
      # LSP servers are installed system-wide. package = null reuses $PATH.
      # Neovim 0.11+ provides the default LSP keymaps.
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
}
