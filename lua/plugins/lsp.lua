-- ============================================================
-- LSP + Completion  (Neovim 0.11 native API)
-- Languages: Go, Python, JavaScript/TypeScript, R, Lua
-- ============================================================
return {

  -- Mason: LSP/tool installer
  {
    "williamboman/mason.nvim",
    cmd  = "Mason",
    opts = {
      ui = {
        border = "rounded",
        icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  -- mason-lspconfig: auto-install servers and call vim.lsp.enable() for each
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "gopls",             -- Go
        "pyright",           -- Python
        "ts_ls",             -- JS / TS
        "r_language_server", -- R
        "lua_ls",            -- Lua (for editing this config)
      },
      automatic_installation = true,
    },
  },

  -- nvim-lspconfig: provides server definitions (cmd, filetypes, root_dir)
  -- We no longer call lspconfig.server.setup() — we use vim.lsp.config() instead
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Global defaults applied to every server
      vim.lsp.config("*", { capabilities = capabilities })

      -- Per-server settings
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt     = true,
            analyses    = { unusedparams = true },
            staticcheck = true,
          },
        },
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths  = true,
            },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime  = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library          = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = { globals = { "vim" } },
            telemetry   = { enable = false },
          },
        },
      })

      -- LSP keymaps — attached only when LSP is active on the buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group    = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(event)
          local opts = { buffer = event.buf }
          local map  = vim.keymap.set
          map("n", "gd",         vim.lsp.buf.definition,     vim.tbl_extend("force", opts, { desc = "Go to definition" }))
          map("n", "gD",         vim.lsp.buf.declaration,    vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
          map("n", "gr",         vim.lsp.buf.references,     vim.tbl_extend("force", opts, { desc = "References" }))
          map("n", "gi",         vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
          map("n", "K",          vim.lsp.buf.hover,          vim.tbl_extend("force", opts, { desc = "Hover docs" }))
          map("n", "<leader>rn", vim.lsp.buf.rename,         vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
          map("n", "<leader>ca", vim.lsp.buf.code_action,    vim.tbl_extend("force", opts, { desc = "Code action" }))
          map("n", "[d",         vim.diagnostic.goto_prev,   vim.tbl_extend("force", opts, { desc = "Prev diagnostic" }))
          map("n", "]d",         vim.diagnostic.goto_next,   vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        end,
      })

      -- Diagnostic display
      vim.diagnostic.config({
        virtual_text     = { prefix = "●" },
        signs            = true,
        underline        = true,
        update_in_insert = false,
        severity_sort    = true,
        float            = { border = "rounded", source = "always" },
      })
    end,
  },

  -- Completion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750  },
          { name = "buffer",   priority = 500  },
          { name = "path",     priority = 250  },
        }),
      })
    end,
  },

}
