-- ============================================================
-- Editor plugins
-- Covers: motion, telescope, git, autopairs, terminal,
--         diagnostics, format, session, lint,
--         todo-comments, mini.ai, mini.surround, diffview,
--         claudecode
-- ============================================================
return {

  -- Claude Code: AI coding assistant integration
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude focus" },
      { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Claude resume" },
      { "<leader>cR", "<cmd>ClaudeCode --continue<cr>", desc = "Claude continue" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude send selection" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude add buffer" },
      { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude accept diff" },
      { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude deny diff" },
    },
    opts = {
      terminal = {
        split_side = "left",
        split_width_percentage = 0.40,
      },
    },
  },

  -- Flash jump motion
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys  = {
      { "<leader>s", function() require("flash").jump() end, desc = "Flash Jump" },
    },
  },

  -- Fuzzy finder + fzf native sorter for speed
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    cmd  = "Telescope",
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy  = "horizontal",
          layout_config    = {
            horizontal = { preview_width = 0.55 },
          },
          sorting_strategy = "ascending",
          winblend         = 0,
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("session-lens")
    end,
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

  -- Git diff viewer
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd  = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    opts = {},
  },

  -- Auto-close pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = {},
  },

  -- Persistent terminal + lazygit (Claude Code now handled by claudecode.nvim)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", desc = "Toggle terminal" },
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
        open_mapping    = nil,
        hide_numbers    = true,
        shade_terminals = false,
        start_in_insert = true,
        direction       = "float",
        float_opts      = { border = "curved", winblend = 3 },
      })

      local Terminal = require("toggleterm.terminal").Terminal

      local function venv_activate_cmd()
        local venv = vim.fn.finddir(".venv", vim.fn.getcwd() .. ";")
        if venv ~= "" then
          return "source " .. vim.fn.fnamemodify(venv, ":p") .. "bin/activate\n"
        end
      end

      local float_term = Terminal:new({
        direction = "float",
        hidden    = true,
        on_open   = function(term)
          local cmd = venv_activate_cmd()
          if cmd then vim.api.nvim_chan_send(term.job_id, cmd) end
        end,
      })
      local lazygit = Terminal:new({
        cmd          = "lazygit",
        direction    = "float",
        hidden       = true,
        display_name = "lazygit",
        float_opts   = { border = "double" },
      })

      vim.keymap.set("n", "<leader>tt", function() float_term:toggle() end, { desc = "Toggle terminal" })
      vim.keymap.set("n", "<leader>lg", function() lazygit:toggle() end,     { desc = "Toggle lazygit" })
      vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>",                       { desc = "Exit terminal mode" })
    end,
  },

  -- Diagnostics panel (VSCode Problems)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd  = "Trouble",
    opts = {
      modes = {
        diagnostics = { auto_open = false, auto_close = true },
      },
    },
  },

  -- TODO/FIXME/HACK/NOTE highlight and search
  {
    "folke/todo-comments.nvim",
    event        = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts         = {},
  },

  -- Session management — auto save/restore per working directory
  {
    "rmagatti/auto-session",
    lazy         = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("auto-session").setup({
        auto_save_enabled               = true,
        auto_restore_enabled            = true,
        auto_restore_lazy_delay_enabled = false,
        bypass_save_filetypes           = { "alpha" },
        pre_save_cmds = {
          "Neotree close",
        },
        post_restore_cmds = {
          -- Re-read .ipynb buffers after session restore so the full
          -- jupytext → FileType → render-markdown chain runs cleanly.
          -- Skip MoltenImportOutput (temp image files from the previous
          -- session are gone and would cause image.nvim errors).
          function()
            vim.g._molten_skip_import = true
            vim.defer_fn(function()
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf)
                  and vim.api.nvim_buf_get_name(buf):match("%.ipynb$") then
                  vim.api.nvim_buf_call(buf, function()
                    pcall(vim.cmd, "edit")
                  end)
                end
              end
              -- Clear the flag once all re-edits and their MoltenInitPost
              -- handlers have had time to fire.
              vim.defer_fn(function() vim.g._molten_skip_import = nil end, 5000)
            end, 500)
          end,
        },
      })
    end,
  },

  -- Harpoon: pin files and jump between them instantly
  {
    "ThePrimeagen/harpoon",
    branch       = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end,                                        { desc = "Harpoon: add file" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,               { desc = "Harpoon: menu" })
      vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end,                                   { desc = "Harpoon: file 1" })
      vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end,                                   { desc = "Harpoon: file 2" })
      vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end,                                   { desc = "Harpoon: file 3" })
      vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end,                                   { desc = "Harpoon: file 4" })
    end,
  },

  -- Rainbow CSV: color-coded columns, CSV queries
  {
    "mechatroner/rainbow_csv",
    ft = { "csv", "tsv", "csv_semicolon", "csv_whitespace", "csv_pipe", "rfc_csv", "rfc_semicolon" },
  },

  -- mini.ai: smarter text objects (va), viq, daA, etc.)
  {
    "echasnovski/mini.ai",
    version = "*",
    event   = "VeryLazy",
    opts    = { n_lines = 500 },
  },

  -- mini.surround: add/change/delete surrounding chars
  {
    "echasnovski/mini.surround",
    version = "*",
    event   = "VeryLazy",
    opts = {
      mappings = {
        add            = "gsa",
        delete         = "gsd",
        find           = "gsf",
        find_left      = "gsF",
        highlight      = "gsh",
        replace        = "gsr",
        update_n_lines = "gsn",
      },
    },
  },

  -- Async linter (separate from formatter)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        go         = { "golangcilint" },
        python     = { "ruff" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }
      -- Run linter on save and when entering a buffer
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- Test runner (Go)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "fredrikaverpil/neotest-golang",
    },
    ft = "go",
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang"),
        },
      })
    end,
  },

  -- Format on save
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts  = {
      formatters_by_ft = {
        go              = { "goimports", "gofmt" },
        python          = { "isort", "black" },
        javascript      = { "prettier" },
        typescript      = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json            = { "prettier" },
        yaml            = { "prettier" },
        markdown        = { "prettier" },
        r               = { "formatR" },
        lua             = { "stylua" },
      },
      format_on_save = { timeout_ms = 1000, lsp_fallback = true },
    },
  },

}
