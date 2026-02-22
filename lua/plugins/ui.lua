-- ============================================================
-- UI plugins
-- Covers: colorscheme, statusline, which-key, bufferline,
--         file explorer, indent guides, color previews
-- ============================================================
return {

  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy     = false,
    priority = 1000,
    opts     = { style = "night" },
    config   = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight-night")
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme            = "tokyonight",
        globalstatus     = true,
        section_separators   = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      preset = "modern",
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      -- Group labels
      wk.add({
        { "<leader>f",  group = "Find (telescope)" },
        { "<leader>d",  group = "Debug" },
        { "<leader>m",  group = "Molten (Jupyter)" },
        { "<leader>t",  group = "Terminal" },
      })
    end,
  },

  -- Buffer tabs
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event        = "VeryLazy",
    opts = {
      options = {
        mode             = "buffers",
        diagnostics      = "nvim_lsp",
        separator_style  = "slant",
        show_buffer_close_icons = true,
        show_close_icon         = false,
        always_show_bufferline  = false,
      },
    },
  },

  -- File explorer sidebar
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch       = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd  = "Neotree",
    opts = {
      window = {
        width    = 35,
        position = "left",
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles   = false,
          hide_gitignored = false,
        },
        follow_current_file = { enabled = true },
      },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = "BufReadPost",
    opts  = {
      indent = { char = "│" },
      scope  = { enabled = true },
    },
  },

  -- Inline color previews (#rgb, css colors, etc.)
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufReadPost",
    config = function()
      require("colorizer").setup({ "*" }, {
        RGB      = true,
        RRGGBB   = true,
        names    = false,
        css      = true,
      })
    end,
  },

}
