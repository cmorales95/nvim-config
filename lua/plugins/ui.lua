-- ============================================================
-- UI plugins
-- Covers: colorscheme, statusline, which-key, bufferline,
--         file explorer, indent guides, color previews,
--         noice, fidget, dressing, rainbow-delimiters
-- ============================================================
return {

  -- Icons (used by neo-tree, bufferline, lualine, telescope, alpha)
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    opts = { default = true },
  },

  -- Colorscheme: Catppuccin Mocha
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    lazy     = false,
    priority = 1000,
    config   = function()
      require("catppuccin").setup({
        flavour = "mocha",
        integrations = {
          treesitter       = true,
          telescope        = { enabled = true },
          which_key        = true,
          bufferline       = true,
          neotree          = true,
          gitsigns         = true,
          indent_blankline = { enabled = true },
          trouble          = true,
          alpha            = true,
          mason            = true,
          noice            = true,
          dap              = true,
          dap_ui           = true,
          rainbow_delimiters = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors      = { "italic" },
              hints       = { "italic" },
              warnings    = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors      = { "underline" },
              hints       = { "underline" },
              warnings    = { "underline" },
              information = { "underline" },
            },
          },
        },
      })
      vim.cmd("colorscheme catppuccin-mocha")
    end,
  },

  -- Noice: VSCode-like command line, notifications, search counter
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                = true,
          ["cmp.entry.get_documentation"]                  = true,
        },
      },
      presets = {
        bottom_search         = true,   -- search bar at the bottom
        command_palette       = true,   -- command palette style cmdline
        long_message_to_split = true,   -- long messages go to a split
        inc_rename            = true,   -- rename UI
        lsp_doc_border        = true,   -- border on hover docs
      },
    },
  },

  -- Fidget: LSP progress spinner (bottom-right corner)
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts  = {
      notification = {
        window = { winblend = 0 },
      },
    },
  },

  -- Dressing: better UI for rename prompts, code actions, input boxes
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts  = {
      input  = { enabled = true },
      select = { enabled = true, backend = { "telescope", "builtin" } },
    },
  },

  -- Rainbow delimiters: color-coded nested brackets
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      require("rainbow-delimiters.setup").setup({
        strategy = { [""] = require("rainbow-delimiters").strategy["global"] },
        query    = { [""] = "rainbow-delimiters", lua = "rainbow-blocks" },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme            = "catppuccin",
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
    opts  = { preset = "modern" },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f", group = "Find (telescope)" },
        { "<leader>d", group = "Debug" },
        { "<leader>m", group = "Molten (Jupyter)" },
        { "<leader>t", group = "Terminal" },
        { "<leader>g", group = "Git" },
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
        mode                    = "buffers",
        diagnostics             = "nvim_lsp",
        separator_style         = "slant",
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
        position = "right",
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

  -- Dashboard (VSCode-like start screen)
  {
    "goolord/alpha-nvim",
    lazy         = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha     = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                       ",
        "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                       ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",     "<cmd>Telescope find_files<cr>"),
        dashboard.button("r", "  Recent files",  "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("g", "  Live grep",     "<cmd>Telescope live_grep<cr>"),
        dashboard.button("n", "  New file",      "<cmd>ene <BAR> startinsert<cr>"),
        dashboard.button("q", "  Quit",          "<cmd>qa<cr>"),
      }

      dashboard.section.footer.val = "No shortcuts. Just flow."
      dashboard.section.footer.opts.hl = "Comment"

      alpha.setup(dashboard.config)

      vim.api.nvim_create_autocmd("User", {
        pattern  = "AlphaReady",
        callback = function()
          vim.defer_fn(function()
            vim.cmd("Neotree show")
            vim.cmd("wincmd l")
          end, 50)
        end,
      })
    end,
  },

  -- Aerial: symbols outline panel (like VSCode's Outline view)
  {
    "stevearc/aerial.nvim",
    event        = "LspAttach",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      layout = { default_direction = "right", min_width = 30 },
      attach_mode = "global",
      show_guides = true,
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
        RGB    = true,
        RRGGBB = true,
        names  = false,
        css    = true,
      })
    end,
  },

}
