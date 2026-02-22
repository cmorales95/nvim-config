-- ============================================================
-- Filetype-specific plugins
-- Covers: Markdown, JSON/YAML schemas, HTTP, SQL, CSV
-- ============================================================
return {

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
    "rest-nvim/rest.nvim",
    ft           = { "http" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("rest-nvim").setup({
        result_split_horizontal = false,
        result_split_in_place   = false,
        stay_in_current_window_after_split = true,
        skip_ssl_verification   = false,
        highlight = { enabled = true, timeout = 150 },
        result = {
          show_url        = true,
          show_http_info  = true,
          show_headers    = true,
          formatters = {
            json = "jq",
            html = { cmd = { "tidy", "-i", "-q" } },
          },
        },
      })
      -- <leader>rr to run request under cursor
      vim.keymap.set("n", "<leader>rr", "<cmd>Rest run<cr>",      { desc = "Run HTTP request", ft = "http" })
      vim.keymap.set("n", "<leader>rl", "<cmd>Rest run last<cr>", { desc = "Re-run last HTTP request" })
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
