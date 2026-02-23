-- ============================================================
-- Filetype-specific plugins
-- Covers: Markdown, JSON/YAML schemas, HTTP, SQL, CSV
-- ============================================================
return {

  -- Inline markdown rendering (headings, code blocks, tables, checkboxes)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft           = { "markdown", "python" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      file_types = { "markdown", "python" },
      heading = {
        sign    = false,
        icons   = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        sign        = false,
        width       = "block",
        right_pad   = 1,
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked   = { icon = "󰱒 " },
      },
    },
  },

  -- Markdown live preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd   = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft    = { "markdown" },
    build = "cd app && npm install",
    config = function()
      vim.g.mkdp_auto_close    = 1   -- close preview when leaving md buffer
      vim.g.mkdp_browser       = ""  -- use system default browser
      vim.g.mkdp_theme         = "dark"
    end,
  },

  -- JSON & YAML schema validation (package.json, tsconfig, docker-compose, etc.)
  {
    "b0o/SchemaStore.nvim",
    lazy = true,  -- loaded on demand by lspconfig
    config = function()
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas  = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas     = require("schemastore").yaml.schemas(),
          },
        },
      })
    end,
  },

  -- HTTP REST client — run .http files like VSCode REST Client
  {
    "mistweaverco/kulala.nvim",
    ft = { "http" },
    opts = {
      split_direction = "vertical",
      default_view = "body",
    },
    config = function(_, opts)
      require("kulala").setup(opts)
      -- <leader>rr to run request under cursor
      vim.keymap.set("n", "<leader>rr", function() require("kulala").run() end, { desc = "Run HTTP request" })
      vim.keymap.set("n", "<leader>rl", function() require("kulala").replay() end, { desc = "Re-run last HTTP request" })
      vim.keymap.set("n", "<leader>ri", function() require("kulala").inspect() end, { desc = "Inspect HTTP request" })
      vim.keymap.set("n", "[r", function() require("kulala").jump_prev() end, { desc = "Prev HTTP request" })
      vim.keymap.set("n", "]r", function() require("kulala").jump_next() end, { desc = "Next HTTP request" })
    end,
  },

  -- SQL database UI (like VSCode database extensions)
  {
    "tpope/vim-dadbod",
    cmd  = "DB",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd  = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location  = vim.fn.stdpath("data") .. "/db_ui"
    end,
  },
  -- SQL completion in dadbod buffers
  {
    "kristijanhusak/vim-dadbod-completion",
    ft   = { "sql", "mysql", "plsql" },
    lazy = true,
  },

  -- CSV column colors (already in editor.lua as rainbow_csv — kept here for reference)
  -- Filetype detection for common data files
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "sql", "toml", "graphql", "dockerfile",
      })
    end,
  },

}
