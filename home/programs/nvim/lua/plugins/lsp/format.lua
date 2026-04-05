-- LSP Formatting
local M = {}

function M.setup(opts)
  -- Setup formatting
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_format", { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      
      -- Format on save if client supports formatting
      if client and client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = event.buf,
          callback = function()
            vim.lsp.buf.format({
              bufnr = event.buf,
              timeout_ms = opts.format.timeout_ms,
              formatting_options = opts.format.formatting_options,
            })
          end,
        })
      end
    end,
  })
  
  -- Manual format keymap
  vim.keymap.set({ "n", "v" }, "<leader>cf", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format Document" })
end

return M