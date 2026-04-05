-- Neovim minimal config - VS Code style
-- Leader key must be set before lazy loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load configuration modules
require("config.options")
require("config.keymaps")
require("config.lazy")