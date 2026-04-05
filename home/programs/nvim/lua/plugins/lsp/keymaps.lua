-- LSP Keymaps
local M = {}

function M.setup(opts)
  -- Setup keymaps when LSP attaches
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
      end

      -- Jump to the definition of the word under your cursor.
      map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

      -- Find references for the word under your cursor.
      map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

      -- Jump to the implementation of the word under your cursor.
      map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

      -- Jump to the type of the word under your cursor.
      map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

      -- Fuzzy find all the symbols in your current document.
      map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

      -- Fuzzy find all the symbols in your current workspace
      map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

      -- Rename the variable under your cursor
      map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

      -- Execute a code action, usually your cursor needs to be on top of an error
      map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

      -- Opens a popup that displays documentation about the word under your cursor
      map("K", vim.lsp.buf.hover, "Hover Documentation")

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client.server_capabilities.documentHighlightProvider then
        local highlight_augroup = vim.api.nvim_create_augroup("lsp_highlight", { clear = false })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd("LspDetach", {
          group = vim.api.nvim_create_augroup("lsp_detach", { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = "lsp_highlight", buffer = event2.buf })
          end,
        })
      end

      -- The following autocommand is used to enable inlay hints in your
      -- code, if the language server you are using supports them
      if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
        map("<leader>th", function()
          local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
          vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
        end, "[T]oggle Inlay [H]ints")
      end
    end,
  })
end

return M
