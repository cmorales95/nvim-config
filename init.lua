-- ============================================================
-- Bootstrap lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- Leader key (must be before plugins)
-- ============================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================
-- Options
-- ============================================================
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.clipboard      = "unnamedplus"  -- sync with system clipboard
vim.opt.expandtab      = true
vim.opt.shiftwidth     = 2
vim.opt.tabstop        = 2
vim.opt.smartindent    = true
vim.opt.wrap           = false
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.termguicolors  = true
vim.opt.signcolumn     = "yes"
vim.opt.updatetime     = 250
vim.opt.scrolloff      = 8
vim.opt.cursorline     = true

-- ============================================================
-- Keymaps
-- ============================================================
local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })

-- Indenting in visual mode
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Misc
map("n", "<Esc>", "<cmd>nohlsearch<cr>",   { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>w<cr>",         { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>",         { desc = "Quit" })

-- Claude Code in a vertical terminal split
map("n", "<leader>cc", function()
  vim.cmd("vsplit")
  vim.cmd("terminal claude")
  vim.cmd("startinsert")
end, { desc = "Open Claude Code" })

-- DAP (debugger) keymaps
map("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", { desc = "Toggle breakpoint" })
map("n", "<leader>dc", "<cmd>lua require('dap').continue()<cr>",          { desc = "Continue" })
map("n", "<leader>di", "<cmd>lua require('dap').step_into()<cr>",         { desc = "Step into" })
map("n", "<leader>do", "<cmd>lua require('dap').step_over()<cr>",         { desc = "Step over" })
map("n", "<leader>dO", "<cmd>lua require('dap').step_out()<cr>",          { desc = "Step out" })
map("n", "<leader>dt", "<cmd>lua require('dap').terminate()<cr>",         { desc = "Terminate" })
map("n", "<leader>du", "<cmd>lua require('dapui').toggle()<cr>",          { desc = "Toggle DAP UI" })

-- ============================================================
-- Plugins
-- ============================================================
require("lazy").setup({

  -- ----------------------------------------------------------
  -- UI
  -- ----------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight-night")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = { options = { theme = "tokyonight" } },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- ----------------------------------------------------------
  -- Editor
  -- ----------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>s", function() require("flash").jump() end, desc = "Flash Jump" },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help Tags" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- ----------------------------------------------------------
  -- LSP (Language Server Protocol)
  -- ----------------------------------------------------------
  {
    "williamboman/mason.nvim",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "gopls", "pyright" },
      automatic_installation = true,
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Go
      lspconfig.gopls.setup({ capabilities = capabilities })

      -- Python
      lspconfig.pyright.setup({ capabilities = capabilities })

      -- LSP keymaps (only active when LSP is attached to buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          map("n", "gd",         vim.lsp.buf.definition,     vim.tbl_extend("force", opts, { desc = "Go to definition" }))
          map("n", "gr",         vim.lsp.buf.references,     vim.tbl_extend("force", opts, { desc = "References" }))
          map("n", "K",          vim.lsp.buf.hover,          vim.tbl_extend("force", opts, { desc = "Hover docs" }))
          map("n", "<leader>rn", vim.lsp.buf.rename,         vim.tbl_extend("force", opts, { desc = "Rename" }))
          map("n", "<leader>ca", vim.lsp.buf.code_action,    vim.tbl_extend("force", opts, { desc = "Code action" }))
          map("n", "[d",         vim.diagnostic.goto_prev,   vim.tbl_extend("force", opts, { desc = "Prev diagnostic" }))
          map("n", "]d",         vim.diagnostic.goto_next,   vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        end,
      })
    end,
  },

  -- ----------------------------------------------------------
  -- Completion
  -- ----------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- ----------------------------------------------------------
  -- Debugging (Go)
  -- ----------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
  },

  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      -- Auto open/close UI when debugging starts/ends
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end
    end,
  },

})
