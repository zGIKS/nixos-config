-- UI Components - Dark Glass/Zinc Theme (Minimal)
return {
  -- Dark Glass Theme (coherent with Waybar/Alacritty)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true, -- Glass effect
      terminal_colors = true,
      styles = {
        comments = { italic = false }, -- Less visual noise
        keywords = { italic = false },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },
      sidebars = { "qf", "help", "neo-tree" },
      on_colors = function(colors)
        -- Zinc color palette to match Waybar/Alacritty exactly
        colors.bg = "#0a0a0c"          -- Same as Alacritty
        colors.bg_dark = "#0a0a0c"
        colors.bg_float = "#18181b"     -- Zinc-900
        colors.bg_sidebar = "#18181b"
        colors.fg = "#fafafa"           -- Same as Alacritty
        colors.fg_dark = "#a1a1aa"     -- Zinc-400
        colors.border = "#27272a"       -- Zinc-800
        colors.comment = "#71717a"      -- Zinc-500
        
        -- No blue accents - keep it zinc/gray
        colors.blue = "#71717a"         
        colors.cyan = "#a1a1aa"
        colors.purple = "#9ca3af"       
        colors.magenta = "#9ca3af"
        colors.teal = "#a1a1aa"
      end,
      on_highlights = function(hl, c)
        -- Glass effect for all floating windows
        hl.FloatBorder = { fg = c.border, bg = "NONE" }
        hl.NormalFloat = { bg = "NONE" }
        hl.TelescopeBorder = { fg = c.border, bg = "NONE" }
        hl.TelescopeNormal = { bg = "NONE" }
        
        -- Neo-tree glass effect
        hl.NeoTreeNormal = { bg = "NONE" }
        hl.NeoTreeNormalNC = { bg = "NONE" }
        
        -- Statusline transparency
        hl.StatusLine = { bg = "NONE" }
        hl.StatusLineNC = { bg = "NONE" }
        
        -- Clean selection
        hl.Visual = { bg = "#27272a" }  -- Same as Alacritty selection
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Minimal StatusLine
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "neo-tree" } },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            fmt = function(str) return str:sub(1,1) end, -- Single letter mode
          }
        },
        lualine_b = {},
        lualine_c = {
          {
            "filename",
            path = 1,
            symbols = { modified = "●", readonly = "", unnamed = "[No Name]" },
          },
        },
        lualine_x = {
          {
            "diagnostics",
            symbols = { error = "E", warn = "W", info = "I", hint = "H" }, -- Simple text
          },
        },
        lualine_y = {
          {
            "branch",
            icon = "",
          }
        },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_c = { "filename" },
        lualine_x = { "location" },
      },
    },
  },

  -- Minimal Which-Key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      delay = 500,
      spec = {
        { "<leader>c", group = "code" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>u", group = "ui" },
      },
      win = {
        border = "single",
        padding = { 1, 2 },
        wo = { winblend = 10 },
      },
    },
  },

  -- Essential Treesitter (your languages only)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        -- Your core languages
        "lua",
        "rust", 
        "go",
        "nix",
        "java",
        
        -- Essential formats
        "json",
        "yaml",
        "toml",
        
        -- Neovim essentials
        "vim",
        "vimdoc",
        "query",
      },
      highlight = { 
        enable = true,
        additional_vim_regex_highlighting = false, -- Performance
      },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.config").setup(opts)
    end,
  },

  -- Simple icons (no colors for zinc theme)
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    opts = {
      color_icons = false, -- Monochrome for zinc theme
      default = true,
    },
  },
}
