-- ============================================================
-- Debugging (DAP)
-- Languages: Go (delve), Python (debugpy)
-- launch.json: drop a .vscode/launch.json in your project —
--              it will be loaded automatically on debug start
-- ============================================================
return {

  -- Core DAP
  {
    "mfussenegger/nvim-dap",
    lazy = true,
  },

  -- Persist breakpoints across sessions
  {
    "Weissle/persistent-breakpoints.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      save_dir = vim.fn.stdpath("data") .. "/breakpoints",
      load_breakpoints_event = { "BufReadPost" },
    },
  },

  -- Inline variable values while stepping (like VSCode inline values)
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    opts = {
      enabled                = true,
      enabled_commands       = true,
      highlight_changed_variables = true,
      highlight_new_as_changed    = true,
      show_stop_reason       = true,
      commented              = false,
      virt_text_pos          = "eol",   -- show at end of line
    },
  },

  -- DAP UI (Variables, Call Stack, Breakpoints, Console panels)
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.25 },
            },
            size     = 40,
            position = "left",
          },
          {
            elements = { { id = "console", size = 0.6 }, { id = "repl", size = 0.4 } },
            size     = 15,
            position = "bottom",
          },
        },
      })

      -- Auto open/close UI with session
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

      -- .vscode/launch.json is read automatically by nvim-dap (no setup needed)

      -- Resolve custom ${command:...} and ${input:...} variables from
      -- project-local VS Code extensions (e.g. call-importer-launcher)
      require("lib.dap-vscode-ext").setup()
    end,
  },

  -- Go debugger (delve)
  {
    "leoluz/nvim-dap-go",
    lazy         = true,
    dependencies = { "mfussenegger/nvim-dap" },
    config       = function()
      require("dap-go").setup({
        delve = {
          path = os.getenv("HOME") .. "/go/bin/dlv",
          initialize_timeout_sec = 30,
        },
      })
    end,
  },

  -- Python debugger (debugpy via mason)
  {
    "mfussenegger/nvim-dap-python",
    lazy         = true,
    dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
    config = function()
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(mason_path)
      require("mason-registry").refresh(function()
        local pkg = require("mason-registry").get_package("debugpy")
        if not pkg:is_installed() then pkg:install() end
      end)
    end,
  },

}
