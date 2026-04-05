-- Neovim options - VS Code style
local opt = vim.opt

-- UI
opt.number = true                    -- Show line numbers
opt.relativenumber = true           -- Show relative line numbers
opt.cursorline = true               -- Highlight current line
opt.signcolumn = "yes"              -- Always show signcolumn
opt.colorcolumn = "80"              -- Show column at 80 chars
opt.wrap = false                    -- Disable line wrapping
opt.termguicolors = true            -- Enable 24-bit RGB colors
opt.pumheight = 10                  -- Popup menu height
opt.cmdheight = 1                   -- Command line height

-- Editor behavior
opt.mouse = "a"                     -- Enable mouse support
opt.clipboard = "unnamedplus"       -- Use system clipboard
opt.undofile = true                 -- Persistent undo
opt.swapfile = false                -- No swap files
opt.backup = false                  -- No backup files
opt.writebackup = false             -- No backup while editing
opt.updatetime = 300                -- Faster completion
opt.timeoutlen = 500                -- Wait time for key combinations
opt.splitright = true               -- Vertical splits to the right
opt.splitbelow = true               -- Horizontal splits below
opt.scrolloff = 8                   -- Keep 8 lines when scrolling
opt.sidescrolloff = 8               -- Keep 8 columns when scrolling

-- Search
opt.ignorecase = true               -- Ignore case in search
opt.smartcase = true                -- Smart case (respect case if uppercase used)
opt.hlsearch = true                 -- Highlight search results
opt.incsearch = true                -- Incremental search

-- Indentation (VS Code style)
opt.expandtab = true                -- Convert tabs to spaces
opt.shiftwidth = 2                  -- Indent with 2 spaces
opt.tabstop = 2                     -- Tab width is 2 spaces
opt.softtabstop = 2                 -- Soft tab width
opt.smartindent = true              -- Smart auto-indenting
opt.autoindent = true               -- Copy indent from current line

-- Folding
opt.foldcolumn = "0"                -- Hide fold column
opt.foldlevel = 99                  -- Don't fold by default
opt.foldlevelstart = 99             -- Don't fold when opening files
opt.foldenable = true               -- Enable folding

-- Performance
opt.lazyredraw = false              -- Don't redraw while executing macros
opt.synmaxcol = 240                 -- Max column for syntax highlight

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")           -- Don't show completion messages

-- Disable some default plugins for performance
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1