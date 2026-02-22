-- ============================================================
-- Editor plugins
-- Covers: motion, telescope, git, autopairs, terminal,
--         diagnostics panel, format on save
-- ============================================================
return {

  -- Flash jump motion
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys  = {
      { "<leader>s", function() require("flash").jump() end, desc = "Flash Jump" },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd  = "Telescope",
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config   = { preview_width = 0.55 },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },

  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts  = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
      },
    },
  },

  -- Auto-close pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = {},
  },

  -- Persistent terminal + Claude Code + lazygit
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", desc = "Toggle terminal" },
      { "<leader>cc", desc = "Toggle Claude Code" },
      { "<leader>lg", desc = "Toggle lazygit" },
    },
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
          return 20
        end,
        open_mapping    = nil,  -- we set our own below
        hide_numbers    = true,
        shade_terminals = false,
        start_in_insert = true,
        direction       = "float",
        float_opts      = {
          border   = "curved",
          winblend = 3,
        },
      })

      local Terminal = require("toggleterm.terminal").Terminal

      -- Generic floating terminal
      local float_term = Terminal:new({ direction = "float", hidden = true })

      -- Claude Code — persistent vertical split so context is preserved
      local claude = Terminal:new({
        cmd          = "claude",
        direction    = "vertical",
        hidden       = true,
        display_name = "Claude Code",
        on_open = function(term)
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true })
        end,
      })

      -- lazygit
      local lazygit = Terminal:new({
        cmd          = "lazygit",
        direction    = "float",
        hidden       = true,
        display_name = "lazygit",
        float_opts   = { border = "double" },
      })

      vim.keymap.set("n", "<leader>tt", function() float_term:toggle() end,  { desc = "Toggle terminal" })
      vim.keymap.set("n", "<leader>cc", function() claude:toggle() end,       { desc = "Toggle Claude Code" })
      vim.keymap.set("n", "<leader>lg", function() lazygit:toggle() end,      { desc = "Toggle lazygit" })

      -- Allow Esc to exit terminal mode back to normal
      vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    end,
  },

  -- Diagnostics panel (VSCode Problems)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd  = "Trouble",
    opts = {
      modes = {
        diagnostics = {
          auto_open   = false,
          auto_close  = true,
        },
      },
    },
  },

  -- Session management — auto save/restore per working directory
  {
    "rmagatti/auto-session",
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("auto-session").setup({
        auto_save_enabled    = true,
        auto_restore_enabled = true,
        -- Don't restore when opening a specific file (only bare `nvim`)
        auto_restore_lazy_delay_enabled = false,
        bypass_save_filetypes = { "alpha" },
        -- Close neo-tree before saving so it restores cleanly
        pre_save_cmds  = { "Neotree close" },
        post_restore_cmds = { "Neotree show" },
      })
    end,
  },

  -- Format on save
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts  = {
      formatters_by_ft = {
        go         = { "goimports", "gofmt" },
        python     = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json       = { "prettier" },
        yaml       = { "prettier" },
        markdown   = { "prettier" },
        r          = { "formatR" },
        lua        = { "stylua" },
      },
      format_on_save = {
        timeout_ms   = 1000,
        lsp_fallback = true,
      },
    },
  },

}
